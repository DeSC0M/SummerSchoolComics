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
//* При свайпе враво/влево – следующий/предыдущий +/-
//* При встряхивании можно смотреть случайный комикс +
//* Чтение комикса с помощью синтезатора речи +
//* Можно поделиться комиксом

import UIKit
import AVFoundation

class ViewController: UIViewController, UIScrollViewDelegate {

    
    @IBOutlet weak var scrollImageUIScroll: UIScrollView!
    @IBOutlet weak var comicsImage: UIImageView!
    
    var transcription: String?
    
    let sinthes = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureScrollAndImageView()
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
        let comics = BaseServices()
        comics.getPhotos(onComplited: { (comics) in
            self.comicsImage.loadImage(by: comics.img)
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
            loadData()
        }
    }
    
    @IBAction func stopButton(_ sender: Any) {
        sinthes.stopSpeaking(at: .immediate)
    }
}

