//
//  AppLogoView.swift
//  user_list_view
//
//  Created by Eri on 2/10/18.
//  Copyright © 2018 Brayan Rodriguez. All rights reserved.
//

import UIKit

class AppLogoView: UIView {
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    // Views
    fileprivate let titleLabel = UILabel()
    fileprivate let imageView = UIImageView()
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setup()
        setupConstraints()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 100)
    }
    
    func setup() {
        imageView.contentMode = .scaleAspectFit
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 28.0)
        titleLabel.textColor = UIColor.black
        
        addSubview(imageView)
        addSubview(titleLabel)
    }
    
    func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 1
        let labelBottom =
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        let labelCenterX =
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        
        // 2
        let imageViewBottom =
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor)
        let imageViewCenterX =
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        
        let imageViewWidth =
            imageView.widthAnchor.constraint(equalToConstant: 80)
        let imageViewHeight =
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.65)
        
        NSLayoutConstraint.activate([
            imageViewBottom, imageViewCenterX, imageViewWidth, imageViewHeight,
            labelBottom, labelCenterX])
        
        // the title label tries to not stretch vertically
        titleLabel.setContentHuggingPriority(
            UILayoutPriorityRequired,
            for: .vertical)
        
        // the title label tries not to shrink vertically
        titleLabel.setContentCompressionResistancePriority(
            UILayoutPriorityRequired,
            for: .vertical)
        
        // the imageView tries to shrink vertically
        imageView.setContentCompressionResistancePriority(
            UILayoutPriorityDefaultLow,
            for: .vertical)
    }
    
    // after the views have been layed out you can call the layoutsubviews method
    // to check the frame of  imageView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageView.bounds.height < 40 {
            imageView.alpha = 0
        } else {
            imageView.alpha = 1
        }
    }
}

