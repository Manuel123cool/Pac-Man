import SpriteKit
import GameplayKit

struct Path {
    let gameScene: SKScene
    let startPoint: CGPoint
    let endPoint: CGPoint
    let alignmentVertical: Bool
    var line: SKShapeNode = SKShapeNode()
    let drawYes = false
    
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
        guard drawYes else {
            return
        }
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
    var startPostion = CGPoint(x: -1, y: -1)
    let changeValue: Double

    init(gameScene: SKScene, changeValue: Double) {
        self.gameScene = gameScene
        self.changeValue = changeValue
        
        self.startPostion = CGPoint(x: roundToChangeValue(perWidth(20)),
            y: roundToChangeValue(perHeigth(7.5)))
        
        addPaths()
        
        deletPath(index: 17, vertical: true)
        deletPath(index: 18, vertical: true)
        deletPath(index: 22, vertical: false)
        deletPath(index: 17, vertical: false)

    }
    
    func perWidth(_ percent: CGFloat) -> CGFloat {
        return gameScene.size.width / 100 * percent
    }
    
    func perHeigth(_ percent: CGFloat) -> CGFloat {
        return gameScene.size.height / 100 * percent
    }
    
    mutating func addPath(startPoint: CGPoint, endPoint: CGPoint) {
        let start = CGPoint(x: roundToChangeValue(startPoint.x),
            y: roundToChangeValue(startPoint.y))
        let end = CGPoint(x: roundToChangeValue(endPoint.x),
            y: roundToChangeValue(endPoint.y))
        paths.append(.init(startPoint: start, endPoint: end, gameScene: gameScene))
      
    }
    
    mutating func addPaths() {
        for row in 0..<8 {
            for column in 0..<5 {
                addPath(startPoint: CGPoint(x: perWidth(CGFloat(column) * 21.25 + 7.5), y: perHeigth(CGFloat(row) * 10.625 + 7.5)),
                            endPoint: CGPoint(x: perWidth(CGFloat(column) * 21.25 + 7.5), y: perHeigth(CGFloat(row + 1) * 10.625 + 7.5)))
            }
        }
        
        for row in 0..<9 {
            for column in 0..<4 {
                addPath(startPoint: CGPoint(x: perWidth(CGFloat(column) * 21.25 + 7.5), y: perHeigth(CGFloat(row) * 10.625 + 7.5)),
                            endPoint: CGPoint(x: perWidth(CGFloat(column + 1) * 21.25 + 7.5), y: perHeigth(CGFloat(row) * 10.625 + 7.5)))
            }
        }
    }
    
    mutating func deletPath(index: Int, vertical: Bool) {
        if !vertical {
            paths[index].line.removeFromParent()
            paths.remove(at: index)
            paths.insert(Path(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 0), gameScene: gameScene), at: index)
        } else {
            paths[index + 40].line.removeFromParent()
            paths.remove(at: index + 40)
            paths.insert(Path(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 0), gameScene: gameScene), at: index + 40)
        }
    }
    
    func roundToChangeValue(_ valuePar: CGFloat) -> CGFloat {
        let value = Double(valuePar)
        var roundValue: Double = 0
        while true {
            if roundValue < value {
                roundValue += changeValue
            } else {
                break
            }
        }
        if (roundValue - changeValue - value) * 1 > roundValue - value {
            return CGFloat(roundValue - changeValue)
        } else {
            return CGFloat(roundValue)
        }
    }
    
    func inRange(_ firstValue: CGFloat, _ secondValue: CGFloat) -> Bool {
        let offsetValue: CGFloat = 10
        if firstValue >= secondValue - offsetValue &&
            firstValue <= secondValue + offsetValue {
            return true
        }
        return false
    }
    
    func checkOnLine(vertical: Bool, path: Path, to: CGPoint) -> (valid: Bool, reachPos: CGFloat) {
        if vertical && inRange(to.y, path.startPoint.y) {
            if to.x >= path.startPoint.x && to.x <= path.endPoint.x  {
                return (valid: true, reachPos: path.startPoint.y)
            }
        } else if !vertical && inRange(to.x, path.startPoint.x) {
            if to.y >= path.startPoint.y && to.y <= path.endPoint.y  {
                return (valid: true, reachPos: path.startPoint.x)
            }
        }
        return (valid: false, reachPos: -1)
    }
    
    func checkMove(from: CGPoint, to: CGPoint) -> (valid: Bool, reachPos: CGFloat) {
        let vertical: Bool
        if from.x == to.x {
            vertical = false
        } else if from.y == from.y {
            vertical = true
        } else {
            print("Error: No straight move")
            return (valid: false, reachPos: -1)
        }
        
        for path in paths {
            if path.alignmentVertical && vertical {
                let chechOnLineResult = checkOnLine(vertical: vertical, path: path, to: to)
                if chechOnLineResult.valid {
                    return (valid: true, reachPos: chechOnLineResult.reachPos)
                }
            }
            
            if !path.alignmentVertical && !vertical {
                let chechOnLineResult = checkOnLine(vertical: vertical, path: path, to: to)
                if chechOnLineResult.valid {
                    return (valid: true, reachPos: chechOnLineResult.reachPos)
                }
            }
        }
        return (valid: false, reachPos: -1)
    }
}
