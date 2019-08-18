//
//  ViewController.swift
//  ComicBook
//
//  Created by Pavel Murzinov on 13/08/2019.
//  Copyright © 2019 Pavel Murzinov. All rights reserved.
//
//
//* Экран со случайным комиксом на весь экран +
//* Возможность скроллить его и менять зум +
//* При свайпе враво/влево – следующий/предыдущий +/+
//* При встряхивании можно смотреть случайный комикс +
//* Чтение комикса с помощью синтезатора речи +
//* Можно поделиться комиксом +

import UIKit
import AVFoundation
import JGProgressHUD

class ComicsViewController: UIViewController {

    let playButton = "PlayButton"
    let stopButton = "StopButton"
    let shareButton = "ShareButton"
    
    @IBOutlet weak var scrollImageUIScroll: UIScrollView!
    @IBOutlet weak var comicsImage: UIImageView!
    @IBOutlet weak var shakeView: ShakeView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var playTranscriptionButton: UIButton!
    
    var transcription: String?
    
    let sinthes = AVSpeechSynthesizer()
    
    var arrayOfComics = [ComicsEntry]() // массив в котором хранятся данные комикса
    var counterComics: Int = 0
    
    let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sinthes.delegate = self
        
        shakeView.onShake = { [weak self] in
            self?.loadData()
        }
        
        configureScrollAndImageView()
        
        statusBar.isHidden = false
        statusBar.backgroundColor = .black
    }

    func configureScrollAndImageView() {
        comicsImage.contentMode = .scaleAspectFit
        loadData()
        
        scrollImageUIScroll.delegate = self
        scrollImageUIScroll.minimumZoomScale = 1.0
        scrollImageUIScroll.maximumZoomScale = 3.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return comicsImage
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadData() {
        
        let HUD = JGProgressHUD(style: .dark)
        progressHUD(HUD: HUD, textLable: "Loading", dismissTimer: nil, indicator: nil)
        
        sinthes.stopSpeaking(at: .immediate)
        let comics = BaseServices()
        comics.getPhotos(onComplited: { comics in
            
            self.arrayOfComics.append(comics)
            self.counterComics = self.arrayOfComics.count
            
            DispatchQueue.main.async {
                self.comicsImage.loadImage(by: comics.img)
                
                self.progressHUD(HUD: HUD, textLable: "Success", dismissTimer: 2.0, indicator: "success")
            }
            
            self.transcription = comics.transcript
        }, onError:  { (error) in
            DispatchQueue.main.async {
                self.comicsImage.image = UIImage(named: "DefaultImage")
                self.transcription = "No connection to server. Chech internet connection"
                
                self.progressHUD(HUD: HUD, textLable: "Error", dismissTimer: 2.0, indicator: "error")
            }

            print("Error with loading data: \(error)")
        })
    }
    
    
    @IBAction func sintezButton(_ sender: Any) {
        playTranscriptionButton.imageView?.image == UIImage(named: playButton) ? startSintez() : stopSintez()
    }
    
    
    @IBAction func rightSwype(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .ended {
            if counterComics == arrayOfComics.count{
                loadData()
            } else {
                sinthes.stopSpeaking(at: .immediate)
                
                transcription = arrayOfComics[counterComics].transcript
                comicsImage.loadImage(by: arrayOfComics[counterComics].img)
                counterComics += 1
            }
        }
    }
  
    @IBAction func shareImageButton(_ sender: Any) {
        guard let image = comicsImage.image else {
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(activityController, animated: true)
    }
    
    @IBAction func leftSwype(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .ended {
            loadCacheComics()
        }
    }
    
    func loadCacheComics() {
        let nomberOfComics = counterComics - 2
        if nomberOfComics < 0 {
            return
        }
        sinthes.stopSpeaking(at: .immediate)
        counterComics -= 1
        transcription = arrayOfComics[nomberOfComics].transcript
        comicsImage.loadImage(by: arrayOfComics[nomberOfComics].img)
    }
    
    @IBAction func tapTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            hiddenUserInterface(isHidden: !bottomBar.isHidden)
        }
    }
    
    func hiddenUserInterface(isHidden: Bool) {
        isHidden == true ? showUI() : hiddenUI(isHidden: isHidden)
    }
    
    func hiddenUI(isHidden: Bool) {
        bottomBar.alpha = 0
        statusBar.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.bottomBar.alpha = 1
            self.statusBar.alpha = 1
        }
        bottomBar.isHidden = isHidden
        statusBar.isHidden = isHidden
    }
    
    func showUI() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomBar.alpha = 0
            self.statusBar.alpha = 0
        }) { (finished) in
            self.bottomBar.isHidden = finished
            self.statusBar.isHidden = finished
        }
    }
    
    func startSintez() {
        if let image = UIImage(named: stopButton) {
            playTranscriptionButton.setImage(image, for: .normal)
        }
        if transcription == "" {
            transcription = "this comic cannot be voiced"
        }
        let utterfance = AVSpeechUtterance(string: transcription ?? "")
        sinthes.speak(utterfance)
    }
    
    func stopSintez() {
        if let image = UIImage(named: playButton) {
            playTranscriptionButton.setImage(image, for: .normal)
        }
        sinthes.stopSpeaking(at: .immediate)
    }
    
    func progressHUD(HUD: JGProgressHUD, textLable: String, dismissTimer: TimeInterval?, indicator: String?) {
        HUD.textLabel.text = textLable
        
        switch indicator {
        case "success":
            HUD.indicatorView = JGProgressHUDSuccessIndicatorView.init()
        case "error":
            HUD.indicatorView = JGProgressHUDErrorIndicatorView.init()
        default:
            HUD.indicatorView = JGProgressHUDIndeterminateIndicatorView.init()
        }
        
        HUD.show(in: self.view, animated: true)
        
        if let timeInterval = dismissTimer {
            HUD.dismiss(afterDelay: timeInterval)
        }
    }
    
}

extension ComicsViewController: AVSpeechSynthesizerDelegate, UIScrollViewDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        playTranscriptionButton.setImage(UIImage(named: playButton), for: .normal)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        hiddenUserInterface(isHidden: true)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        DispatchQueue.main.async {
            self.scrollImageUIScroll.setZoomScale(self.scrollImageUIScroll.minimumZoomScale, animated: true)
            self.hiddenUserInterface(isHidden: false)
        }
    }
}
