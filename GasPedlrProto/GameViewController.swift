

import UIKit
import SpriteKit

class GameViewController: UIViewController, MySceneDelegate {
    @IBOutlet weak var skView : SKView!
    @IBOutlet weak var padSlider : UISlider!
    @IBOutlet weak var lifeLabel : UILabel!
    @IBOutlet weak var gameOverButton : UIButton!
    @IBOutlet weak var gameClearButton : UIButton!
    @IBOutlet var adImage: UIImageView!
    @IBOutlet var backButton: UIButton!
    
    @IBAction func backToMainView(sender: AnyObject) {
        skView.presentScene(nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
    //var adDict = ["bannerSpa.png": "adSpa.png", "bannerStarbucks.png": "adStarbucks.jpg", "bannerHalfAcre.png": "adHalfAcre.jpg", "bannerTacoBell.jpg": "adTacoBell.png"]
    
    var timer = NSTimer()
    var newDict = ["bannerSpa.png": "newAdSpa.jpg", "bannerTacoBell.jpg": "newAdTacoBell.png", "bannerStarbucks.png": "newAdStarbucks.jpg", "bannerHalfAcre.png": "newAdHalfAcre.jpg"]
    
    var _myScene : MyScene!
    var _readyToFire = false
    var _lifeCount : Int = 0 {
        didSet {
            lifeLabel.text = String(_lifeCount)
        }
    }

    func gameStart() {
        _lifeCount = 10
        gameOverButton.hidden = true
        gameClearButton.hidden = true
        
        _myScene.reset()
        _readyToFire = true
    }

    @IBAction func restart(_ : AnyObject) {
        _myScene.respawn(completion:{ self.gameStart() })
    }
    
    func respawn() {
        _myScene.respawn(completion:{ self._readyToFire = true })
    }
    
    func dead() {
        _lifeCount--
        
        if 0 < _lifeCount {
            NSTimer.scheduledTimerWithTimeInterval(3.0,
                target:self, selector:"respawn",
                userInfo:nil, repeats:false)
        } else {
            gameOverButton.hidden = false
        }
        _readyToFire = false
    }
    
    func clear() {
        gameClearButton.hidden = false
        _readyToFire = false
    }
    
    func updateAd(spriteName: String) {
        adImage.image = UIImage(named: newDict[spriteName]!)
        adImage.backgroundColor = getRandomColor()
    }
    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }

    func setPadPosition(value:Float) {
        if _readyToFire {
            _myScene.fire()
            _readyToFire = false
        }
        _myScene.padX = value
    }
    
    @IBAction func padSliderMoved(sender : UISlider) {
        setPadPosition(sender.value)
    }
    
    @IBAction func pan(sender : UIPanGestureRecognizer) {
        let value = Float(sender.locationInView(_myScene.view).x)
        padSlider.value = value
        setPadPosition(value)
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("updateBoard"), userInfo: nil, repeats: true)
    }
    
    func updateBoard() {
        _myScene.updateBoard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _myScene = MyScene(size: skView.frame.size)
        skView.presentScene(_myScene)

        padSlider.minimumValue = 0
        padSlider.maximumValue = Float(_myScene.size.width)
        padSlider.value = Float(_myScene.padX)
        
        _myScene.mySceneDelegate = self
        scheduledTimerWithTimeInterval()
        gameStart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

