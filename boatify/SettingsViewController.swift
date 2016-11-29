//
//  SettingsViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import ReSwift

protocol SettingsDelegate {
    func volumeChanged(_ minVolume: Double, maxVolume: Double)
}

class SettingsViewController: UIViewController {

    let settingsService = SettingsService()
    var store = AppState.sharedStore
    var originalMinVolume: Double?
    var originalMaxVolume: Double?
    var delegate: SettingsDelegate?
    
    @IBOutlet weak var maxSlider: UISlider!
    @IBOutlet weak var minSlider: UISlider!
    @IBOutlet weak var maxPercentLabel: UILabel!
    @IBOutlet weak var minPercentLabel: UILabel!
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    
    // MARK: - Interface actions
    
    @IBAction func maxSliderChangedValue(_ sender: AnyObject) {
        if maxSlider.value <= minSlider.value + 0.1 {
            maxSlider.value = minSlider.value + 0.1
            showTemporaryMessage("Max volume must be higher than minimum")
        }
        maxPercentLabel.text = "\(maxSlider.value.percentForm)%"
        delegate?.volumeChanged(Double(minSlider.value), maxVolume: Double(maxSlider.value))
    }
    
    @IBAction func minSliderChangedValue(_ sender: AnyObject) {
        if minSlider.value >= maxSlider.value - 0.1 {
            minSlider.value = maxSlider.value - 0.1
            showTemporaryMessage("Minimum volume must be lower than max")
        }
        minPercentLabel.text = "\(minSlider.value.percentForm)%"
        delegate?.volumeChanged(Double(minSlider.value), maxVolume: Double(maxSlider.value))
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        store.dispatch(settingsService.updateVolumes(minVolume: minSlider.value, maxVolume: maxSlider.value))
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        guard let minVolume = originalMinVolume, let maxVolume = originalMaxVolume else { return }
        
        if minVolume != Double(minSlider.value) || maxVolume != Double(maxSlider.value) {
            store.dispatch(settingsService.updateVolumes(minVolume: Float(minVolume), maxVolume: Float(maxVolume)))
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonTapped() {
        guard let minVolume = originalMinVolume, let maxVolume = originalMaxVolume else { return }
        delegate?.volumeChanged(minVolume, maxVolume: maxVolume)
        minSlider.setValue(Float(minVolume), animated: true)
        maxSlider.setValue(Float(maxVolume), animated: true)
        minPercentLabel.text = "\(minSlider.value.percentForm)%"
        maxPercentLabel.text = "\(maxSlider.value.percentForm)%"
    }
    
}


// MARK: - Store subscriber

extension SettingsViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        maxSlider.setValue(Float(state.recorderState.volume.max), animated: true)
        minSlider.setValue(Float(state.recorderState.volume.min), animated: true)
        maxPercentLabel.text = "\(maxSlider.value.percentForm)%"
        minPercentLabel.text = "\(minSlider.value.percentForm)%"
        originalMaxVolume = state.recorderState.volume.max
        originalMinVolume = state.recorderState.volume.min
    }
    
}
