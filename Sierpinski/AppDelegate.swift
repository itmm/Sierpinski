import UIKit
import QuartzCore

let birthInterval = 0.1
let showDuration = 0.5
let fadeDuration = 2.0
let maxElements = 300

@UIApplicationMain
class Sierpinski: UIResponder, UIApplicationDelegate {
                            
    lazy var window = UIWindow(frame: UIScreen.mainScreen().bounds)
    lazy var dot = UIImage(named: "Dot");
    var playground = CGSize()
    var position = CGPoint()
    var fadingLayers = 0


// - setup

    func application(
        application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: NSDictionary?
    ) -> Bool {
        window.backgroundColor = UIColor.darkGrayColor()
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        
        playground.width = window.bounds.width - dot.size.width
        playground.height = window.bounds.height - dot.size.height
        
        sranddev()
        
        NSTimer.scheduledTimerWithTimeInterval(
            birthInterval,
            target: self,
            selector: Selector("addDot"),
            userInfo: nil,
            repeats: true
        )

        return true
    }


// - layer creation and fade animation

    func createLayer() -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(
            x: position.x,
            y: position.y,
            width: dot.size.width,
            height: dot.size.height
        )
        layer.contents = dot.CGImage
        return layer;
    }
    
    func animateOpacityForLayer(
        layer: CALayer,
        to: Float,
        duration: NSTimeInterval,
        delegate: NSObject?
    ) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = duration
        animation.fromValue = 1 - to
        animation.toValue = to
        animation.delegate = delegate
        animation.fillMode = kCAFillModeForwards
        animation.additive = false
        animation.removedOnCompletion = false

        layer.addAnimation(animation, forKey: "opacity")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        window.layer.sublayers[0].removeFromSuperlayer()
        --fadingLayers
    }


// - dot placement

    func updatePosition() {
        position.x /= 2
        position.y /= 2
        switch random() % 3 {
            case 0:
                position.x += playground.width/2
                fallthrough
            case 1:
                position.y += playground.height/2
            default:
                position.x += playground.width/4
        }
    }
    
    func addDot() {
        self.updatePosition()
        
        let container = self.window.layer
        
        var visibleLayers = 0
        if let sublayers = container.sublayers {
            visibleLayers += sublayers.count
        }
        visibleLayers -= fadingLayers

        var layer = createLayer()
        animateOpacityForLayer(layer, to: 1, duration: showDuration, delegate: nil)
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
