//
//  ShakeView.swift
//  ComicBook
//
//  Created by Pavel Murzinov on 13/08/2019.
//  Copyright © 2019 Pavel Murzinov. All rights reserved.
//

import UIKit
import AVFoundation

class ShakeView: UIView {
    
    var onShake: (() -> Void)?
        
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake {
            onShake?()
        }
        if super.responds(to: #selector(UIResponder.motionEnded(_:with:))) {
            super.motionEnded(motion, with: event)
        }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
}
