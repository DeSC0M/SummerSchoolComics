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

class ComicsViewController: UIViewController, UIScrollViewDelegate {

    
    @IBOutlet weak var scrollImageUIScroll: UIScrollView!
    @IBOutlet weak var comicsImage: UIImageView!
    @IBOutlet weak var shakeView: ShakeView!
    @IBOutlet weak var bottomBar: UIView!
    
    var transcription: String?
    
    let sinthes = AVSpeechSynthesizer()
    
    var arrayOfComics = [ComicsEntry]() // массив в котором хранятся данные комикса
    var counterComics: Int = 0
    
    let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shakeView.onShake = { [weak self] in
            self?.loadData()
        }
        
        configureScrollAndImageView()
        
        statusBar.isHidden = false
    }

    func configureScrollAndImageView() {
        comicsImage.contentMode = .scaleAspectFit
        loadData()
        
        scrollImageUIScroll.delegate = self
        scrollImageUIScroll.minimumZoomScale = 1.0
        scrollImageUIScroll.maximumZoomScale = 10.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return comicsImage
    }
    
    //устанавливаем нужный цвет в статус баре
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadData() {
        sinthes.stopSpeaking(at: .immediate)
        let comics = BaseServices()
        comics.getPhotos(onComplited: { comics in
            
            self.arrayOfComics.append(comics)
            self.counterComics = self.arrayOfComics.count
            
            DispatchQueue.main.async {
                self.comicsImage.loadImage(by: comics.img) //выбивает ошибку при встряхивании
            }
            self.transcription = comics.transcript
        }, onError:  { (error) in
            print("Error with loading data: \(error)")
        })
    }
    
    
    @IBAction func sintezButton(_ sender: Any) {
        let utterfance = AVSpeechUtterance(string: transcription ?? "")
        sinthes.speak(utterfance)
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
    
    @IBAction func stopButton(_ sender: Any) {
        sinthes.stopSpeaking(at: .immediate)
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
            bottomBar.isHidden = !bottomBar.isHidden
            statusBar.isHidden = !statusBar.isHidden
        }
    }
    
    
}

