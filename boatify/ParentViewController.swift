//
//  ParentViewController.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit
import Reactor

class ParentViewController: UIViewController {
    
    var core = App.sharedCore

    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var playBackContainerView: UIView!
    @IBOutlet weak var playBackContainerViewBottomConstraint: NSLayoutConstraint!
    
    
    // MARK: - View life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        core.remove(subscriber: self)
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

extension ParentViewController: Subscriber {
    
    func update(with state: AppState) {
        
    }
}
