//
//  ParentViewController.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit
import Reactor
import Hero

class ParentViewController: UIViewController {
    
    var core = App.sharedCore

    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var playBackContainerView: UIView!
    @IBOutlet weak var playBackContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    
    // MARK: - View life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        core.remove(subscriber: self)
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        
    }
    
    // MARK: - Bottom view animations
    
    func animateInBottomView() {
        guard playBackContainerViewBottomConstraint.constant < 0 else { return }
        playBackContainerViewBottomConstraint.constant = 0
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func animateOutBottomView() {
        guard playBackContainerViewBottomConstraint.constant == 0 else { return }
        playBackContainerViewBottomConstraint.constant = -60
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }


}

extension ParentViewController: Subscriber {
    
    func update(with state: AppState) {
        switch state.viewState {
        case .preLoggedIn, .loading(_):
            animateOutBottomView()
        case .viewing:
            animateInBottomView()
        default:
            break
        }
    }
}
