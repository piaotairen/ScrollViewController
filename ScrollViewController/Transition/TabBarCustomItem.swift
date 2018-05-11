//
//  TabBarCustomItem.swift
//  ScrollViewController
//
//  Created by Cobb on 2018/5/4.
//  Copyright © 2018年 Cobb. All rights reserved.
//

import UIKit

/// 滚动Tab栏目的高度
let kScrollTabBarHeight: CGFloat = 60.0

/// Tab栏Scale缩放控制
let tabScaleMax: CGFloat = 0.0

/// TabBarCustomItem 点击区域
///
/// - title: 点击标题
/// - icon: 点击Icon
enum TabBarTapActionType {
    case title
    case icon
}

/// TabBarCustomItem的视图协议
protocol TabBarCustomItemProtocol: NSObjectProtocol {
    
    /// 点击TabBar的标题或Icon
    func tabBarCustomItem(_ item: TabBarCustomItem, onClick type: TabBarTapActionType)
}

/// 自定义的TabBar的视图
class TabBarCustomItem: UIView {
    
    // MARK: - Property
    
    /// Tab栏目标题按钮
    private let titleButton = UIButton(type: .custom)
    
    /// Tab栏目Icon按钮
    private let arrowButton = UIButton(type: .custom)
    
    /// 标题
    var title: String?
    
    /// 默认Icon
    var image: UIImage?
    
    /// 选中Icon
    var selectedImage: UIImage?
    
    /// 是否被选中
    var isSelected: Bool = false
    
    /// 字体大小
    fileprivate let tabBarFont = UIFont.systemFont(ofSize: 14)
    
    /// 计算的Item的尺寸
    var caculateItemSize = CGSize.zero
    
    /// Icon尺寸
    fileprivate let iconSize = CGSize(width: 16, height: 9)
    
    /// 标题左边间隙
    fileprivate let leftMargin: CGFloat = 10
    
    /// 标题/Iocn中间间隙
    fileprivate let middleMargin: CGFloat = 10
    
    /// Icon右边边间隙
    fileprivate let rightMargin: CGFloat = 10
    
    /// 协议成员
    weak var delegate: TabBarCustomItemProtocol?
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCustomViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadCustomViews()
    }
    
    /// 推荐的初始化方法
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - image: 图标
    ///   - selectedImage: 选中图标
    public convenience init(title: String?, image: UIImage?, selectedImage: UIImage?) {
        self.init(frame: .zero)
        self.title = title
        titleButton.setTitle(title, for: .normal)
        self.image = image
        arrowButton.setImage(image, for: .normal)
        self.selectedImage = selectedImage
        arrowButton.setImage(selectedImage, for: .selected)
        caculateSubviewsConstraint()
    }
    
    deinit {
    }
    
    // MARK: - Private
    
    /// 加载自视图
    func loadCustomViews() {
        titleButton.translatesAutoresizingMaskIntoConstraints = false
        titleButton.titleLabel?.font = tabBarFont
        let colorPoint: CGFloat = 137.0 / 255.0
        titleButton.setTitleColor(UIColor(red: colorPoint, green: colorPoint, blue: colorPoint, alpha: 1), for: UIControlState())
        titleButton.addTarget(self, action: #selector(TabBarCustomItem.titleButtonTapped(_:)), for: .touchUpInside)
        addSubview(titleButton)
        
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        arrowButton.contentMode = .scaleAspectFit
        arrowButton.backgroundColor = .clear
        arrowButton.addTarget(self, action: #selector(TabBarCustomItem.arrowButtonTapped(_:)), for: .touchUpInside)
        addSubview(arrowButton)
    }
    
    /// Tab栏标题按钮点击
    ///
    /// - Parameter button: 点击的Tab按钮
    @objc fileprivate func titleButtonTapped(_ button: UIButton) {
        delegate?.tabBarCustomItem(self, onClick: .title)
    }
    
    /// Tab栏Icon按钮点击
    ///
    /// - Parameter button: 点击的Tab按钮
    @objc fileprivate func arrowButtonTapped(_ button: UIButton) {
        delegate?.tabBarCustomItem(self, onClick: .icon)
    }
    
    /// 根据文本和Icon计算自视图布局
    func caculateSubviewsConstraint() {
        let limitSize = CGSize(width: kScreenWidth, height: kScrollTabBarHeight)
        let titleAttributes: [NSAttributedStringKey : Any] = [.font: tabBarFont]
        var titleRect = CGRect.zero
        if let title = title {
            titleRect = title.boundingRect(with: limitSize, options: .usesLineFragmentOrigin, attributes: titleAttributes, context:nil)
        }
        let titleWidth = CGSize(width: ceil(titleRect.width), height: kScrollTabBarHeight)
        let tabBarWidth = leftMargin + titleWidth.width + middleMargin + iconSize.width + rightMargin
        caculateItemSize = CGSize(width: tabBarWidth, height: kScrollTabBarHeight)
        
        addConstraint(NSLayoutConstraint(item: titleButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: titleWidth.width))
        addConstraint(NSLayoutConstraint(item: titleButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: titleWidth.height))
        addConstraint(NSLayoutConstraint(item: titleButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: leftMargin))
        addConstraint(NSLayoutConstraint(item: titleButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: arrowButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: iconSize.width))
        addConstraint(NSLayoutConstraint(item: arrowButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: iconSize.height))
        addConstraint(NSLayoutConstraint(item: arrowButton, attribute: .left, relatedBy: .equal, toItem: titleButton, attribute: .right, multiplier: 1, constant: middleMargin))
        addConstraint(NSLayoutConstraint(item: arrowButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    // MARK: - Public
    
    /// 即将选中
    ///
    /// - Parameters:
    ///   - percent: 转场过渡百分比
    func willSelectItem(_ percent: CGFloat) {
        titleButton.transform = CGAffineTransform(scaleX: 1 + tabScaleMax * percent, y: 1)
        let colorPoint: CGFloat = (137.0 * (1 - percent) + 73.0 * percent) / 255.0
        titleButton.setTitleColor(UIColor(red: colorPoint, green: colorPoint, blue: colorPoint, alpha: 1), for: UIControlState())
    }
    
    /// 已经选中
    func didSelectItem() {
        titleButton.transform = CGAffineTransform(scaleX: 1 + tabScaleMax, y: 1)
        let colorPoint: CGFloat = 73.0 / 255.0
        titleButton.setTitleColor(UIColor(red: colorPoint, green: colorPoint, blue: colorPoint, alpha: 1), for: UIControlState())
    }
    
    /// 即将取消选中
    ///
    /// - Parameter percent: 转场过渡百分比
    func willDeselectItem(_ percent: CGFloat) {
        titleButton.transform = CGAffineTransform(scaleX: 1 + tabScaleMax * (1 - percent), y: 1)
        let colorPoint: CGFloat = (137.0 * percent + 73.0 * (1 - percent)) / 255.0
        titleButton.setTitleColor(UIColor(red: colorPoint, green: colorPoint, blue: colorPoint, alpha: 1), for: UIControlState())
    }
    
    /// 已经取消选中
    func didDeselectItem() {
        titleButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        let colorPoint: CGFloat = 137.0 / 255.0
        titleButton.setTitleColor(UIColor(red: colorPoint, green: colorPoint, blue: colorPoint, alpha: 1), for: UIControlState())
    }
}
