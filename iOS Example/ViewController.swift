//
//  ViewController.swift
//  CountdownTimerView
//
//  Created by Paul on 30/07/2016.
//  Copyright © 2016 Paul Sneddon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var countdownTimerView: CountdownTimerView!
    @IBOutlet weak var randomColorButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        countdownTimerView.progressColor = UIColor.blue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapRandomColorButton(_ sender: AnyObject) {
        countdownTimerView.progressColor = generateRandomColor()
    }
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

}

