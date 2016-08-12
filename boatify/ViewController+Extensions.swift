//
//  ViewController+Extensions.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit
import Whisper

extension UIViewController {
    
    func showTemporaryMessage(title: String) {
        let murmur = Murmur(title: title, backgroundColor: UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0), titleColor: UIColor.darkGrayColor(), font: UIFont.systemFontOfSize(14.0))
        show(whistle: murmur, action: .Show(2.0))
    }
    
    func showErrorBanner(error: String) {
        let murmur = Murmur(title: error, backgroundColor: UIColor.redColor(), titleColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14.0))
        show(whistle: murmur, action: .Show(3.0))
    }
    
}