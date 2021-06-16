import SpriteKit
import GameplayKit

struct GameLogic {
    let radius: Double
    var lives = 1
    var lost = false
    var pointsFromPoints = 0
    var pointsLabel = SKLabelNode()
    let gameScene: SKScene
    
    var overAllPoints: Int {
        pointsFromPoints
    }
    
    init(radius: Double, gameScene: SKScene) {
        self.radius = radius
        self.gameScene = gameScene
        initLabel()
    }
    
    mutating func update(figurePos: CGPoint, monsterPositons: [CGPoint], points: inout Points) {
        pointsFromPoints = points.update(figurePos: figurePos)
        printPoints()
        if checkBeeingEaten(figurePos: figurePos, monsterPositons: monsterPositons) {
            loosesLive()
        }
    }
    
    mutating func checkBeeingEaten(figurePos: CGPoint, monsterPositons: [CGPoint]) -> Bool {
        
        let radiusF = CGFloat(radius)
        for monsterPos in monsterPositons {
            if figurePos.y == monsterPos.y {
                if figurePos.x < monsterPos.x {
                    if figurePos.x + radiusF > monsterPos.x - radiusF {
                        return true
                    }
                } else {
                    if figurePos.x - radiusF < monsterPos.x + radiusF {
                        return true
                    }
                }
            } else if figurePos.x == monsterPos.x {
                if figurePos.y < monsterPos.y {
                    if figurePos.y + radiusF > monsterPos.y - radiusF {
                        return true
                    }
                } else {
                    if figurePos.y - radiusF < monsterPos.y + radiusF {
                        return true
                    }
                }
            }
        }
        return false
    }

    
    mutating func initLabel() {
        pointsLabel = SKLabelNode(fontNamed: "Chalkduster")
        pointsLabel.text = "Points: 0"
        pointsLabel.fontSize = 20
        pointsLabel.fontColor = SKColor.green
        pointsLabel.position = CGPoint(x: 75, y: 20)
        
        gameScene.addChild(pointsLabel)
    }
    
    private func printPoints() {
        pointsLabel.text = "Points: \(overAllPoints)"
    }
    
    mutating func loosesLive() {
        lives -= 1
        if lives == 0 {
            lost = true
        }
    }
    
    mutating func checkLost() -> Bool {
        if lost {
            lost = false
            lives = 1
            pointsFromPoints = 0
            return true
        }
        return false
    }
}
