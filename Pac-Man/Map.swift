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
    
    private func perWidth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.width / 100 * percent)
    }
    
    private func perHeigth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.height / 100 * percent)
    }
    
    private func drawSurroundings() {
        let pacManRadiusF = CGFloat(pacManRadius + 4)
        let lineXLeft = perWidth(7.5) - pacManRadiusF
        let lineXRight = gameScene.size.width - lineXLeft
        let lineYDown = perHeigth(7.5) - pacManRadiusF
        let lineYUp = gameScene.size.height - lineYDown
        
        let xMiddleRight = perWidth(7.5  + 21.25 * 2) + pacManRadiusF
        let xMiddleLeft = perWidth(7.5  + 21.25 * 2) - pacManRadiusF
        
        drawLine(CGPoint(x: lineXRight, y: lineYDown), CGPoint(x: lineXRight, y: lineYUp))
        drawLine(CGPoint(x: lineXLeft, y: lineYDown), CGPoint(x: lineXLeft, y: lineYUp))
        
        drawLine(CGPoint(x: lineXLeft, y: lineYDown), CGPoint(x: xMiddleLeft, y: lineYDown))
        drawLine(CGPoint(x: xMiddleRight, y: lineYDown), CGPoint(x: lineXRight, y: lineYDown))
        
        drawLine(CGPoint(x: lineXLeft, y: lineYUp), CGPoint(x: xMiddleLeft, y: lineYUp))
        drawLine(CGPoint(x: xMiddleRight, y: lineYUp), CGPoint(x: lineXRight, y: lineYUp))
    }
    
    private func drawRects() {
        for index in 0..<(4 * 8) {
            if index == 13 || index == 14 || index == 17 || index == 18 {
                continue
            }
            drawRect(index)
        }
    }
    
    private func drawRect(_ index: Int) {
        let pacManRadiusF = CGFloat(pacManRadius + 4)
        
        let column: CGFloat = CGFloat((index + 4) % 4)
        let baseX: CGFloat = (CGFloat(column) * perWidth(21.25))
        
        let row: Int = (index / 4)
        let baseY: CGFloat = (CGFloat(row) * perHeigth(10.625))
        
        var bottomHight = baseY + perHeigth(7.5) + pacManRadiusF
        var topHight = baseY + perHeigth(7.5 + 10.625) - pacManRadiusF
        
        switch index {
        case 1, 2:
            bottomHight = perHeigth(7.5) - pacManRadiusF
        case 29, 30:
            topHight = gameScene.size.height - (perHeigth(7.5) - pacManRadiusF)
        default:
            break
        }
        let path = CGMutablePath()
        path.move(to: CGPoint(x: baseX + perWidth(7.5) + pacManRadiusF, y: bottomHight))
        path.addLine(to: CGPoint(x: baseX + perWidth(7.5 + 21.25) - pacManRadiusF, y: bottomHight))
        path.addLine(to: CGPoint(x: baseX + perWidth(7.5 + 21.25) - pacManRadiusF, y: topHight))
        path.addLine(to: CGPoint(x: baseX + perWidth(7.5) + pacManRadiusF, y: topHight))
        path.closeSubpath()

        let line = SKShapeNode(path: path)
        line.zPosition = 0
        line.strokeColor = .blue
        line.lineWidth = 2
        gameScene.addChild(line)
    }
    
    private func drawLine(_ from: CGPoint, _ to: CGPoint)  {
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
