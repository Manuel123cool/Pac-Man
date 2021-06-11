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
    let paths: Paths
    var pos: CGPoint
    var direction: Direction = .left
    var afterDirChange: (yes: Bool, reachPos: CGFloat, dir: Direction) =
        (yes: false, reachPos: -1, dir: .left)
    
    var firstArc: SKShapeNode = SKShapeNode()
    var secondArc: SKShapeNode = SKShapeNode()
    init(gameScene: SKScene) {
        self.gameScene = gameScene
        self.paths = Paths(gameScene: self.gameScene)
        self.pos = paths.startPostion
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
        firstArc.zPosition = 1
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
        secondArc.zPosition = 1
        gameScene.addChild(secondArc)
    }
    
    mutating func changeDir(_ direction: Direction) {
        move(direction, noMove: true)
    }
    
    mutating func move(_ directionForChance: Direction, noMove: Bool = false) {
        let changeValue: CGFloat = 0.5
        
        breakForNotReached: if afterDirChange.yes {
            var reachedChangeDir = false
            switch afterDirChange.dir {
                case .up, .down:
                    if firstArc.position.x == afterDirChange.reachPos {
                        reachedChangeDir = true
                    }
                case .right, .left:
                    if firstArc.position.y == afterDirChange.reachPos {
                        reachedChangeDir = true
                    }
            }
            
            guard reachedChangeDir else {
                break breakForNotReached
            }
            
            self.direction = afterDirChange.dir
            setupArcs(self.direction)
            afterDirChange.yes = false
        }
        
        let  currentPos = firstArc.position
        func checkMove(arc1Pos: CGPoint, arc2Pos: CGPoint) {
            let checkMoveResult = self.paths.checkMove(from: currentPos, to: arc1Pos)
            if checkMoveResult.valid {
                if (!noMove) {
                    firstArc.position = arc1Pos
                    secondArc.position = arc2Pos
                    pos = firstArc.position
                } else {
                    afterDirChange.reachPos = checkMoveResult.reachPos
                    afterDirChange.yes = true
                    afterDirChange.dir = directionForChance
                }
            }
        }
        
        let finalDir: Direction
        if noMove {
            finalDir = directionForChance
        } else {
            finalDir = self.direction
        }
        
        switch finalDir {
            case .up:
                let arc1Pos = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y + changeValue))
                let arc2Pos = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y + changeValue))
                checkMove(arc1Pos: arc1Pos, arc2Pos: arc2Pos)
            case .down:
                let arc1Pos = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y - changeValue))
                let arc2Pos = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y - changeValue))
                checkMove(arc1Pos: arc1Pos, arc2Pos: arc2Pos)
            case .right:
                let arc1Pos = CGPoint(x: currentPos.x + changeValue, y: CGFloat(currentPos.y))
                let arc2Pos = CGPoint(x: currentPos.x + changeValue, y: CGFloat(currentPos.y))
                checkMove(arc1Pos: arc1Pos, arc2Pos: arc2Pos)
            case .left:
                let arc1Pos = CGPoint(x: currentPos.x - changeValue, y: CGFloat(currentPos.y))
                let arc2Pos = CGPoint(x: currentPos.x - changeValue, y: CGFloat(currentPos.y))
                checkMove(arc1Pos: arc1Pos, arc2Pos: arc2Pos)
        }
    }
}
