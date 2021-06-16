import SpriteKit
import GameplayKit

extension CGPoint {
    func opposite(changeValue: CGFloat, direction: Direction) -> CGPoint {
        switch direction {
            case .down:
                return CGPoint(x: self.x, y: self.y - changeValue)
            case .up:
                return CGPoint(x: self.x, y: self.y + changeValue)
            case .right:
                return CGPoint(x: self.x - changeValue, y: self.y)
            case .left:
                return CGPoint(x: self.x + changeValue, y: self.y)
        }
    }
}

struct Monster {
    var direction: Direction
    var pos: CGPoint
    let monsterRadius: Double
    var gameScene: SKScene
    var monster: SKShapeNode = SKShapeNode()
    var outOfSpawn = false
    let color: SKColor
    let waiting: TimeInterval
    let startTime: TimeInterval
    var collissionOccurred = false
    var afterCollisonCount = 0
    
    init(gameScene: SKScene, monsterRadius: Double, pos: CGPoint, direction: Direction, color: SKColor, waiting: TimeInterval) {
        self.gameScene = gameScene
        self.monsterRadius = monsterRadius
        self.pos = pos
        self.direction = direction
        self.color = color
        self.waiting = waiting
        let newDate = Date()
        startTime = newDate.timeIntervalSince1970
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
        monster.fillColor = color
        if drawGreen {
            monster.fillColor = .green
        }
        gameScene.addChild(monster)
    }
    
    private func checkTime() -> Bool {
        let currentDate = Date()
        if currentDate.timeIntervalSince1970 > startTime + waiting {
            return true
        }
        return false
    }
    
    mutating func moveTo(_ to: CGPoint) {
        guard checkTime() else {
            return
        }
        pos = to
        monster.removeFromParent()
        draw()
    }
    
    mutating func changeDir(_ direction: Direction) {
        self.direction = direction
    }
    
    mutating func changeToOppositeDir() {
        changeDir(direction.opposite())
    }
    
    mutating func chackAfterCollison() {
        if collissionOccurred {
            afterCollisonCount += 1
            if afterCollisonCount > 10 {
                collissionOccurred = false
                afterCollisonCount = 0
            }
        }
    }
}

struct Monsters {
    var monsters: [Monster] = []
    let gameScene: SKScene
    let paths: Paths
    let changeValue: Double = 1
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
    
    
    func isSelfColliding(newPos: CGPoint, oldPos: CGPoint) -> Bool {
        let radiusF = CGFloat(pacManRadius)
        for monster in monsters {
            guard monster.pos != oldPos else {
                continue
            }
            var x1: CGFloat = monster.pos.x
            var x2: CGFloat = newPos.x
            
            var y1: CGFloat = monster.pos.y
            var y2: CGFloat = newPos.y
            
            if monster.pos.x > newPos.x {
                x1 = newPos.x
                x2 = monster.pos.x
            }
            x2 -= x1
            
            if monster.pos.y > newPos.y {
                y1 = newPos.y
                y2 = monster.pos.y
            }
            y2 -= y1
            
            let betweenPoins = (pow(x2, 2) + pow(y2, 2)).squareRoot()
            if betweenPoins - radiusF * 2 < 0 {
                return true
            }
        }
        return false
    }
    
    mutating func addMonsters() {
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) - (21.25 / CGFloat(4))), y: perHeigth(7.5 + 10.625 * 3 + 10.625 / 2)),
            direction: Direction.right, color: .purple, waiting: 8))
        
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) + (21.25 / CGFloat(4))), y: perHeigth(7.5 + 10.625 * 3 + 10.625 / 2)),
            direction: Direction.left, color: .brown, waiting: 10))
        
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth(7.5 + 21.25 * CGFloat(2)), y: perHeigth(7.5 + 10.625 * 4)),
            direction: Direction.up, color: .darkGray, waiting: 6))
        
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) - (21.25 / CGFloat(4))), y: perHeigth(7.5 + 10.625 * 4 + 10.625 / 2)),
            direction: Direction.right, color: .orange, waiting: 2))
        
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) + (21.25 / CGFloat(4))), y: perHeigth(7.5 + 10.625 * 4 + 10.625 / 2)),
            direction: Direction.left, color: .gray, waiting: 4))
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
        monsters[index].chackAfterCollison()
        
        let  currentPos = monsters[index].pos
        var possibleMoves: [(CGPoint, Direction)] = []
        var collosionOccurred = false
        func checkMove(_ pos: CGPoint, _ direction: Direction) {
            if direction == monsters[index].direction.opposite() {
                return
            }
            
            let checkMoveResult = self.paths.checkMoveMonster(from: currentPos, to: pos)
            if checkMoveResult {
                if isSelfColliding(newPos: pos, oldPos: currentPos) && !monsters[index].collissionOccurred {
                    monsters[index].moveTo(pos.opposite(changeValue: CGFloat(changeValue),
                        direction: direction.opposite()))
                    monsters[index].changeToOppositeDir()
                    collosionOccurred = true
                    monsters[index].collissionOccurred = true
                    return
                }
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
        
        if collosionOccurred {
            return true
        }
        
        checkDirInSpawn(possibleMoves: &possibleMoves, index: index)
        
        if possibleMoves.isEmpty {
            return false
        }
        
        let randomIndex = Int.random(in: 0..<possibleMoves.count)
        
        guard checkInSpawn(pos: possibleMoves[randomIndex].0, index: index) else {
            return false
        }
        
        monsters[index].moveTo(possibleMoves[randomIndex].0)
        monsters[index].changeDir(possibleMoves[randomIndex].1)
        
        return true
    }
    
    mutating func checkInSpawn(pos: CGPoint, index: Int) -> Bool {
        if pos == outOfSpawnPoint && !monsters[index].outOfSpawn {
            monsters[index].outOfSpawn = true
            return true
        } else if pos == outOfSpawnPoint {
            return false
        }
        return true
    }
    
    private func checkDirInSpawn(possibleMoves: inout [(CGPoint, Direction)], index: Int) {
        guard !possibleMoves.isEmpty else {
            return
        }
        
        if !monsters[index].outOfSpawn {
            var yesDelete = false
            if possibleMoves[0].1 == .up {
                yesDelete = true
            }
            
            var minusIndex = 0
            for (index, move) in possibleMoves.enumerated() {
                if move.1 == .right && yesDelete{
                    possibleMoves.remove(at: index - minusIndex)
                    minusIndex += 1
                } else if move.1 == .left && yesDelete {
                    possibleMoves.remove(at: index  - minusIndex)
                } else if move.1 == .down {
                    possibleMoves.remove(at: index - minusIndex)
                    minusIndex += 1
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
    
    func rePositions() -> [CGPoint] {
        var positions: [CGPoint] = []
        for monster in monsters {
            positions.append(monster.pos)
        }
        return positions
    }
    
    func clear() {
        for (index, _) in monsters.enumerated() {
            monsters[index].monster.removeFromParent()
                
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
        
        outOfSpawnPoint = CGPoint(x: perWidth(7.5 + 21.25 * 2), y: perHeigth(7.5 + 10.625 * 5 - 10.625 / 4))
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
