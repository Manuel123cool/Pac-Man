import SpriteKit
import GameplayKit

enum Direction: CGFloat {
    case left = 0
    case right = 180
    case up = 270
    case down = 90
}

struct Figure {
    let gameScene: SKScene
    
    var pos: CGPoint = CGPoint(x: 100, y: 100)
    var direction: Direction = .left
    var crocodileOpeningValue = 0
    
    var firstArc: SKShapeNode = SKShapeNode()
    var secondArc: SKShapeNode = SKShapeNode()
    init(gameScene: SKScene) {
        self.gameScene = gameScene
        
        setupArcs(direction)
    }
    
    private mutating func setupArcs(_ direction: Direction) {
        firstArc.removeFromParent()
        secondArc.removeFromParent()
        
        let baseAngle = direction.rawValue
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero,
                    radius: 15,
                    startAngle: CGFloat(baseAngle * CGFloat.pi / 180),
                    endAngle: CGFloat(CGFloat(baseAngle + 180) * CGFloat.pi / 180),
                    clockwise: true
        )
        
        
        firstArc = SKShapeNode(path: path)
        firstArc.fillColor = .yellow
        firstArc.position = pos
        
        let rotationAction = SKAction.rotate(byAngle: CGFloat(40 * CGFloat.pi / 180), duration: 0.3)
        let rotationAction1 = SKAction.rotate(byAngle: CGFloat(-40 * CGFloat.pi / 180), duration: 0.3)
        
        let sequence = SKAction.sequence([rotationAction, rotationAction1])
        let repeatAction = SKAction.repeatForever(sequence)
        firstArc.run(repeatAction)
        
        gameScene.addChild(firstArc)
        
        let path1 = CGMutablePath()
        path1.addArc(center: CGPoint.zero,
                    radius: 15,
                    startAngle: CGFloat(CGFloat(baseAngle + 180) * CGFloat.pi / 180),
                    endAngle: CGFloat(baseAngle * CGFloat.pi / 180),
                    clockwise: true
        )
        
        
        secondArc = SKShapeNode(path: path1)
        secondArc.fillColor = .yellow
        secondArc.position = pos
        
        let sequence1 = SKAction.sequence([rotationAction1, rotationAction])
        let repeatAction1 = SKAction.repeatForever(sequence1)

        secondArc.run(repeatAction1)
        gameScene.addChild(secondArc)
    }
    
    mutating func changeDir(_ direction: Direction) {
        self.direction = direction
        setupArcs(direction)
    }
    
    mutating func move() {
        let changeValue: CGFloat = 0.5
        let  currentPos = firstArc.position
        
        switch direction {
            case .up:
                firstArc.position = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y + changeValue))
                secondArc.position = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y + changeValue))
            case .down:
                firstArc.position = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y - changeValue))
                secondArc.position = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y - changeValue))
            case .right:
                firstArc.position = CGPoint(x: currentPos.x + changeValue, y: CGFloat(currentPos.y))
                secondArc.position = CGPoint(x: currentPos.x + changeValue, y: CGFloat(currentPos.y))
            case .left:
                firstArc.position = CGPoint(x: currentPos.x - changeValue, y: CGFloat(currentPos.y))
                secondArc.position = CGPoint(x: currentPos.x - changeValue, y: CGFloat(currentPos.y))
        }
        pos = firstArc.position
    }
}
