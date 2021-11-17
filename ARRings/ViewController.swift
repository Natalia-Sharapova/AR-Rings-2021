//
//  ViewController.swift
//  ARRings
//
//  Created by Наталья Шарапова on 15.11.2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    //MARK: - Outlets
    
    @IBOutlet var sceneView: ARSCNView!
    
    //MARK: - Properties
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    
    var isAreaAdded = false {
        didSet {
            configuration.planeDetection = []
            sceneView.session.run(configuration, options: .removeExistingAnchors)
        }
    }
    
    private var powerOfThrow: Float = 0
    private var swipeLocation = CGPoint()
    private var swipeStart = CGPoint()
    private var swipeEnd = CGPoint()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Detect horizontal planes
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Methods
    
    func calculatingOfPower() {
        
        let swipePower = Float(swipeStart.y - swipeEnd.y) / Float(sceneView.frame.height)
        powerOfThrow = 50 * (0.1 + swipePower)
    
    }
    
    func getAreaNode() -> SCNNode {
        
        //Load scene
        let scene = SCNScene(named: "Rings.scn", inDirectory: "art.scnassets")!
        
        //Get node
        let areaNode = scene.rootNode.clone()
        
        areaNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: areaNode))
        
        return areaNode
    }
    
    //Getting and visualisation horisontal plane for user's tap and setting areaNode
    func getPlaneNode(for anchor: ARPlaneAnchor) -> SCNNode {
        
        //Get extent
        let extent = anchor.extent
        
        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        
        plane.firstMaterial?.diffuse.contents = UIColor.green
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 0.5
        planeNode.eulerAngles.x -= .pi / 2
        
        return planeNode
    }
    
    func getRingNode() -> SCNNode? {
        
        guard let frame = sceneView.session.currentFrame else { return nil }
        
        //Get camera transform
        
        let cameratransform = frame.camera.transform
        let matrixCameraTransform = SCNMatrix4(cameratransform)
        
        //Ring geometry
        let ring = SCNTorus(ringRadius: 0.1, pipeRadius: 0.01)
        ring.firstMaterial?.diffuse.contents = UIImage(named: "gold")
        
        //Get node
        let ringNode = SCNNode(geometry: ring)
        
        //Get physics body
        ringNode.physicsBody = SCNPhysicsBody(type: .dynamic,
                                              shape: SCNPhysicsShape(
                                              node: ringNode,
                                              options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        //Calculation of ring direction
        let x = -matrixCameraTransform.m31 * powerOfThrow
        let y = -matrixCameraTransform.m32 * powerOfThrow
        let z = -matrixCameraTransform.m33 * powerOfThrow
        
        let forceDirection = SCNVector3(x, y, z)
        
        ringNode.physicsBody?.applyForce(forceDirection, asImpulse: true)
        
        ringNode.simdTransform = cameratransform
        
        return ringNode
    }
    
    func updatePlaneNode(_ node: SCNNode, for anchor: ARPlaneAnchor) {
        guard let planeNode = node.childNodes.first, let plane = planeNode.geometry as? SCNPlane else {
            return
        }
        //Change planeNode center
        planeNode.simdPosition = anchor.center
        
        //Change plane size
        let extent = anchor.extent
        plane.height = CGFloat(extent.z)
        plane.width = CGFloat(extent.x)
    }

    // MARK: - ARSCNViewDelegate
    
     func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal else { return }
        
        //Add the areaNode to the center of detected horizontal plane
        node.addChildNode(getPlaneNode(for: planeAnchor))
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal else { return }
        
        //Update planeNode
        updatePlaneNode(node, for: planeAnchor)
    }
    
    //MARK: - Actions
    
    @IBAction func userTapped(_ sender: UITapGestureRecognizer) {
        
        if isAreaAdded {
         return
            
        } else {
            
            let location = sender.location(in: sceneView)
            
            //Let array of AR objects, which lay on the line from tap to scene
            guard let result = sceneView.hitTest(location, types: .existingPlaneUsingExtent).first else { return }
            guard let anchor = result.anchor as? ARPlaneAnchor, anchor.alignment == .horizontal else { return }
            
            //Get areaNode and set its coordinates to the point of user touch
            let areaNode = getAreaNode()
            
            areaNode.simdTransform = result.worldTransform
            
            isAreaAdded = true
            
            sceneView.scene.rootNode.addChildNode(areaNode)
            
        }
    }
    
    
    @IBAction func userPanned(_ sender: UIPanGestureRecognizer) {
        
        //Get location of swipe
        swipeLocation = sender.location(in: sceneView)
        
        if !isAreaAdded {
            return
        } else {
        
        //Calculating of power for throwing the ball
            
        switch sender.state {
        case .began:
            swipeStart = sender.location(in: sceneView)
        case .ended:
            swipeEnd = sender.location(in: sceneView)
            
            calculatingOfPower()
            
            //Add new ball
            guard let ringNode = getRingNode() else { return }
            ringNode.eulerAngles.z -= .pi / 2
            
            sceneView.scene.rootNode.addChildNode(ringNode)
        default:
          break
        }
        }
    }
    }

