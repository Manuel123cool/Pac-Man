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
    var oneAfterDirChange: (Bool, undoOffset: CGFloat) = (false, undoOffset: -1)
    
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
        if move(direction, noMove: true) {
            self.direction = direction
            setupArcs(direction)
        }
    }
    
    @discardableResult mutating func move(_ direction: Direction, noMove: Bool = false) -> Bool {
        let changeValue: CGFloat = 0.5
        
        if oneAfterDirChange.0 {
            switch direction {
                case .up:
                    firstArc.position.x = oneAfterDirChange.undoOffset
                    secondArc.position.x = oneAfterDirChange.undoOffset
                case .down:
                    firstArc.position.x = oneAfterDirChange.undoOffset
                    secondArc.position.x = oneAfterDirChange.undoOffset
                case .right:
                    firstArc.position.y = oneAfterDirChange.undoOffset
                    secondArc.position.y = oneAfterDirChange.undoOffset
                case .left:
                    firstArc.position.y = oneAfterDirChange.undoOffset
                    secondArc.position.y = oneAfterDirChange.undoOffset
            }
            oneAfterDirChange.0 = false
        }
        
        let  currentPos = firstArc.position
        func checkMove(arc1Pos: CGPoint, arc2Pos: CGPoint) -> Bool {
            let checkMoveResult = self.paths.checkMove(from: currentPos, to: arc1Pos)
            if checkMoveResult.valid {
                if (!noMove) {
                    firstArc.position = arc1Pos
                    secondArc.position = arc2Pos
                    
                    pos = firstArc.position
                } else {
                    oneAfterDirChange.undoOffset = checkMoveResult.undoOffset
                    oneAfterDirChange.0 = true
                }
                return true
            } else {
                return false
            }
        }
        
        switch direction {
            case .up:
                let arc1Pos = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y + changeValue))
                let arc2Pos = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y + changeValue))
                if checkMove(arc1Pos: arc1Pos, arc2Pos: arc2Pos) {
                    return true
                }
                
            case .down:
                let arc1Pos = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y - changeValue))
                let arc2Pos = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y - changeValue))
                if checkMove(arc1Pos: arc1Pos, arc2Pos: arc2Pos) {
                    return true
                }
            case .right:
                let arc1Pos = CGPoint(x: currentPos.x + changeValue, y: CGFloat(currentPos.y))
                let arc2Pos = CGPoint(x: currentPos.x + changeValue, y: CGFloat(currentPos.y))
                if checkMove(arc1Pos: arc1Pos, arc2Pos: arc2Pos) {
                    return true
                }
            case .left:
                let arc1Pos = CGPoint(x: currentPos.x - changeValue, y: CGFloat(currentPos.y))
                let arc2Pos = CGPoint(x: currentPos.x - changeValue, y: CGFloat(currentPos.y))
                if checkMove(arc1Pos: arc1Pos, arc2Pos: arc2Pos) {
                    return true
                }
        }
        return false
    }
}
