import SpriteKit
import GameplayKit

struct Monster {
    var direction: Direction
    var pos: CGPoint
    let monsterRadius: Double
    var gameScene: SKScene
    var monster: SKShapeNode = SKShapeNode()
    
    init(gameScene: SKScene, monsterRadius: Double, pos: CGPoint) {
        self.gameScene = gameScene
        self.monsterRadius = monsterRadius
        self.pos = pos
        self.direction = .left
    }
    
    mutating func draw(_ drawGreen: Bool = false) {
        let monserRadiusF = CGFloat(monsterRadius - 3)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: pos.x - monserRadiusF, y: pos.y - monserRadiusF))
        path.addLine(to: CGPoint(x: pos.x - monserRadiusF, y: pos.y))
        path.addCurve(to: CGPoint(x: pos.x + monserRadiusF, y: pos.y),
                      control1: CGPoint(x: pos.x - 4 - monserRadiusF, y: pos.y + monserRadiusF + 10),
                      control2: CGPoint(x: pos.x + 4 + monserRadiusF, y: pos.y + monserRadiusF + 10)
        )
        path.addLine(to: CGPoint(x: pos.x + monserRadiusF, y: pos.y - monserRadiusF))
        
        path.addLine(to: CGPoint(x: pos.x + (monserRadiusF - monserRadiusF / 4), y: pos.y - monserRadiusF - 4))
        path.addLine(to: CGPoint(x: pos.x + (monserRadiusF - monserRadiusF / 2), y: pos.y - monserRadiusF ))
        path.addLine(to: CGPoint(x: pos.x + monserRadiusF / 4, y: pos.y - monserRadiusF - 4))
        path.addLine(to: CGPoint(x: pos.x, y: pos.y - monserRadiusF))
        path.addLine(to: CGPoint(x: pos.x - monserRadiusF / 4, y: pos.y - monserRadiusF - 4))
        path.addLine(to: CGPoint(x: pos.x - monserRadiusF / 2, y: pos.y - monserRadiusF))
        path.addLine(to: CGPoint(x: pos.x - (monserRadiusF - monserRadiusF / 4), y: pos.y - monserRadiusF - 4))
        path.closeSubpath()

        self.monster = SKShapeNode(path: path)
        monster.zPosition = 2
        monster.strokeColor = .clear
        monster.fillColor = .red
        if drawGreen {
            monster.fillColor = .green

        }
        gameScene.addChild(monster)
    }
    
    mutating func moveTo(_ to: CGPoint) {
        pos = to
        monster.removeFromParent()
        draw()
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
        self.paths = Paths(gameScene: self.gameScene, changeValue: changeValue, forMonsters: true)
        self.pacManRadius = pacManRadius
        self.monsterSpawn = MonsterSpawn(gameScene: gameScene, changeValue: changeValue, pacManRadius: pacManRadius)
        
        addMonsters()
        drawMonsters()
    }
    
    mutating func addMonsters() {
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) - (21.25 / CGFloat(4))), y: perHeigth(7.5 + 10.625 * 3 + 10.625 / 2))))
    }
    
    mutating func drawMonsters() {
        for (index, _) in monsters.enumerated() {
            monsters[index].draw()
        }
    }
    
    private func perWidth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.width / 100 * percent)
    }
    
    private func perHeigth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.height / 100 * percent)
    }
    
    mutating func moveMonster(_ index: Int) {
        let  currentPos = monsters[index].pos
        func checkMove(_ pos: CGPoint) {
            let checkMoveResult = self.paths.checkMove(from: currentPos, to: pos)
            if checkMoveResult.valid {
                monsters[index].moveTo(pos)
            }
        }
        
        let changeValue: CGFloat = CGFloat(self.changeValue)
        switch monsters[index].direction {
            case .up:
                let pos = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y + changeValue))
                checkMove(pos)
            case .down:
                let pos = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y - changeValue))
                checkMove(pos)
            case .right:
                let pos = CGPoint(x: currentPos.x + changeValue, y: CGFloat(currentPos.y))
                checkMove(pos)
            case .left:
                let pos = CGPoint(x: currentPos.x - changeValue, y: CGFloat(currentPos.y))
                checkMove(pos)
        }
    }
    
    mutating func moveMonsters() {
        for (index, _) in monsters.enumerated() {
            moveMonster(index)
        }
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
        
        drawLine(CGPoint(x: perWidth(7.5 + 21.25 * 2) - pacManRadiusF, y: perHeigth(7.5 + 10.625 * 5) - pacManRadiusF),
            CGPoint(x: perWidth(7.5 + 21.25 * 2) + pacManRadiusF, y: perHeigth(7.5 + 10.625 * 5) - pacManRadiusF), orange: true)
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
