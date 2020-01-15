//
//  ViewController.swift
//  ComicBook
//
//  Created by Pavel Murzinov on 13/08/2019.
//  Copyright © 2019 Pavel Murzinov. All rights reserved.
//
//

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
    
    var isHiddenUserInterface = false
    override var prefersStatusBarHidden: Bool {
        return isHiddenUserInterface
    }
    
    var isLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sinthes.delegate = self
        
        shakeView.onShake = { [weak self] in
            self?.loadData()
        }
        
        configureScrollAndImageView()
    }

    func configureScrollAndImageView() {
        comicsImage.contentMode = .scaleAspectFit
        loadData()
        
        scrollImageUIScroll.delegate = self
        scrollImageUIScroll.isPagingEnabled = true
        
        comicsImage.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadData() {
        isLoad = true
        let HUD = JGProgressHUD(style: .dark)
        progressHUD(HUD: HUD, textLable: "Loading", dismissTimer: nil, indicator: nil)
        
        sinthes.stopSpeaking(at: .immediate)
        
        let group = DispatchGroup()
        group.enter()
        let comics = BaseServices()
        comics.getPhotos(onComplited: { comics in
            
            self.arrayOfComics.append(comics)
            self.counterComics = self.arrayOfComics.count
            
            DispatchQueue.main.async {
                self.comicsImage.loadImage(by: comics.img, in: group)
                if let image = self.comicsImage {
                    self.scrollImageUIScroll.addSubview(image)
                } else {
                    print("Can't get image")
                }
                
                self.progressHUD(HUD: HUD, textLable: "Success", dismissTimer: 1.0, indicator: "success")
            }
            
            self.transcription = comics.transcript
        }, onError:  { (error) in
            DispatchQueue.main.async {
                self.comicsImage.image = UIImage(named: "DefaultImage")
                self.transcription = "No connection to server. Chech internet connection"
                
                self.progressHUD(HUD: HUD, textLable: "Error", dismissTimer: 1.0, indicator: "error")
            }

            print("Error with loading data: \(error)")
        })
        
        group.notify(queue: .main) {
            guard let image = self.comicsImage.image else {
                print("\tCan't get image from comicsImage. ")
                return
            }
            
            let count = self.arrayOfComics.count
            let boundsSize = self.scrollImageUIScroll.bounds
            
            self.scrollImageUIScroll.contentSize = CGSize(width: boundsSize.width * CGFloat(count + 1), height: boundsSize.height)
            
            let rect = CGRect(x: boundsSize.width * CGFloat(count - 1), y: 0, width: boundsSize.width, height: boundsSize.height)
            let pageView = PageScrollView(frame: rect)
            pageView.set(image: image)
            
            self.scrollImageUIScroll.addSubview(pageView)
            self.isLoad = false
        }
    }
    
    
    @IBAction func sintezButton(_ sender: Any) {
        playTranscriptionButton.imageView?.image == UIImage(named: playButton) ? startSintez() : stopSintez()
    }
    
//    переделать
    @IBAction func rightSwype(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .ended {
            if counterComics == arrayOfComics.count{
                loadData()
            } else {
                sinthes.stopSpeaking(at: .immediate)
                
                transcription = arrayOfComics[counterComics].transcript
                
                let group = DispatchGroup()
                group.enter()
                comicsImage.loadImage(by: arrayOfComics[counterComics].img, in: group)
                counterComics += 1
            }
        }
    }
    //    переделать
    @IBAction func leftSwype(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .ended {
            loadCacheComics()
        }
    }
//    переделать
    func loadCacheComics() {
        let nomberOfComics = counterComics - 2
        if nomberOfComics < 0 {
            return
        }
        sinthes.stopSpeaking(at: .immediate)
        counterComics -= 1
        transcription = arrayOfComics[nomberOfComics].transcript
        
        let group = DispatchGroup()
        group.enter()
        comicsImage.loadImage(by: arrayOfComics[nomberOfComics].img, in: group)
    }
//    переделать
    @IBAction func shareImageButton(_ sender: Any) {
        guard let image = comicsImage.image else {
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(activityController, animated: true)
    }
    
    @IBAction func tapTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            hiddenUserInterface(isHidden: !isHiddenUserInterface)
        }
    }
    
    //MARK: - UI func (hidden or show)
    func hiddenUserInterface(isHidden: Bool) {
        isHiddenUserInterface = isHidden
        if isHidden == false {
            showUI()
        } else {
            hiddenUI()
        }
    }
    
    func hiddenUI() {
        bottomBar.alpha = 1
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomBar.alpha = 0
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: { _ in
            self.bottomBar.isHidden = true
        })
    }
    
    func showUI() {
        bottomBar.alpha = 0
        bottomBar.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.bottomBar.alpha = 1
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: - Sintez Func
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
    
    //MARK: - ProgressHUD
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

//MARK: - Extension
extension ComicsViewController: AVSpeechSynthesizerDelegate, UIScrollViewDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        playTranscriptionButton.setImage(UIImage(named: playButton), for: .normal)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        if (pageNumber - CGFloat(arrayOfComics.count - 1)) > 0.1 && !isLoad {
            loadData()
        }
    }
}
