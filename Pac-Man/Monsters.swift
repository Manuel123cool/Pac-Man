import SpriteKit
import GameplayKit

struct Monster {
    var direction: Direction
    var pos: CGPoint
    let monsterRadius: Double
    var gameScene: SKScene
    var monster: SKShapeNode = SKShapeNode()
    var outOfSpawn = false
    init(gameScene: SKScene, monsterRadius: Double, pos: CGPoint, direction: Direction) {
        self.gameScene = gameScene
        self.monsterRadius = monsterRadius
        self.pos = pos
        self.direction = direction
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
    
    mutating func changeDir(_ direction: Direction) {
        self.direction = direction
    }
    
    mutating func changeToOppositeDir() {
        switch direction {
            case .down:
                changeDir(.up)
            case .up:
                changeDir(.down)
            case .right:
                changeDir(.left)
            case .left:
                changeDir(.right)
        }
    }
}

struct Monsters {
    var monsters: [Monster] = []
    let gameScene: SKScene
    let paths: Paths
    let changeValue: Double = 0.5
    let monsterSpawn: MonsterSpawn
    let pacManRadius: Double
    let outOfSpawnPoint: CGPoint

    init(gameScene: SKScene, pacManRadius: Double) {
        self.gameScene = gameScene
        self.paths = Paths(gameScene: self.gameScene, changeValue: changeValue, forMonsters: true)
        self.pacManRadius = pacManRadius
        self.monsterSpawn = MonsterSpawn(gameScene: gameScene, changeValue: changeValue, pacManRadius: pacManRadius)
        self.outOfSpawnPoint = monsterSpawn.outOfSpawnPoint
        
        addMonsters()
        drawMonsters()
    }
    
    mutating func addMonsters() {
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) - (21.25 / CGFloat(4))), y: perHeigth(7.5 + 10.625 * 3 + 10.625 / 2)),
                direction: Direction.right))
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
    
    mutating func moveMonster(_ index: Int) -> Bool {
        let  currentPos = monsters[index].pos
        var possibleMoves: [(CGPoint, Direction)] = []
        
        func checkMove(_ pos: CGPoint, _ direction: Direction) {
            switch direction {
                case .down:
                    if monsters[index].direction == .up {
                        return
                    }
                case .up:
                    if monsters[index].direction == .down {
                        return
                    }
                case .right:
                    if monsters[index].direction == .left {
                        return
                    }
                case .left:
                    if monsters[index].direction == .right {
                        return
                    }
            }
            let checkMoveResult = self.paths.checkMoveMonster(from: currentPos, to: pos)
            if checkMoveResult {
                possibleMoves.append((pos, direction))
            }
        }
        
        let changeValue: CGFloat = CGFloat(self.changeValue)
        
        
        let pos1 = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y + changeValue))
        checkMove(pos1, .up)
           
        let pos2 = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y - changeValue))
        checkMove(pos2, .down)
            
        let pos3 = CGPoint(x: currentPos.x + changeValue, y: CGFloat(currentPos.y))
        checkMove(pos3, .right)
            
        let pos4 = CGPoint(x: currentPos.x - changeValue, y: CGFloat(currentPos.y))
        checkMove(pos4, .left)
        
        if possibleMoves.isEmpty {
            return false
        }
        
        checkDirInSpawn(possibleMoves: &possibleMoves, index: index)
        
        let randomIndex = Int.random(in: 0..<possibleMoves.count)
        
        guard checkInSpawn(pos: possibleMoves[randomIndex].0, index: index) else {
            return false
        }
        
        monsters[index].moveTo(possibleMoves[randomIndex].0)
        monsters[index].changeDir(possibleMoves[randomIndex].1)
        
        
        return true
    }
    
    mutating func checkInSpawn(pos: CGPoint, index: Int) -> Bool {
        if pos == outOfSpawnPoint && !monsters[index].outOfSpawn{
            monsters[index].outOfSpawn = true
            return true
        } else if pos == outOfSpawnPoint {
            return false
        }
        return true
    }
    
    private func checkDirInSpawn(possibleMoves: inout [(CGPoint, Direction)], index: Int) {
        if !monsters[index].outOfSpawn {
            var rightDir = false
            var rightDirIndex = -1
            var upDir = false
            var leftDir = false
            var leftDirIndex = -1
            for (index, move) in possibleMoves.enumerated() {
                if move.1 == .up {
                    upDir = true
                } else if move.1 == .right {
                    rightDir = true
                    rightDirIndex = index
                } else if move.1 == .left {
                    leftDir = true
                    leftDirIndex = index
                }
            }
            if rightDir && upDir {
                possibleMoves.remove(at: rightDirIndex)
                if leftDir {
                    possibleMoves.remove(at: leftDirIndex - 1)
                }
            }
        }
    }
    
    mutating func moveMonsters() {
        for (index, _) in monsters.enumerated() {
            if !moveMonster(index) {
                monsters[index].changeToOppositeDir()
            }
        }
    }
}

struct MonsterSpawn {
    var pathsMonster: [Path] = []
    let paths: Paths
    let gameScene: SKScene
    let pacManRadius: Double
    var outOfSpawnPoint = CGPoint(x: -1, y: -1)

    init(gameScene: SKScene, changeValue: Double, pacManRadius: Double) {
        self.gameScene = gameScene
        self.paths = Paths(gameScene: self.gameScene, changeValue: changeValue)
        self.pacManRadius = pacManRadius
        
        outOfSpawnPoint = CGPoint(x: perWidth(7.5 + 21.25 * 2), y: perHeigth(7.5 + 10.625 * 5) - CGFloat(pacManRadius + 4))
        draw()
    }
    
    func draw() {
        let pacManRadiusF = CGFloat(pacManRadius + 4)
        
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
