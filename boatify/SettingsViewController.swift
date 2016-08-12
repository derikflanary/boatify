//
//  SettingsViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import ReSwift

class SettingsViewController: UIViewController {

    let settingsService = SettingsService()
    var store = AppState.sharedStore
    
    @IBOutlet weak var maxSlider: UISlider!
    @IBOutlet weak var minSlider: UISlider!
    @IBOutlet weak var maxPercentLabel: UILabel!
    @IBOutlet weak var minPercentLabel: UILabel!
    
    
    // MARK: - View life cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    
    // MARK: - Interface actions
    
    @IBAction func maxSliderChangedValue(sender: AnyObject) {
        if maxSlider.value <= minSlider.value + 0.1 {
            maxSlider.value = minSlider.value + 0.1
        }
        maxPercentLabel.text = "\(maxSlider.value.percentForm)%"
    }
    
    @IBAction func minSliderChangedValue(sender: AnyObject) {
        if minSlider.value >= maxSlider.value - 0.1 {
            minSlider.value = maxSlider.value - 0.1
        }
        minPercentLabel.text = "\(minSlider.value.percentForm)%"
    }
    
    @IBAction func doneTapped(sender: UIBarButtonItem) {
        store.dispatch(settingsService.updateVolumes(minVolume: minSlider.value, maxVolume: maxSlider.value))
        dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - Store subscriber

extension SettingsViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        maxSlider.setValue(Float(state.maxVolume), animated: true)
        minSlider.setValue(Float(state.minVolume), animated: true)
        maxPercentLabel.text = "\(maxSlider.value.percentForm)%"
        minPercentLabel.text = "\(minSlider.value.percentForm)%"
    }
    
}

extension Float {
    var percentForm: String {
        let percent = self * 100
        return String(format: "%.0f", percent)
    }
}
