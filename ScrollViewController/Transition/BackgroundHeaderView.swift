//
//  BackgroundHeaderView.swift
//  ScrollViewController
//
//  Created by Cobb on 2018/5/10.
//  Copyright © 2018年 Cobb. All rights reserved.
//

import UIKit

/// 表头视图的高度
let kCoverHeaderHeight: CGFloat = 295

class BackgroundHeaderView: UIView {
    // MARK: - Property
    
    /// 背景视图
    let backgroundImageView = UIImageView()
    
    /// 封面Blur视图
    let blurCoverView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSubviews()
    }
    
    deinit {
        print("...deinit...")
    }
    
    // MARK: - Private
    
    /// 设置自视图、布局
    private func setUpSubviews() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = UIImage(named: "icon_header_background")
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImageView)
        
        addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        blurCoverView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurCoverView)
        
        addConstraint(NSLayoutConstraint(item: blurCoverView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: blurCoverView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: blurCoverView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: blurCoverView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    // MARK: - Public
    
    /// 更改Blur视图的透明度
    ///
    /// - Parameter alpha: 透明度 0-1
    func changeBlurView(alpha: CGFloat) {
        if alpha <= 1 && alpha >= 0 {
            blurCoverView.alpha = alpha
        }
    }
}
