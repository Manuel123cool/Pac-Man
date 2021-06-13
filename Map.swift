import SpriteKit
import GameplayKit

struct Map {
    let gameScene: SKScene
    let pacManRadius: Double
    let paths: Paths
    
    func draw() {
        drawSurroundings()
        drawRects()
    }
    
    func perWidth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.width / 100 * percent)
    }
    
    func perHeigth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.height / 100 * percent)
    }
    
    func drawSurroundings() {
        let pacManRadiusF = CGFloat(pacManRadius + 4)
        let lineXLeft = perWidth(7.5) - pacManRadiusF
        let lineXRight = gameScene.size.width - lineXLeft
        let lineYDown = perHeigth(7.5) - pacManRadiusF
        let lineYUp = gameScene.size.height - lineYDown
        drawLine(CGPoint(x: lineXRight, y: lineYDown), CGPoint(x: lineXRight, y: lineYUp))
        drawLine(CGPoint(x: lineXLeft, y: lineYDown), CGPoint(x: lineXLeft, y: lineYUp))
        drawLine(CGPoint(x: lineXLeft, y: lineYDown), CGPoint(x: lineXRight, y: lineYDown))
        drawLine(CGPoint(x: lineXLeft, y: lineYUp), CGPoint(x: lineXRight, y: lineYUp))
    }
    
    func drawRects() {
        drawRect(0)
    }
    
    func drawRect(_ index: Int) {
        let pacManRadiusF = CGFloat(pacManRadius + 4)
        
        let baseX: CGFloat
        var minusToX = index
        while true {
            if minusToX < 5 {
                baseX = CGFloat(minusToX) * perWidth(21.25) + perWidth(7.5)
                break
            } else {
                minusToX -= 5
            }
        }
        
        let baseY: CGFloat
        var row: Double = index / 5
        while true {
            if row % 10 == 0 {
                baseY = CGFloat(row) * perHeigth(10.625)
                break
            }
        }
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: perWidth(7.5) + pacManRadiusF, y: perHeigth(7.5) + pacManRadiusF))
        path.addLine(to: CGPoint(x: perWidth(7.5 + 21.25) - pacManRadiusF, y: perHeigth(7.5) + pacManRadiusF))
        path.addLine(to: CGPoint(x: perWidth(7.5 + 21.25) - pacManRadiusF, y: perHeigth(7.5 + 10.625) - pacManRadiusF))
        path.addLine(to: CGPoint(x: perWidth(7.5) + pacManRadiusF, y: perHeigth(7.5 + 10.625) - pacManRadiusF))
        path.closeSubpath()

        let line = SKShapeNode(path: path)
        line.zPosition = 0
        line.strokeColor = .blue
        line.lineWidth = 2
        gameScene.addChild(line)
    }
    
    func drawLine(_ from: CGPoint, _ to: CGPoint)  {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        
        let line = SKShapeNode(path: path)
        line.zPosition = 0
        line.strokeColor = .blue
        line.lineWidth = 2
        gameScene.addChild(line)
    }
}
