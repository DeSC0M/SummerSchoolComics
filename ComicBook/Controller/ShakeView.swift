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

    @IBOutlet weak var comicsImage: UIImageView!
    
    var transcription: String?
    
    let sinthes = AVSpeechSynthesizer()
    
    let loadData = ViewController()
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake {
                loadData.loadData()
//            sinthes.stopSpeaking(at: .immediate)
//            let comics = BaseServices()
//            comics.getPhotos(onComplited: { (comics) in
//                self.comicsImage.loadImage(by: comics.img)
//                self.transcription = comics.transcript
//            }, onError:  { (error) in
//                print("Error with loading data: \(error)")
//            })
        }
        if super.responds(to: #selector(UIResponder.motionEnded(_:with:))) {
            super.motionEnded(motion, with: event)
        }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
}
