//
//  GameScene.swift
//  Pong2019
//
//  Created by  on 12/2/19.
//  Copyright © 2019 BrendansReallyCoolThings. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    
    var ball = SKSpriteNode()
    var paddle = SKSpriteNode()
    var aiPaddle = SKSpriteNode()
    var bottom = SKSpriteNode()
    var top = SKSpriteNode()
    var playerScoreLabel = SKLabelNode()
    var computerScoreLabel = SKLabelNode()
    static var playerScore = 0
    static var computerScore = 0

    func createBottomAndTopNodes() {
            // create a view at the very bottom and top
        bottom = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 50))
        bottom.position = CGPoint(x: frame.width * 0.5, y: 0)
        bottom.physicsBody = SKPhysicsBody(rectangleOf: bottom.frame.size)
        bottom.physicsBody!.isDynamic = false
        bottom.name = "bottom"
        addChild(bottom)
            
        top = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 50))
        top.position = CGPoint(x: frame.width * 0.5, y:frame.height)
        top.physicsBody = SKPhysicsBody(rectangleOf: top.frame.size)
        top.physicsBody!.isDynamic = false
        top.name = "top"
        addChild(top)
        }
    
    func setUpLabels() {
        playerScoreLabel = SKLabelNode(fontNamed: "Arial")
        playerScoreLabel.text = "0"
        playerScoreLabel.fontSize = 75
        playerScoreLabel.position = CGPoint(x: frame.width * 0.25, y: frame.height * 0.10)
        playerScoreLabel.fontColor = UIColor.white
        addChild(playerScoreLabel)
        
        computerScoreLabel = SKLabelNode(fontNamed: "Arial")
        computerScoreLabel.text = "0"
        computerScoreLabel.fontSize = 75
        computerScoreLabel.position = CGPoint(x: frame.width * 0.25, y: frame.height * 0.90)
        computerScoreLabel.fontColor = UIColor.white
        addChild(computerScoreLabel)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print(contact.contactPoint)
        if (contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 4) || (contact.bodyB.categoryBitMask == 1 && contact.bodyA.categoryBitMask == 4)
        {
            if contact.bodyA.node == top || contact.bodyB.node == top
            {
                print("ball hit top")
                GameScene.playerScore += 1
                playerScoreLabel.text = String(GameScene.playerScore)
            }
            else
            {
                print("ball hit bottom")
                GameScene.computerScore += 1
                computerScoreLabel.text = String(GameScene.computerScore)
            }
            resetBall()
            if GameScene.playerScore == 2 || GameScene.computerScore == 2
            {
                let scene = GameOverScene(size: self.size)
                scene.scaleMode = .aspectFill
                let reveal = SKTransition.doorsOpenVertical(withDuration: 0.5)
                view?.presentScene(scene, transition: reveal)
                GameScene.playerScore = 0
                GameScene.computerScore = 0
            }
            
        }
    }
    
    func resetBall()
    {
        ball.physicsBody?.velocity = CGVector.zero
        let wait = SKAction.wait(forDuration: 1)
        let repositionBall = SKAction.run(bringBallToCenter)
        let pushTheBall = SKAction.run (pushBall)
        let sequence = SKAction.sequence([wait, repositionBall, pushTheBall])
        run (sequence)
    }
    
    func bringBallToCenter()
    {
        ball.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    
    func pushBall()
    {
        ball.physicsBody?.applyImpulse(CGVector(dx: 200, dy: -200))
    }


    
    
    override func didMove(to view: SKView)
    {
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0.0
        self.physicsBody = borderBody
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        paddle = self.childNode(withName: "paddle") as! SKSpriteNode
        createBottomAndTopNodes()
        setUpLabels()
        createAIPaddle()
        
        ball.physicsBody?.categoryBitMask = 1
        paddle.physicsBody?.categoryBitMask = 2
        aiPaddle.physicsBody?.categoryBitMask = 3
        bottom.physicsBody?.categoryBitMask = 4
        top.physicsBody?.categoryBitMask = 4
        
        ball.physicsBody?.contactTestBitMask = 4
    }
    
    func createAIPaddle()
    {
        aiPaddle = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 50))
        aiPaddle.position = CGPoint(x: frame.width * 0.5, y: frame.height * 0.8)
        addChild(aiPaddle)
        aiPaddle.name = "aiPaddle"
        
        aiPaddle.physicsBody = SKPhysicsBody(rectangleOf: aiPaddle.frame.size)
        aiPaddle.physicsBody?.allowsRotation = false
        aiPaddle.physicsBody?.friction = 0
        aiPaddle.physicsBody?.affectedByGravity = false
        aiPaddle.physicsBody?.isDynamic = false
        
       run( SKAction.repeatForever(
            SKAction.sequence([SKAction.run(followBall), SKAction.wait(forDuration: 0.3)])
            ))

    }
    
    func followBall()
    {
        let move = SKAction.moveTo(x: ball.position.x, duration: 0.3)
        aiPaddle.run(move)
        
    }
    
    func makeNewBall(location : CGPoint)
    {
        var ball = SKSpriteNode(color: .gray, size: CGSize(width: 100, height: 100))
        ball.position = location
        addChild(ball)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.friction = 0
        ball.physicsBody?.allowsRotation = true
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.velocity = CGVector(dx: -500, dy: 500)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        //makeNewBall(location: location)
        if paddle.frame.contains(location)
        {
            isFingerOnPaddle = true
        }
    }
    
    var isFingerOnPaddle = false
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let location = touches.first!.location(in: self)
        if isFingerOnPaddle == true
        {
            paddle.position.x = location.x
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        isFingerOnPaddle = false
        
    }
}
