import SpriteKit
import GameplayKit

struct Points {
    let gameScene: SKScene
    let paths: Paths
    var points: [SKShapeNode] = []
    let pacManRadius: Double
    let pointRadius: CGFloat = 2
    var eaten = 0
    init(gameScene: SKScene, changeValue: Double, pacManRadius: Double) {
        self.gameScene = gameScene
        self.paths = Paths(gameScene: gameScene, changeValue: changeValue, forPoints: true)
        self.pacManRadius = pacManRadius
        
        draw()
    }
    
    
    mutating func update(figurePos: CGPoint) -> (Int, Bool) {
        let wasEaten = eaten
        checkBeeingEaten(figurePos: figurePos)
        var pointNum = 0
        for point in points {
            if point.position.x == -1 {
                pointNum += 1
            }
        }
        eaten = pointNum
        let allEaten = checkAllEaten()
        return (pointNum - wasEaten, allEaten)
    }
    
    private func checkAllEaten() -> Bool {
        var once = false
        for point in points {
            if point.position.x > 0 {
                once = true
                return false
            }
        }
        if !once {
            return true
        }
    }
    
    private mutating func checkBeeingEaten(figurePos: CGPoint) {
        let radiusF = CGFloat(pacManRadius)
        for (index, point) in points.enumerated() {
            if point.position.x == -1 {
                continue
            }
            
            if Monsters.distanceBetween(point1: point.position, point2: figurePos) - (radiusF + pointRadius) < 0 {
                points[index].position = CGPoint(x: -1, y: -1)
            }
        }
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
                let circle = SKShapeNode(circleOfRadius: pointRadius)
                circle.fillColor = SKColor(red: 179 / 255, green: 128 / 255, blue: 0, alpha: 1.0)
                circle.position = CGPoint(x: posX, y: posY)
                circle.strokeColor = .clear
                circle.zPosition = 0.5
                points.append(circle)
                gameScene.addChild(points.last!)
            }
        }
    
        for count in 0..<9 {
            let posY = paths.perHeigth(7.5 + 10.625 * CGFloat(count))
            for count1 in 0..<29 {
                let posX = paths.perWidth(7.5 + CGFloat(count1) * (21.25 / 7))
                let circle = SKShapeNode(circleOfRadius: pointRadius)
                circle.fillColor = SKColor(red: 179 / 255, green: 128 / 255, blue: 0, alpha: 1.0)
                circle.position = CGPoint(x: posX, y: posY)
                circle.strokeColor = .clear
                circle.zPosition = 0.5
                points.append(circle)
                gameScene.addChild(points.last!)
            }
        }
        
        for (index, point) in points.enumerated() {
            var continueVar = false
            for (index1, point1) in points.enumerated() {
                if point1.position == point.position && index != index1 {
                    points[index1].position = CGPoint(x: -2, y: -2)
                    continueVar = true
                    break
                }
            }
            if continueVar && index != 142 {
                continue
            }
            
            for deletedPath in paths.deltedPaths {
                if paths.checkOnLine(vertical: true, path: deletedPath, to: point.position).valid {
                    points[index].position = CGPoint(x: -2, y: -2)
                } else if paths.checkOnLine(vertical: false, path: deletedPath, to: point.position).valid {
                    points[index].position = CGPoint(x: -2, y: -2)
                }
            }
        }
    }
    
    func clear() {
        for (index, _) in points.enumerated() {
            points[index].removeFromParent()
        }
    }
}
