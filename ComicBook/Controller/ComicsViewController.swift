//
//  ViewController.swift
//  ComicBook
//
//  Created by Pavel Murzinov on 13/08/2019.
//  Copyright © 2019 Pavel Murzinov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    
    @IBOutlet weak var scrollImageUIScroll: UIScrollView!
    @IBOutlet weak var comicsImage: UIImageView!
    
    var transcription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureScrollAndImageView()
    }

    func configureScrollAndImageView() {
        comicsImage.contentMode = .scaleAspectFit
//        comicsImage.image = UIImage(named: "e_scooters")
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
}

