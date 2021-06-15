import SpriteKit
import GameplayKit

struct GameLogic {
    let radius: Double
    var lives = 1
    var lost = false
    
    mutating func update(figurePos: CGPoint, monsterPositons: [CGPoint]) {
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
                    if figurePos.x - radiusF > monsterPos.x + radiusF {
                        return true
                    }
                }
            } else if figurePos.x == monsterPos.x {
                if figurePos.y < monsterPos.y {
                    if figurePos.y + radiusF > monsterPos.y - radiusF {
                        return true
                    }
                } else {
                    if figurePos.y - radiusF > monsterPos.y + radiusF {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private mutating func loosesLive() {
        lives -= 1
        if lives == 0 {
            lost = true
        }
    }
    
    func checkLost() -> Bool {
        if lost {
            return true
        }
        return false
    }
}
