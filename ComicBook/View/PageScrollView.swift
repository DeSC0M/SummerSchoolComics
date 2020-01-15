//
//  PageScrollView.swift
//  ComicBook
//
//  Created by Pavel Murzinov on 15.01.2020.
//  Copyright © 2020 Pavel Murzinov. All rights reserved.
//

import UIKit

class PageScrollView: UIScrollView, UIScrollViewDelegate{
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(image: UIImage) {
        imageView = UIImageView(image: image)
        self.addSubview(imageView)
        
        configurateFor(imageSize: image.size)
    }
    
    func configurateFor(imageSize: CGSize) {
        self.contentSize = imageSize
        
        setCurrentMaxAndMinScale()
        self.zoomScale = minimumZoomScale
    }
    
    func setCurrentMaxAndMinScale() {
        let boundsSize = self.bounds.size
        let imageSize = imageView.bounds.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height  / imageSize.height
        
        self.minimumZoomScale = min(xScale, yScale)
        self.maximumZoomScale = max(xScale, yScale)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        centerImage()
    }
    
    func centerImage() {
        let boundsSize = self.bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
    
    //MARK: - Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
}
