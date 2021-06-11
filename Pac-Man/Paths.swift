import SpriteKit
import GameplayKit

struct Path {
    let gameScene: SKScene
    let startPoint: CGPoint
    let endPoint: CGPoint
    let alignmentVertical: Bool
    var line: SKShapeNode = SKShapeNode()
    
    init(startPoint: CGPoint, endPoint: CGPoint, gameScene: SKScene) {
        self.gameScene = gameScene
        self.startPoint = startPoint
        self.endPoint = endPoint
        if startPoint.x == endPoint.x {
            alignmentVertical = false
            if endPoint.y < startPoint.y {
                print("Error: Line must be button to top")
                return
            }
        } else if startPoint.y == endPoint.y {
            alignmentVertical = true
            if endPoint.x < startPoint.x {
                print("Error: Line must be left to right")
                return
            }
        } else {
            print("Error: Points dont align")
            alignmentVertical = false
            return
        }
        draw()
    }
    
    mutating func draw() {
        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        line = SKShapeNode(path: path)
        line.zPosition = 0
        line.strokeColor = .white
        line.lineWidth = 2
        gameScene.addChild(line)
    }
}

struct Paths {
    let gameScene: SKScene
    var paths: [Path] = []
    let startPostion = CGPoint(x: 150, y: 100)
    
    init(gameScene: SKScene) {
        self.gameScene = gameScene
        
        addPath(startPoint: CGPoint(x: 100, y: 100), endPoint: CGPoint(x: 200, y: 100))
        addPath(startPoint: CGPoint(x: 100, y: 0), endPoint: CGPoint(x: 100, y: 100))
        addPath(startPoint: CGPoint(x: 100, y: 100), endPoint: CGPoint(x: 100, y: 200))
    }
    
    mutating func addPath(startPoint: CGPoint, endPoint: CGPoint) {
        paths.append(.init(startPoint: startPoint, endPoint: endPoint, gameScene: gameScene))
        
    }
    
    func inRange(_ firstValue: CGFloat, _ secondValue: CGFloat) -> Bool {
        let offsetValue: CGFloat = 10
        if firstValue >= secondValue - offsetValue &&
            firstValue <= secondValue + offsetValue {
            return true
        }
        return false
    }
    
    func checkOnLine(vertical: Bool, path: Path, to: CGPoint) -> (valid: Bool, undoOffset: CGFloat) {
        if vertical && inRange(to.y, path.startPoint.y) {
            if to.x >= path.startPoint.x && to.x <= path.endPoint.x  {
                return (valid: true, undoOffset: path.startPoint.y)
            }
        } else if !vertical && inRange(to.x, path.startPoint.x) {
            if to.y >= path.startPoint.y && to.y <= path.endPoint.y  {
                return (valid: true, undoOffset: path.startPoint.x)
            }
        }
        return (valid: false, undoOffset: -1)
    }
    
    func checkMove(from: CGPoint, to: CGPoint) -> (valid: Bool, undoOffset: CGFloat) {
        let vertical: Bool
        if from.x == to.x {
            vertical = false
        } else if from.y == from.y {
            vertical = true
        } else {
            print("Error: No straight move")
            return (valid: false, undoOffset: -1)
        }
        
        for path in paths {
            if path.alignmentVertical && vertical {
                let chechOnLineResult = checkOnLine(vertical: vertical, path: path, to: to)
                if chechOnLineResult.valid {
                    return (valid: true, undoOffset: chechOnLineResult.undoOffset)
                }
            }
            
            if !path.alignmentVertical && !vertical {
                let chechOnLineResult = checkOnLine(vertical: vertical, path: path, to: to)
                if chechOnLineResult.valid {
                    return (valid: true, undoOffset: chechOnLineResult.undoOffset)
                }
            }
        }
        return (valid: false, undoOffset: -1)
    }
}
