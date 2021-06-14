import SpriteKit
import GameplayKit

struct Monster {
    var direction: Direction = .left
    var pos: CGPoint

    func draw() {
        
    }
}

struct Monsters {
    var monsters: [Monster] = []
    let gameScene: SKScene
    let paths: Paths
    let changeValue: Double = 0.5
    let monsterSpawn: MonsterSpawn
    let pacManRadius: Double
    
    init(gameScene: SKScene, pacManRadius: Double) {
        self.gameScene = gameScene
        self.paths = Paths(gameScene: self.gameScene, changeValue: changeValue)
        self.pacManRadius = pacManRadius
        self.monsterSpawn = MonsterSpawn(gameScene: gameScene, changeValue: changeValue, pacManRadius: pacManRadius)
        
    }
}

struct MonsterSpawn {
    var pathsMonster: [Path] = []
    let paths: Paths
    let gameScene: SKScene
    let pacManRadius: Double

    init(gameScene: SKScene, changeValue: Double, pacManRadius: Double) {
        self.gameScene = gameScene
        self.paths = Paths(gameScene: self.gameScene, changeValue: changeValue)
        self.pacManRadius = pacManRadius
        
        draw()
    }
    
    func draw() {
        let pacManRadiusF = CGFloat(pacManRadius + 4)
        //10.625 21.25
        
        drawLine(CGPoint(x: perWidth(7.5 + 21.25) + pacManRadiusF, y: perHeigth(7.5 + 10.625 * 3) + pacManRadiusF),
            CGPoint(x: perWidth(7.5 + 21.25 * 3) - pacManRadiusF, y: perHeigth(7.5 + 10.625 * 3) + pacManRadiusF))
        
        drawLine(CGPoint(x: perWidth(7.5 + 21.25) + pacManRadiusF, y: perHeigth(7.5 + 10.625 * 3) + pacManRadiusF),
            CGPoint(x: perWidth(7.5 + 21.25) + pacManRadiusF, y: perHeigth(7.5 + 10.625 * 5) - pacManRadiusF))
        
        drawLine(CGPoint(x: perWidth(7.5 + 21.25 * 3) - pacManRadiusF, y: perHeigth(7.5 + 10.625 * 3) + pacManRadiusF),
            CGPoint(x: perWidth(7.5 + 21.25 * 3) - pacManRadiusF, y: perHeigth(7.5 + 10.625 * 5) - pacManRadiusF))
        
        drawLine(CGPoint(x: perWidth(7.5 + 21.25) + pacManRadiusF, y: perHeigth(7.5 + 10.625 * 5) - pacManRadiusF),
            CGPoint(x: perWidth(7.5 + 21.25 * 2) - pacManRadiusF, y: perHeigth(7.5 + 10.625 * 5) - pacManRadiusF))
        
        drawLine(CGPoint(x: perWidth(7.5 + 21.25 * 2) + pacManRadiusF, y: perHeigth(7.5 + 10.625 * 5) - pacManRadiusF),
            CGPoint(x: perWidth(7.5 + 21.25 * 3) - pacManRadiusF, y: perHeigth(7.5 + 10.625 * 5) - pacManRadiusF))
        
        drawLine(CGPoint(x: perWidth(7.5 + 21.25 * 2) + pacManRadiusF, y: perHeigth(7.5 + 10.625 * 5) - pacManRadiusF),
            CGPoint(x: perWidth(7.5 + 21.25 * 3) - pacManRadiusF, y: perHeigth(7.5 + 10.625 * 5) - pacManRadiusF))
    }
    
    private func drawLine(_ from: CGPoint, _ to: CGPoint, orange: Bool = false)  {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        
        let line = SKShapeNode(path: path)
        line.zPosition = 0
        line.strokeColor = .blue
        if orange {
            line.strokeColor = .orange
        }
        line.lineWidth = 2
        gameScene.addChild(line)
    }
    
    private func perWidth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.width / 100 * percent)
    }
    
    private func perHeigth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.height / 100 * percent)
    }
}
