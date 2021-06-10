import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var figure: Figure?
    
    override func didMove(to view: SKView) {
        figure = Figure(gameScene: self as SKScene)
        backgroundColor = SKColor.black
        
        addGesturRecognizer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*for touch in touches {
        }
 */
    }
    
    override func update(_ currentTime: TimeInterval) {
        figure!.move()
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
}

