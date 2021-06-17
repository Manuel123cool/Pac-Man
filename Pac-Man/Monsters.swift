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
    var waiting: TimeInterval
    var startTime: TimeInterval
    
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
    
    mutating func spawnMoveTimeChange() {
        let newDate = Date()
        startTime = newDate.timeIntervalSince1970
        waiting = 5
    }
}

struct Monsters {
    var monsters: [Monster] = []
    let gameScene: SKScene
    let paths: Paths
    let changeValue: Double
    let monsterSpawn: MonsterSpawn
    let pacManRadius: Double
    let outOfSpawnPoint: CGPoint

    init(gameScene: SKScene, pacManRadius: Double, changeValue: Double) {
        self.changeValue = changeValue
        self.gameScene = gameScene
        self.paths = Paths(gameScene: self.gameScene, changeValue: changeValue, forMonsters: true)
        self.pacManRadius = pacManRadius
        self.monsterSpawn = MonsterSpawn(gameScene: gameScene, changeValue: changeValue, pacManRadius: pacManRadius)
        self.outOfSpawnPoint = monsterSpawn.outOfSpawnPoint
        
        addMonsters()
        drawMonsters()
    }
    
    mutating func moveToSpawn(index: Int) {
        monsterSpawn.moveToSpawn(&monsters[index], monsters)
    }
    
    func isSelfColliding(newPos: CGPoint, oldPos: CGPoint) -> Bool {
        let radiusF = CGFloat(pacManRadius)
        for monster in monsters {
            guard monster.pos != oldPos else {
                continue
            }
    
            if Monsters.distanceBetween(point1: newPos, point2: monster.pos) - radiusF * 2 < 0 {
                return true
            }
        }
        return false
    }
    
    mutating func addMonsters() {
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) - (21.25 / CGFloat(2))), y: perHeigth(7.5 + 10.625 * 3 + 10.625 / 2)),
            direction: Direction.right, color: .purple, waiting: 8))
        
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) + (21.25 / CGFloat(2))), y: perHeigth(7.5 + 10.625 * 3 + 10.625 / 2)),
            direction: Direction.left, color: .brown, waiting: 10))
        
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth(7.5 + 21.25 * CGFloat(2)), y: perHeigth(7.5 + 10.625 * 4)),
            direction: Direction.up, color: .darkGray, waiting: 6))
        
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) - (21.25 / CGFloat(2))), y: perHeigth(7.5 + 10.625 * 4 + 10.625 / 2)),
            direction: Direction.right, color: .orange, waiting: 2))
        
        monsters.append(Monster(gameScene: gameScene, monsterRadius: pacManRadius,
            pos: CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) + (21.25 / CGFloat(2))), y: perHeigth(7.5 + 10.625 * 4 + 10.625 / 2)),
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
    
    func checkMove(newPos: CGPoint, currentPos: CGPoint,
                   index: Int, direction:
                        Direction, possibleMoves: inout [(CGPoint, Direction)]) {
        
        if isSelfColliding(newPos: newPos, oldPos: currentPos) {
            return
        }
        
        let checkMoveResult = self.paths.checkMoveMonster(from: currentPos, to: newPos)
        if checkMoveResult {
            possibleMoves.append((newPos, direction))
        }
    }
    
    mutating func moveMonster(_ index: Int, figurePos: CGPoint) {
        let  currentPos = monsters[index].pos
        var possibleMoves: [(CGPoint, Direction)] = []
        
        let changeValue: CGFloat = CGFloat(self.changeValue)
        
        let pos1 = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y + changeValue))
        checkMove(newPos: pos1, currentPos: currentPos,
            index: index, direction: .up, possibleMoves: &possibleMoves)
           
        let pos2 = CGPoint(x: currentPos.x, y: CGFloat(currentPos.y - changeValue))
        checkMove(newPos: pos2, currentPos: currentPos,
            index: index, direction: .down, possibleMoves: &possibleMoves)
            
        let pos3 = CGPoint(x: currentPos.x + changeValue, y: CGFloat(currentPos.y))
        checkMove(newPos: pos3, currentPos: currentPos,
            index: index, direction: .right, possibleMoves: &possibleMoves)

        let pos4 = CGPoint(x: currentPos.x - changeValue, y: CGFloat(currentPos.y))
        checkMove(newPos: pos4, currentPos: currentPos,
            index: index, direction: .left, possibleMoves: &possibleMoves)

        deleteOppositeIfPossible(possibleMoves: &possibleMoves, index: index)
        
        checkDirInSpawn(possibleMoves: &possibleMoves, index: index)

        if possibleMoves.isEmpty {
            monsters[index].changeToOppositeDir()
            return
        }
        
        let nearestIndex = reNearestToPlayer(possibleMoves: possibleMoves, figurePos: figurePos)
        let nextMove = possibleMoves[nearestIndex]
        
        guard checkInSpawn(pos: nextMove.0, index: index) else {
            monsters[index].changeToOppositeDir()
            return
        }
        
        monsters[index].moveTo(nextMove.0)
        monsters[index].changeDir(nextMove.1)
        
        return
    }
    
    func reNearestToPlayer(possibleMoves: [(CGPoint, Direction)], figurePos: CGPoint) -> Int {
        var nearest: (CGFloat, Int) = (gameScene.size.height * 10, 0)
        for (index, possibleMove) in possibleMoves.enumerated() {
            let distance = Monsters.distanceBetween(point1: possibleMove.0, point2: figurePos)
            if distance < nearest.0 {
                nearest.0 = distance
                nearest.1 = index
            }
        }
        return nearest.1
    }
    
    func deleteOppositeIfPossible(possibleMoves: inout [(CGPoint, Direction)], index: Int) {
        guard possibleMoves.count > 1 else {
            return
        }
        for (index1, move) in possibleMoves.enumerated() {
            if monsters[index].direction.opposite() == move.1 {
                possibleMoves.remove(at: index1)
                return
            }
        }
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
            return
        }
        return
    }
    
    mutating func moveMonsters(figurePos: CGPoint,_ makeMonsterBlue: Bool = false) {
        for (index, _) in monsters.enumerated() {
            moveMonster(index, figurePos: figurePos)
            
            if makeMonsterBlue {
                monsters[index].monster.fillColor = .blue
            } else {
                monsters[index].monster.fillColor = monsters[index].color
            }
        }
    }
    
    static func distanceBetween(point1: CGPoint, point2: CGPoint) -> CGFloat {
        
        var smallerX: CGFloat = point1.x
        var biggerX: CGFloat = point2.x
        
        var smallerY: CGFloat = point1.y
        var biggerY: CGFloat = point2.y
        
        if point1.x > point2.x {
            smallerX = point2.x
            biggerX = point1.x
        }
        biggerX -= smallerX
        
        if point1.y > point2.y {
            smallerY = point2.y
            biggerY = point1.y
        }
        biggerY -= smallerY
        
        return (pow(biggerX, 2) + pow(biggerY, 2)).squareRoot()
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
        monsterSpawn.clear()
    }
}




