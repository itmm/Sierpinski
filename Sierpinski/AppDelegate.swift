import UIKit
import QuartzCore

let birthInterval = 0.1
let showDuration = 0.5
let fadeDuration = 2.0
let maxElements = 300

@UIApplicationMain
class Sierpinski: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var dot = UIImage(named: "Dot");
    var playground = CGSize()
    var position = CGPoint()
    var fadingLayers = 0;


// - setup

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        let w = UIWindow(frame: UIScreen.mainScreen().bounds)
        w.backgroundColor = UIColor.darkGrayColor()
        w.makeKeyAndVisible()
        window = w;
        
        playground.width = w.bounds.width - dot.size.width
        playground.height = w.bounds.height - dot.size.height
        
        sranddev()
        
        NSTimer.scheduledTimerWithTimeInterval(
            birthInterval, target: self, selector: Selector("addDot"), userInfo: nil, repeats: true
        )

        return true
    }


// - layer creation and fade animation

    func createLayer() -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(x: position.x, y: position.y, width: dot.size.width, height: dot.size.height)
        layer.contents = dot.CGImage
        return layer;
    }
    
    func animateOpacityForLayer(layer: CALayer, to: CGFloat, duration: NSTimeInterval, delegate: NSObject? = nil) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = duration
        animation.fromValue = 1 - to
        animation.toValue = to
        animation.fillMode = kCAFillModeBoth
        animation.delegate = delegate
        layer.addAnimation(animation, forKey: "opacity")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        window!.layer.sublayers[0].removeFromSuperlayer()
        --fadingLayers
    }


// - dot placement

    func updatePosition() {
        position.x /= 2
        position.y /= 2
        switch random() % 3 {
            case 0:
                position.x += playground.width/2
                position.y += playground.height/2
            case 1:
                position.y += playground.height/2
            default:
                position.x += playground.width/4
        }
    }
    
    func addDot() {
        self.updatePosition()
        
        let container = self.window!.layer;
        var visibleLayers = (container.sublayers ? container.sublayers.count : 0) - fadingLayers;

        var layer = createLayer()
        animateOpacityForLayer(layer, to: 1, duration: showDuration)
        container.addSublayer(layer)
        
        while visibleLayers > maxElements {
            let choice = random() % visibleLayers + fadingLayers
            let fading = container.sublayers[choice] as CALayer
            container.insertSublayer(fading, atIndex: CUnsignedInt(fadingLayers))
            animateOpacityForLayer(fading, to: 0, duration: fadeDuration, delegate: self)
            ++fadingLayers
            --visibleLayers
        }
    }
}
