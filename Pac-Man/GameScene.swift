import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var figure: Figure?
    var monsters: Monsters?
    var gameLogic: GameLogic?
    override func didMove(to view: SKView) {
        initFunc()
        
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
        monsters!.moveMonsters()
        gameLogic!.update(figurePos: figure!.pos, monsterPositons: monsters!.rePositions())
        if gameLogic!.checkLost() {
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
        if clear {
            figure!.clear()
            monsters!.clear()
        }
        figure = Figure(gameScene: self as SKScene)
        monsters = Monsters(gameScene: self as SKScene, pacManRadius: figure!.pacManRadius)
        gameLogic = GameLogic(radius: figure!.pacManRadius)
    }
}

