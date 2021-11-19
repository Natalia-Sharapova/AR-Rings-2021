//
//  ViewController.swift
//  ARRings
//
//  Created by Наталья Шарапова on 15.11.2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    //MARK: - Outlets
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceText: UILabel!
    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet var arrayOfLabels: [UILabel]!
    @IBOutlet weak var quitGameButton: UIButton!
    @IBOutlet weak var congradLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    //MARK: - Properties
    
    var allThrownRings: [SCNNode] = [] {
        didSet {
            if allThrownRings.count > 10 {
                DispatchQueue.main.async {
                                    // Delete the ring from scene and it's Texture
                                    let ring = self.allThrownRings.removeFirst()
                                    ring.geometry?.firstMaterial?.diffuse.contents = nil
                                    ring.removeFromParentNode()
            }
        }
    }
    }
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    
    var isAreaAdded = false {
        didSet {
            configuration.planeDetection = []
            sceneView.session.run(configuration, options: .removeExistingAnchors)
        }
    }
    
    private var powerOfThrow: Float = 0
    private var pinNodePosition = SCNVector3()
    private var swipeLocation = CGPoint()
    private var swipeStart = CGPoint()
    private var swipeEnd = CGPoint()
    private var points = 0
    
    var distance: Double = 0 {
        didSet {
            distanceLabel.text = "\(String(format: "%.1f", distance)) m"
            points = self.distance > 2.0 ? 3 : 2
        }
    }
    
    var score = 0 {
        didSet {
            DispatchQueue.main.async {
                self.scoreLabel.text = "\(self.score)"
        }
    }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.isHidden = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        for label in arrayOfLabels {
            label.alpha = 1
            label.textColor = .white
            label.textAlignment = .center
        }
        
        scoreLabel.frame = CGRect(x: view.bounds.midX - 200, y: 80, width: 100, height: 50)
        scoreLabel.font = UIFont(name: "Gill Sans", size: 45)
        
        scoreText.text = "Score:"
        scoreText.frame = CGRect(x: view.bounds.midX - 200, y: 30, width: 100, height: 50)
        scoreText.font = UIFont(name: "Gill Sans", size: 30)
        
        distanceLabel.frame = CGRect(x: view.bounds.midX + 100, y: 80, width: 100, height: 50)
        distanceLabel.font = UIFont(name: "Gill Sans", size: 36)
        
        distanceText.text = "Distance:"
        distanceText.frame = CGRect(x: view.bounds.midX + 70, y: 30, width: 130, height: 50)
        distanceText.font = UIFont(name: "Gill Sans", size: 30)
        
        quitGameButton.alpha = 0.7
        quitGameButton.layer.cornerRadius = 20
        quitGameButton.tintColor = .white
        quitGameButton.layer.borderWidth = 1
        quitGameButton.backgroundColor = .gray
        quitGameButton.setTitle("Quit game", for: .normal)
        quitGameButton.frame = CGRect(x: view.bounds.midX - 150, y: 780, width: 300, height: 50)
        quitGameButton.titleLabel?.font = UIFont(name: "Gill Sans", size: 25)
        
        congradLabel.alpha = 0.8
        congradLabel.tintColor = .white
        congradLabel.backgroundColor = .gray
        congradLabel.text = "Congratulations!"
        congradLabel.font = UIFont(name: "Gill Sans", size: 36)
        
        resultLabel.alpha = 0.8
        resultLabel.tintColor = .white
        resultLabel.backgroundColor = .gray
        resultLabel.font = UIFont(name: "Gill Sans", size: 36)
        
        restartButton.alpha = 0.8
        restartButton.tintColor = .white
        restartButton.backgroundColor = .gray
        restartButton.setTitle("Restart", for: .normal)
        restartButton.titleLabel?.font = UIFont(name: "Gill Sans", size: 35)
        
        stackView.alpha = 0.7
        stackView.layer.cornerRadius = 20
        stackView.tintColor = .white
        stackView.layer.borderWidth = 1
        stackView.backgroundColor = .gray
        
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
        
        areaNode.physicsBody?.categoryBitMask = CollisionCategory.area.rawValue
        areaNode.physicsBody?.collisionBitMask =  CollisionCategory.ring.rawValue
        
        return areaNode
    }
    
    func getPinNode() -> SCNNode {
        
        //Load scene
        let scene = SCNScene(named: "Pin.scn", inDirectory: "art.scnassets")!
        
        //Get node
        let pinNode = scene.rootNode.clone()
        
        pinNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: pinNode))
        
        pinNodePosition = pinNode.position
        
        pinNode.physicsBody?.categoryBitMask = CollisionCategory.area.rawValue
        pinNode.physicsBody?.collisionBitMask =  CollisionCategory.ring.rawValue
        
        return pinNode
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
        
        let ringNode = RingInit()
        
        //Calculation of ring direction
        let x = -matrixCameraTransform.m31 * powerOfThrow
        let y = -matrixCameraTransform.m32 * powerOfThrow
        let z = -matrixCameraTransform.m33 * powerOfThrow
        
        let forceDirection = SCNVector3(x, y, z)
        
        ringNode.physicsBody?.applyForce(forceDirection, asImpulse: true)
        
        ringNode.simdTransform = cameratransform
        
        distance = Double(sqrtf(pow(ringNode.position.x - pinNodePosition.x, 2) + pow(ringNode.position.z - pinNodePosition.z, 2)))
    
        return ringNode
    }
    
    func getScorePointNode() -> SCNNode {
       
        let scorePointNode = ScorePointInit()
        
        scorePointNode.position = SCNVector3(0, 0, 0)
        scorePointNode.eulerAngles.x = .pi / 2
        
        return scorePointNode
    }
    
    func getScorePointNode2() -> SCNNode {
        
        let scorePointNode2 = ScorePoint2Init()
      
        scorePointNode2.position = SCNVector3(-0.4, -3.3, -8)
       
        return scorePointNode2
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        guard let nodeAMask = contact.nodeA.physicsBody?.categoryBitMask,
              let nodeBMask = contact.nodeB.physicsBody?.categoryBitMask
        
        else { return }
        
        // When the Ball touch the Point, it disables contact for correct counting of these balls
        if nodeAMask & nodeBMask == CollisionCategory.scorePoint.rawValue & CollisionCategory.scorePoint2.rawValue {
            
            contact.nodeA.physicsBody?.contactTestBitMask = 0
            contact.nodeB.physicsBody?.contactTestBitMask = 0
            
            score += points
        }
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
    
    func updateUI() {
        allThrownRings.forEach{ ring in ring.removeFromParentNode() }
        allThrownRings.removeAll()
        distanceLabel.text = ""
        scoreLabel.text = ""
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
            areaNode.addChildNode(getPinNode())
            areaNode.addChildNode(getScorePointNode2())
        }
    }
    
    @IBAction func userPanned(_ sender: UIPanGestureRecognizer) {
        
        //Get location of swipe
        swipeLocation = sender.location(in: sceneView)
        
        if !isAreaAdded {
            return
        } else {
        
        //Calculating of power for throwing the ring
        switch sender.state {
        case .began:
            swipeStart = sender.location(in: sceneView)
        case .ended:
            swipeEnd = sender.location(in: sceneView)
            
            calculatingOfPower()
            
            //Add new ball
            guard let ringNode = getRingNode() else { return }
           ringNode.eulerAngles.x = .pi / 2
           ringNode.eulerAngles.y = .pi / 2
            
            allThrownRings.append(ringNode)
            
            sceneView.scene.rootNode.addChildNode(ringNode)
            ringNode.addChildNode(getScorePointNode())
            
        default:
          break
        }
        }
    }
    
    @IBAction func quitGamePressed(_ sender: UIButton) {
        
        stackView.isHidden = false
        resultLabel.text = "Your score: \(score)"
    }
    
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        updateUI()
        score = 0
        stackView.isHidden = true
    }
}

