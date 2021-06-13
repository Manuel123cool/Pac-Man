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
        for index in 0..<(4 * 8) {
            drawRect(index)
        }
    }
    
    func drawRect(_ index: Int) {
        let pacManRadiusF = CGFloat(pacManRadius + 4)
        
        var baseX: CGFloat = -1
        var minusToX = index
        while true {
            if minusToX < 4 {
                baseX = CGFloat(minusToX) * perWidth(21.25)
                break
            } else {
                minusToX -= 4
            }
        }
        
        
        let row: Int = (index / 4)
        let baseY: CGFloat = (CGFloat(row) * perHeigth(10.625))
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: baseX + perWidth(7.5) + pacManRadiusF, y: baseY + perHeigth(7.5) + pacManRadiusF))
        path.addLine(to: CGPoint(x: baseX + perWidth(7.5 + 21.25) - pacManRadiusF, y: baseY + perHeigth(7.5) + pacManRadiusF))
        path.addLine(to: CGPoint(x: baseX + perWidth(7.5 + 21.25) - pacManRadiusF, y: baseY + perHeigth(7.5 + 10.625) - pacManRadiusF))
        path.addLine(to: CGPoint(x: baseX + perWidth(7.5) + pacManRadiusF, y: baseY + perHeigth(7.5 + 10.625) - pacManRadiusF))
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
