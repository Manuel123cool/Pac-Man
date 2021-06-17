import SpriteKit
import GameplayKit

struct GameLogic {
    let radius: Double
    var lives = 2
    var lostLive = false
    var lost = false
    var won = false
    var pointsNum = 0
    var pointsFromCurrentLevel = 0
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
        pointsNum = pointsUpdateResult.0
        pointsFromCurrentLevel = pointsUpdateResult.0
        if pointsUpdateResult.1 {
            hasWon()
            return
        }
        printPoints()
        checkKillerMode(figurePos: figurePos)
        
        let isEaten = checkBeeingEaten(figurePos: figurePos, monsterPositons: monsterPositons)
        if isEaten.0 && !killerPointStatus.killerMode {
            loosesLive()
        } else if isEaten.0 {
            monsters.moveToSpawn(index: isEaten.1)
            pointsNum += 20
        }
    }
    
    mutating func hasWon() {
        level += 1
        changeValue *= 1.5
        printLevel()
        won = true
    }
    
    mutating func checkBeeingEaten(figurePos: CGPoint, monsterPositons: [CGPoint], killerPoint: Bool = false) -> (Bool, Int) {
        let radius1 = CGFloat(radius)
        for (index, monsterPos) in monsterPositons.enumerated() {
            var x1: CGFloat = monsterPos.x
            var x2: CGFloat = figurePos.x
            
            var y1: CGFloat = monsterPos.y
            var y2: CGFloat = figurePos.y
            if monsterPos.x > figurePos.x {
                x1 = figurePos.x
                x2 = monsterPos.x
            }
            x2 -= x1
            
            if monsterPos.y > figurePos.y {
                y1 = figurePos.y
                y2 = monsterPos.y
            }
            y2 -= y1
            
            var radius2 = radius1
            if killerPoint {
                radius2 = CGFloat(5)
            }
            
            let betweenPoins = (pow(x2, 2) + pow(y2, 2)).squareRoot()
            if betweenPoins - (radius1 + radius2) < 0 {
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
        lives -= 1
        lostLive = true
        pointsFromCurrentLevel = 0
        printLives()
        drawKillerPoints()
        if lives == 0 {
            lost = true
            lostLive = false
        }
    }
    
    mutating func drawKillerPoints() {
        if !killerPointNodes.isEmpty {
            for (index, _) in killerPointNodes.enumerated() {
                killerPointNodes[index].removeFromParent()
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
            pointsFromCurrentLevel = 0
            printLives()
            return true
        } else if lostLive {
            pointsNum -= pointsFromCurrentLevel
            lostLive = false
            return true
        }
        return false
    }
}