struct MonsterSpawn {
    var pathsMonster: [Path] = []
    let paths: Paths
    let gameScene: SKScene
    let pacManRadius: Double
    var outOfSpawnPoint = CGPoint(x: -1, y: -1)
    var lines: [SKShapeNode] = []
    
    init(gameScene: SKScene, changeValue: Double, pacManRadius: Double) {
        self.gameScene = gameScene
        self.paths = Paths(gameScene: self.gameScene, changeValue: changeValue)
        self.pacManRadius = pacManRadius
        
        outOfSpawnPoint = CGPoint(x: perWidth(7.5 + 21.25 * 2), y: perHeigth(7.5 + 10.625 * 5 - 10.625 / 4))
        draw()
    }
    
    mutating func draw() {
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
    
    private mutating func drawLine(_ from: CGPoint, _ to: CGPoint, orange: Bool = false)  {
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
        lines.append(line)
        gameScene.addChild(lines.last!)
    }
    
    private func perWidth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.width / 100 * percent)
    }
    
    private func perHeigth(_ percent: CGFloat) -> CGFloat {
        return paths.roundToChangeValue(gameScene.size.height / 100 * percent)
    }
    
    func moveToSpawn(_ monster: inout Monster, _ monsters: [Monster]) {
        var spawns: [CGPoint] = []
        spawns.append(CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) - (21.25 / CGFloat(2))), y: perHeigth(7.5 + 10.625 * 4 + 10.625 / 2)))
        spawns.append(CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) + (21.25 / CGFloat(2))), y: perHeigth(7.5 + 10.625 * 4 + 10.625 / 2)))
        spawns.append(CGPoint(x: perWidth(7.5 + 21.25 * CGFloat(2)), y: perHeigth(7.5 + 10.625 * 4)))
        spawns.append(CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) - (21.25 / CGFloat(2))), y: perHeigth(7.5 + 10.625 * 3 + 10.625 / 2)))
        spawns.append(CGPoint(x: perWidth((7.5 + 21.25 * CGFloat(2)) + (21.25 / CGFloat(2))), y: perHeigth(7.5 + 10.625 * 3 + 10.625 / 2)))
        
        spawnLoop: for spawn in spawns {
            for monsterLoop in monsters {
                if Monsters.distanceBetween(point1: monsterLoop.pos, point2: spawn) - CGFloat(pacManRadius) * 2 < 0 {
                    continue spawnLoop
                }
            }
            monster.moveTo(spawn)
            monster.spawnMoveTimeChange()
            monster.outOfSpawn = false
            return
        }
    }
    
    func clear() {
        for (index, _) in lines.enumerated() {
            lines[index].removeFromParent()
        }
    }
}
