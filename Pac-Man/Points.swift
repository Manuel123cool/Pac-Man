import SpriteKit
import GameplayKit

struct Points {
    let gameScene: SKScene
    let paths: Paths
    var points: [SKShapeNode] = []
    
    init(gameScene: SKScene, changeValue: Double) {
        self.gameScene = gameScene
        self.paths = Paths(gameScene: gameScene, changeValue: changeValue, forPoints: true)
        
        draw()
    }
    
    private func perWidth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.width / 100 * percent)
    }
    
    private func perHeigth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.height / 100 * percent)
    }
    
    mutating func draw() {
       for count in 0..<5 {
            let posX = paths.perWidth(7.5 + 21.25 * CGFloat(count))
            for count1 in 0..<57 {
                let posY = paths.perHeigth(7.5 + CGFloat(count1) * (10.625 / 7))
                let circle = SKShapeNode(circleOfRadius: 2)
                circle.fillColor = SKColor(red: 179 / 255, green: 128 / 255, blue: 0, alpha: 1.0)
                circle.position = CGPoint(x: posX, y: posY)
                circle.strokeColor = .clear
                points.append(circle)
                gameScene.addChild(points.last!)
            }
        }
    
        for count in 0..<9 {
            let posY = paths.perHeigth(7.5 + 10.625 * CGFloat(count))
            for count1 in 0..<29 {
                let posX = paths.perWidth(7.5 + CGFloat(count1) * (21.25 / 7))
                let circle = SKShapeNode(circleOfRadius: 2)
                circle.fillColor = SKColor(red: 179 / 255, green: 128 / 255, blue: 0, alpha: 1.0)
                circle.position = CGPoint(x: posX, y: posY)
                circle.strokeColor = .clear
                points.append(circle)
                gameScene.addChild(points.last!)
            }
        }
        
        for (index, point) in points.enumerated() {
            var continueVar = false
            for (index1, point1) in points.enumerated() {
                if point1.position == point.position && index != index1 {
                    continueVar = true
                    break
                }
            }
            if continueVar && index != 142 {
                continue
            }
            
            for deletedPath in paths.deltedPaths {
                if paths.checkOnLine(vertical: true, path: deletedPath, to: point.position).valid {
                    points[index].position = CGPoint(x: -1, y: -1)
                } else if paths.checkOnLine(vertical: false, path: deletedPath, to: point.position).valid {
                    points[index].position = CGPoint(x: -1, y: -1)
                }
            }
        }
    }
}
