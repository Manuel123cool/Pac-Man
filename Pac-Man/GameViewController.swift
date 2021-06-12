import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
  
        let firstScene = GameScene(size: self.view.bounds.size)
        let skview = self.view as! SKView
        
        skview.presentScene(firstScene)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        /*
        let skview = self.view as! SKView
        let scene = skview.scene!
        var text=""
        switch UIDevice.current.orientation{
        case .portrait:
            text="Portrait"
        case .portraitUpsideDown:
            scene.anchorPoint = CGPoint(x: scene.size.width, y: 0)
            text="PortraitUpsideDown"
        case .landscapeLeft:
            text="LandscapeLeft"
        case .landscapeRight:
            text="LandscapeRight"
        default:
            text="Another"
        }
        NSLog("You have moved: \(text)")
        */
    }
}
