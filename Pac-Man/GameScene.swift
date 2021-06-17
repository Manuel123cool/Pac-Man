import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var figure: Figure?
    var monsters: Monsters?
    var points: Points?
    var gameLogic: GameLogic?
    override func didMove(to view: SKView) {
        initFunc()
        gameLogic = GameLogic(radius: figure!.pacManRadius, gameScene: self as SKScene)
        
        backgroundColor = SKColor.black
        
        addGesturRecognizer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*for touch in touches {
        }
 */
    }
    
    override func update(_ currentTime: TimeInterval) {
        figure!.move(figure!.direction)
        monsters!.moveMonsters(gameLogic!.killerPointStatus.killerMode)
        gameLogic!.update(figurePos: figure!.pos, points: &points!, monsters: &monsters!)
        if gameLogic!.checkLostOrWon() {
            initFunc(true)
        }
    }
    
    private func addGesturRecognizer() {
        let gesturesDirections: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
        for gestureDirection in gesturesDirections {
            let gesturesRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            gesturesRecognizer.direction = gestureDirection
            self.view!.addGestureRecognizer(gesturesRecognizer)
        }
    }
    
    @objc private func handleSwipe(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
            case .up:
                figure!.changeDir(.up)
            case .down:
                figure!.changeDir(.down)
            case .right:
                figure!.changeDir(.right)
            case .left:
                figure!.changeDir(.left)
            default:
                print("Something went wrong")
                break
        }
    }
    
    func initFunc(_ clear: Bool = false)  {
        let changeValue: Double
        if clear {
            figure!.clear()
            monsters!.clear()
            points!.clear()
            changeValue = gameLogic!.changeValue
        } else {
            changeValue = 1.0
        }
        figure = Figure(gameScene: self as SKScene, changeValue: changeValue)
        monsters = Monsters(gameScene: self as SKScene,
            pacManRadius: figure!.pacManRadius, changeValue: changeValue)
        points = Points(gameScene: self as SKScene, changeValue: figure!.changeValue, pacManRadius: figure!.pacManRadius)
    }
}

