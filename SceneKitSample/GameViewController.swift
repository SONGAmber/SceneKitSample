//
//  GameViewController.swift
//  SceneKitSample
//
//  Created by Anup Harbade on 7/2/17.
//  Copyright © 2017 Anup Harbade. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    var gameView: SCNView!
    var gameScene: SCNScene!
    var cameraNode: SCNNode!
    var targetCreationTime: TimeInterval = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupScene()
        setupCameraNode()
    }
    
    func setupSceneView() {
        gameView = self.view as! SCNView
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        gameView.delegate = self
    }
    
    func setupScene() {
        gameScene = SCNScene()
        gameView.scene = gameScene
        //!To let scene view play continuosly indefinitely
        gameView.isPlaying = true
    }
    
    func setupCameraNode() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3Make(0, 5, 10)
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    func createTarget() {
        let geometry: SCNGeometry = getRandomTarget()
        
        let randomColor: UIColor = arc4random_uniform(2) == 0 ? UIColor.green: UIColor.red
        
        geometry.materials.first?.diffuse.contents = randomColor
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if randomColor == UIColor.red {
            geometryNode.name = "enemy"
        } else {
            geometryNode.name = "friend"
        }
        gameScene.rootNode.addChildNode(geometryNode)
        
        
        let randomDirection: Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let force = SCNVector3Make(randomDirection, 15, 0)
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3Make(0.05, 0.05, 0.05), asImpulse: true)
    }
    
    func getRandomTarget() -> SCNGeometry {
        let randomInt = arc4random_uniform(4)
        
        switch randomInt {
        case 0:
            return SCNPyramid(width: 1, height: 1, length: 1)
        case 1:
            return SCNCone(topRadius: 0, bottomRadius: 0.5, height: 1)
        case 2:
            return SCNSphere(radius: 0.5)
        case 3:
            return SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        default:
            return SCNPyramid(width: 1, height: 1, length: 1)
        }
    }
    
    
    func cleanup() {
        for node in gameScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime {
            createTarget()
            targetCreationTime = time + 1.0
        }
        
        cleanup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: gameView)
            let hitTest = gameView.hitTest(location, options: nil)
            
            if let hitObject = hitTest.first {
                let node = hitObject.node
                
                if node.name == "friend" {
                    node.removeFromParentNode()
                    self.gameView.backgroundColor = UIColor.black
                } else {
                    node.removeFromParentNode()
                    self.gameView.backgroundColor = UIColor.red
                }
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
