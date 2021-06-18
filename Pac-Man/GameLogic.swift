import SpriteKit
import GameplayKit

struct GameLogic {
    let radius: Double
    var lives = 2
    var lostLive = false
    var lost = false
    var won = false
    var pointsNum = 0
    var pointsInCurrentLive = 0
    
    var pointsLabel = SKLabelNode()
    var levelLabel = SKLabelNode()
    var livesLabel = SKLabelNode()
    var killerPointNodes: [SKShapeNode] = []
    var killerPointStatus: (killerMode: Bool, timeStarted: TimeInterval) = (killerMode: false, timeStarted: 0.0)
    let gameScene: SKScene
    var changeValue: Double = 1.0
    var level = 1
    
    init(radius: Double, gameScene: SKScene) {
        self.radius = radius
        self.gameScene = gameScene
        initLabels()
        drawKillerPoints()
    }
    
    mutating func update(figurePos: CGPoint, points: inout Points, monsters: inout Monsters) {
        let monsterPositons = monsters.rePositions()
        let pointsUpdateResult = points.update(figurePos: figurePos)
        pointsNum += pointsUpdateResult.0
        pointsInCurrentLive += pointsUpdateResult.0
        if pointsUpdateResult.1 {
            hasWon()
            return
        }
        printPoints()
        checkKillerMode(figurePos: figurePos)
        
        let isEaten = checkBeeingEaten(figurePos: figurePos, monsterPositons: monsterPositons)
        if isEaten.0 && !killerPointStatus.killerMode {
            loosesLive()
            points.eaten = 0
        } else if isEaten.0 {
            monsters.moveToSpawn(index: isEaten.1)
            pointsNum += 20
            pointsInCurrentLive += 20
        }
    }
    
    mutating func hasWon() {
        level += 1
        changeValue *= 1.5
        printLevel()
        won = true
    }
    
    func checkBeeingEaten(figurePos: CGPoint, monsterPositons: [CGPoint], killerPoint: Bool = false) -> (Bool, Int) {
        let radius1 = CGFloat(radius)
        var radius2 = radius1
        if killerPoint {
            radius2 = 5
        }
        
        for (index, monsterPos) in monsterPositons.enumerated() {
            if Monsters.distanceBetween(point1: monsterPos, point2: figurePos) - (radius1 + radius2) < 0 {
                return (true, index)
            }
        }
        return (false, -1)
    }

    
    mutating func initLabels() {
        pointsLabel = SKLabelNode(fontNamed: "Chalkduster")
        pointsLabel.text = "Points: 0"
        pointsLabel.fontSize = 20
        pointsLabel.fontColor = SKColor.green
        pointsLabel.position = CGPoint(x: 75, y: 20)
        
        gameScene.addChild(pointsLabel)
        
        levelLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelLabel.text = "Level: 1"
        levelLabel.fontSize = 20
        levelLabel.fontColor = SKColor.green
        levelLabel.position = CGPoint(x: 200, y: 20)
        
        gameScene.addChild(levelLabel)
        
        livesLabel = SKLabelNode(fontNamed: "Chalkduster")
        livesLabel.text = "Lives: 2"
        livesLabel.fontSize = 20
        livesLabel.fontColor = SKColor.green
        livesLabel.position = CGPoint(x: 325, y: 20)
        
        gameScene.addChild(livesLabel)
    }
    
    private func printPoints() {
        pointsLabel.text = "Points: \(pointsNum)"
    }
    
    private func printLevel() {
        levelLabel.text = "Level: \(level)"
    }
    
    private func printLives() {
        livesLabel.text = "Lives: \(lives)"
    }
    
    mutating func loosesLive() {
        pointsNum -= pointsInCurrentLive
        pointsInCurrentLive = 0
        lives -= 1
        lostLive = true
        printLives()
        drawKillerPoints()
        if lives == 0 {
            lost = true
            lostLive = false
        }
    }
    
    mutating func drawKillerPoints() {
        if !killerPointNodes.isEmpty {
            for _ in killerPointNodes {
                killerPointNodes[0].removeFromParent()
                killerPointNodes.remove(at: 0)
            }
        }
        drawKillerPoint(pos: CGPoint(x: perWidth(7.5), y: perHeigth(7.5)))
        drawKillerPoint(pos: CGPoint(x: perWidth(7.5 + 21.25 * 4), y: perHeigth(7.5)))
        drawKillerPoint(pos: CGPoint(x: perWidth(7.5), y: perHeigth(7.5 + 10.625 * 8)))
        drawKillerPoint(pos: CGPoint(x: perWidth(7.5 + 21.25 * 4), y: perHeigth(7.5 + 10.625 * 8)))
    }
    
    mutating func checkKillerMode(figurePos: CGPoint) {
        let testDate = Date()
        if killerPointStatus.killerMode &&
                testDate.timeIntervalSince1970 - killerPointStatus.timeStarted > 6 {
            killerPointStatus.killerMode = false
        } else if killerPointStatus.killerMode {
            return
        }
        
        var killerPointPos: [CGPoint] = []
        for killerPoint in killerPointNodes {
            killerPointPos.append(killerPoint.position)
        }
        
        let isEaten = checkBeeingEaten(figurePos: figurePos, monsterPositons: killerPointPos, killerPoint: true)
        if isEaten.0 {
            let newDate = Date()
            killerPointStatus.timeStarted = newDate.timeIntervalSince1970
            killerPointStatus.killerMode = true
            killerPointNodes[isEaten.1].position = CGPoint(x: -1, y: -1)
        }
    }
    
    private func perWidth(_ percent: CGFloat) -> CGFloat {
        return gameScene.size.width / 100 * percent
    }
    
    private func perHeigth(_ percent: CGFloat) -> CGFloat {
        return gameScene.size.height / 100 * percent
    }
    
    mutating func drawKillerPoint(pos: CGPoint) {
        let radius: CGFloat = 5.0
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = .blue
        circle.position = CGPoint(x: pos.x, y: pos.y)
        circle.strokeColor = .clear
        circle.zPosition = 0.6
        killerPointNodes.append(circle)
        gameScene.addChild(killerPointNodes.last!)
    }
    
    mutating func checkLostOrWon() -> Bool {
        if lost {
            lost = false
            won = false
            lives = 2
            level = 1
            changeValue = 1
            pointsNum = 0
            printLives()
            return true
        } else if won {
            won = false
            lives = 2
            printLives()
            return true
        } else if lostLive {
            lostLive = false
            return true
        }
        return false
    }
}
