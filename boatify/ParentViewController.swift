//
//  ParentViewController.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit

class ParentViewController: UIViewController {

    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var playBackContainerView: UIView!
    @IBOutlet weak var playBackContainerViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Bottom view animations
    
    func animateInBottomView() {
        playBackContainerViewBottomConstraint.constant = 0
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func animateOutBottomView() {
        playBackContainerViewBottomConstraint.constant = -60
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }


}
