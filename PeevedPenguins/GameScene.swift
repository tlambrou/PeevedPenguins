//
//  GameScene.swift
//  PeevedPenguins
//
//  Created by Tassos Lambrou on 6/24/16.
//  Copyright (c) 2016 tassos. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* Game object connections */
    var catapultArm: SKSpriteNode!
    var catapult: SKSpriteNode!
    var levelNode: SKNode!
    
    var wPenguin1: SKSpriteNode!
    var wPenguin2: SKSpriteNode!
    var wPenguin3: SKSpriteNode!
    
    /* Camera helpers */
    var cameraTarget: SKNode?
    
    var buttonRestart: MSButtonNode!
    var cantileverNode: SKSpriteNode!
    var touchNode: SKSpriteNode!
    
    /* Physics helpers */
    var touchJoint: SKPhysicsJointSpring?
    
    var penguinJoint: SKPhysicsJointPin?
    
    var penguinCount: Int = 0
    var score: Int = 0
    var scoreLabel: SKLabelNode!
    
    
//    var highscore: Int = 0
//    var highScoreLabel: SKLabelNode!
    
    override func didMoveToView(view: SKView) {
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set reference to catapultArm node */
        catapultArm = childNodeWithName("catapultArm") as! SKSpriteNode
        catapult = childNodeWithName("catapult") as! SKSpriteNode
        
        //Waiting Penguins
        wPenguin1 = childNodeWithName("waitingPenguin1") as! SKSpriteNode
        wPenguin2 = childNodeWithName("waitingPenguin2") as! SKSpriteNode
        wPenguin3 = childNodeWithName("waitingPenguin3") as! SKSpriteNode
        
        //Score
        scoreLabel = childNodeWithName("//scoreLabel") as! SKLabelNode
//        highScoreLabel = childNodeWithName("//highScoreLabel") as! SKLabelNode
        
        /* Set reference to the level loader node */
        levelNode = childNodeWithName("//levelNode")
        
        // Set reference to cantileverNode
        cantileverNode = childNodeWithName("cantileverNode") as! SKSpriteNode
        
        //Set reference to touchNode
        touchNode = childNodeWithName("touchNode") as! SKSpriteNode
        
        /* Load Level 1 */
        let resourcePath = NSBundle.mainBundle().pathForResource("Level1", ofType: "sks")
        let newLevel = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
        levelNode.addChild(newLevel)
        
        /* Create catapult arm physics body of type alpha */
        let catapultArmBody = SKPhysicsBody (texture: catapultArm!.texture!, size: catapultArm.size)
        
        /* Set mass, needs to be heavy enough to hit the penguin with solid force */
        catapultArmBody.mass = 0.5
        
        /* Apply gravity to catapultArm */
        catapultArmBody.affectedByGravity = false
        
        /* Improves physics collision handling of fast moving objects */
        catapultArmBody.usesPreciseCollisionDetection = true
        
        /* Assign the physics body to the catapult arm */
        catapultArm.physicsBody = catapultArmBody
        
        /* Set UI connections */
        buttonRestart = self.childNodeWithName("//buttonRestart") as! MSButtonNode
        
        /* Setup restart button selection handler */
        buttonRestart.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFit
            
            /* Show debug */
            skView.showsPhysics = true
            skView.showsDrawCount = true
            skView.showsFPS = false
            
            /* Restart game scene */
            skView.presentScene(scene)
            self.penguinCount = 0
            
        }
        
        
        
        /* Pin joint catapult and catapult arm */
        let catapultPinJoint = SKPhysicsJointPin.jointWithBodyA(catapult.physicsBody!, bodyB: catapultArm.physicsBody!, anchor: CGPoint(x:210 ,y:103))
        physicsWorld.addJoint(catapultPinJoint)
        
        /* Spring joint catapult arm and cantilever node */
        let catapultSpringJoint = SKPhysicsJointSpring.jointWithBodyA(catapultArm.physicsBody!, bodyB: cantileverNode.physicsBody!, anchorA: catapultArm.position + CGPoint(x:15, y:30), anchorB: cantileverNode.position)
        physicsWorld.addJoint(catapultSpringJoint)
        
        /* Make this joint a bit more springy */
        catapultSpringJoint.frequency = 1.5
        
    }
    
    /*
     override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Add a new penguin to the scene */
        let resourcePath = NSBundle.mainBundle().pathForResource("Penguin", ofType: "sks")
        let penguin = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
        addChild(penguin)
        
        /* Move penguin to the catapult bucket area */
        penguin.avatar.position = catapultArm.position + CGPoint(x: 32, y: 50)
        
        /* Impulse vector */
        let launchDirection = CGVector(dx: 1, dy: 0)
        let force = launchDirection * 20
        
        /* Apply impulse to penguin */
        penguin.avatar.physicsBody?.applyImpulse(force)
        
        /* Set camera to follow penguin */
        cameraTarget = penguin.avatar
    } 
     */
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        /* There will only be one touch as multi touch is not enabled by default */
        for touch in touches {
            
            /* Grab scene position of touch */
            let location    = touch.locationInNode(self)
            
            /* Get node reference if we're touching a node */
            let touchedNode = nodeAtPoint(location)
            
            /* Is it the catapult arm? */
            if touchedNode.name == "catapultArm" {
                
                /* Reset touch node position */
                touchNode.position = location
                
                /* Spring joint touch node and catapult arm */
                touchJoint = SKPhysicsJointSpring.jointWithBodyA(touchNode.physicsBody!, bodyB: catapultArm.physicsBody!, anchorA: location, anchorB: location)
                physicsWorld.addJoint(touchJoint!)
                
            }
        }
        
        /* Add a new penguin to the scene */
        let resourcePath = NSBundle.mainBundle().pathForResource("Penguin", ofType: "sks")
        let penguin = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
        addChild(penguin)
        
        //Add to penguin life count
        penguinCount += 1
        
        
        //Make waiting penguins visible or not
        
        switch penguinCount {
        case 1:
            wPenguin3.removeFromParent()
        case 2:
            wPenguin2.removeFromParent()
        case 3:
            wPenguin1.removeFromParent()
        default:
            print(penguinCount)
            
        }
        
        
        
        
        /* Position penguin in the catapult bucket area */
        penguin.avatar.position = catapultArm.position + CGPoint(x: 32, y: 50)
        
        /* Improves physics collision handling of fast moving objects */
        penguin.avatar.physicsBody?.usesPreciseCollisionDetection = true
        
        /* Setup pin joint between penguin and catapult arm */
        penguinJoint = SKPhysicsJointPin.jointWithBodyA(catapultArm.physicsBody!, bodyB: penguin.avatar.physicsBody!, anchor: penguin.avatar.position)
        physicsWorld.addJoint(penguinJoint!)
        
        /* Remove any camera actions */
        camera?.removeAllActions()
        
        /* Set camera to follow penguin */
        cameraTarget = penguin.avatar
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch moved */
        
        /* There will only be one touch as multi touch is not enabled by default */
        for touch in touches {
            
            /* Grab scene position of touch and update touchNode position */
            let location       = touch.locationInNode(self)
            touchNode.position = location
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch ended */
        
        /* Let it fly!, remove joints used in catapult launch */
        if let touchJoint = touchJoint { physicsWorld.removeJoint(touchJoint) }
        
        if let penguinJoint = penguinJoint { physicsWorld.removeJoint(penguinJoint) }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent SKSpriteNode */
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        
        /* Check if either physics bodies was a seal */
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            
            /* Was the collision more than a gentle nudge? */
            if contact.collisionImpulse > 2.0 {
                
                /* Kill Seal(s) */
                if contactA.categoryBitMask == 2 { dieSeal(nodeA) }
                if contactB.categoryBitMask == 2 { dieSeal(nodeB) }
            }
        }
    }
    
    func dieSeal(node: SKNode) {
        /* Seal death*/
        
        
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "SealExplosion")!
        
        /* Convert node location (currently inside Level 1, to scene space) */
        particles.position = convertPoint(node.position, fromNode: node)
        
        /* Restrict total particles to reduce runtime of particle */
        particles.numParticlesToEmit = 25
        
        /* Add particles to scene */
        addChild(particles)
        
        /* Play SFX */
        let sealSFX = SKAction.playSoundFileNamed("//sfx_seal", waitForCompletion: false)
        self.runAction(sealSFX)
        
        /* Create our hero death action */
        let sealDeath = SKAction.runBlock({
            /* Remove seal node from scene */
            node.removeFromParent()
            self.score += 1
            
//            if self.score > self.highscore {
//                self.highscore = self.score
//                print ("You got a high score")
//                self.highScoreLabel.text = String(self.highscore)
//            }
            
                /* Update score label */
                self.scoreLabel.text = String(self.score)
                return
                    
           
            
            print(self.score)
        })
        
        self.runAction(sealDeath)
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        /* Check we have a valid camera target to follow */
        if let cameraTarget = cameraTarget {
            
            /* Set camera position to follow target horizontally, keep vertical locked */
            camera?.position = CGPoint(x:cameraTarget.position.x, y:camera!.position.y)
            
            /* Clamp camera scrolling to our visible scene area only */
            camera?.position.x.clamp(283, 677)
            
            /* Check penguin has come to rest */
            if cameraTarget.physicsBody?.joints.count == 0 && cameraTarget.physicsBody?.velocity.length() < 0.18 || cameraTarget.position.x > CGFloat(677)  {
                
                
                cameraTarget.removeFromParent()
                
                /* Reset catapult arm */
                catapultArm.physicsBody?.velocity = CGVector(dx:0, dy:0)
                catapultArm.physicsBody?.angularVelocity = 0
                catapultArm.zRotation = 0
                
                /* Reset camera */
                let cameraReset = SKAction.moveTo(CGPoint(x:284, y:camera!.position.y), duration: 1.5)
                let cameraDelay = SKAction.waitForDuration(0.5)
                let cameraSequence = SKAction.sequence([cameraDelay,cameraReset])
                
                camera?.runAction(cameraSequence)
                
                
                
            }
            
            
            if cameraTarget.physicsBody?.joints.count == 0 && cameraTarget.physicsBody?.velocity.length() < 0.18 && penguinCount >= 3 {
                
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = GameScene(fileNamed:"GameScene") as GameScene!
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .AspectFit
                
                /* Show debug */
                skView.showsPhysics = true
                skView.showsDrawCount = true
                skView.showsFPS = false
                
                /* Restart game scene */
                skView.presentScene(scene)
                
                penguinCount = 0
            }


            
        }
            }
    
    
}