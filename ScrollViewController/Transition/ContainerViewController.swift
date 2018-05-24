//
//  ContainerViewController.swift
//  ScrollViewController
//
//  Created by Cobb on 2018/5/4.
//  Copyright © 2018年 Cobb. All rights reserved.
//

import UIKit

/// 屏幕宽
let kScreenWidth = UIScreen.main.bounds.size.width

/// 屏幕高
let kScreenHeight = UIScreen.main.bounds.size.height

/// 顶部Header总高度
let kTotalHeaderHeight = kCoverHeaderHeight + kScrollTabBarHeight

/// ScrollTabBar视图控制器的基类 处理子视图控制器加载、布局、转场等核心逻辑
class ContainerViewController: UIViewController {
    
    // MARK: Normal Property
    
    /// 容器视图
    fileprivate let privateContainerView = UIView()
    
    /// 自定义的伪头部视图 放置在容器视图中
    let header = BackgroundHeaderView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kCoverHeaderHeight))

    /// Tab栏目视图
    private let containerTabBar = UIView(frame: CGRect(x: 0, y: kCoverHeaderHeight, width: kScreenWidth, height: kScrollTabBarHeight))
    
    // MARK: Property for Transition
    
    /// 交互手势控制
    var interactive = false
    
    /// 转场代理
    weak var containerTransitionDelegate: InteractiveTransitionMakerProtocol?
    
    /// 转场控制类
    fileprivate var containerTransitionContext: ContainerTransitionContext?
    
    // MARK: Property like UITabBarController
    
    /// set tabChildViewControllers need more code and test, so keep this private in this demo.
    fileprivate(set) var tabChildViewControllers: [UIViewController]?
    
    /// Tab栏目标题集
    fileprivate(set) var tabBarTitles: [String] = []
    
    /// Tab栏目icon集
    fileprivate(set) var tabBarIcons: [String] = []
    
    /// Tab栏目选中icon集
    fileprivate(set) var tabBarSelectedIcons: [String] = []
    
    /// 是否存储选中按钮信息
    fileprivate var shouldReserve = false
    
    /// 先前选中的按钮位置
    fileprivate var priorSelectedIndex: Int = NSNotFound
    
    /// 选中的Tab栏目
    var selectedIndex: Int = NSNotFound {
        willSet {
            if shouldReserve {
                shouldReserve = false
            } else {
                transitionViewControllerFromIndex(selectedIndex, toIndex: newValue)
            }
        }
    }
    
    /// 选中的控制器
    var selectedViewController: UIViewController? {
        get {
            if tabChildViewControllers == nil || selectedIndex < 0 || selectedIndex >= tabChildViewControllers!.count {
                return nil
            }
            return tabChildViewControllers![selectedIndex]
        }
        set {
            if tabChildViewControllers == nil{
                return
            }
            if let index = tabChildViewControllers!.index(of: selectedViewController!){
                selectedIndex = index
            } else {
                print("The view controller is not in the tabChildViewControllers")
            }
        }
    }
    
    // MARK: - Class Life Method
    
    /// 实例化
    ///
    /// - Parameters:
    ///   - viewControllers: 控制器集
    ///   - titles: Tab栏目集
    ///   - icons: Tab的icon集
    init(viewControllers: [UIViewController], titles: [String], icons: [String], selectedIcons: [String]) {
        assert(viewControllers.count > 0, "can't init with 0 child VC")
        super.init(nibName: nil, bundle: nil)
        
        tabChildViewControllers = viewControllers
        tabBarTitles = titles
        tabBarIcons = icons
        tabBarSelectedIcons = selectedIcons
        
        for innerViewController in viewControllers {
            /// 如果是 RankingTableViewController 则监听表格上下移动 设置Tabbar位置
            if let rankingViewController = innerViewController as? RankingTableViewController {
                rankingViewController.tableView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            }
            /// 适应屏幕旋转的最简单的办法，在转场开始前设置子 view 的尺寸为容器视图的尺寸。
            innerViewController.view.translatesAutoresizingMaskIntoConstraints = true
            innerViewController.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: K_NOTIFI_TRANSITION_END), object: nil, queue: nil, using: { _ in
            self.containerTransitionContext = nil
            self.containerTabBar.isUserInteractionEnabled = true
        })
    }
    
    /// Not Support
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't support init from storyboar in this demo")
        //super.init(coder: aDecoder)
    }
    
    /// 重载视图 添加自定义视图
    override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = UIColor.black
        rootView.isOpaque = true
        self.view = rootView
        
        privateContainerView.translatesAutoresizingMaskIntoConstraints = false
        privateContainerView.backgroundColor = UIColor.clear
        privateContainerView.isOpaque = true
        privateContainerView.addSubview(header)
        rootView.addSubview(privateContainerView)
        
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .width, relatedBy: .equal, toItem: rootView, attribute: .width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .height, relatedBy: .equal, toItem: rootView, attribute: .height, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .left, relatedBy: .equal, toItem: rootView, attribute: .left, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .top, relatedBy: .equal, toItem: rootView, attribute: .top, multiplier: 1, constant: 0))
        
        containerTabBar.translatesAutoresizingMaskIntoConstraints = true
        containerTabBar.backgroundColor = UIColor.white
        containerTabBar.tintColor = UIColor.clear
        containerTabBar.isUserInteractionEnabled = true
        rootView.addSubview(containerTabBar)
        
        addChildViewControllerButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Setting this property in other method before this one will make a bug: when you go back to this initial selectedIndex, no transition animation.
        if tabChildViewControllers != nil && tabChildViewControllers!.count > 0 && selectedIndex == NSNotFound {
            selectedIndex = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Restore data and change button appear
    
    /// 重置选中的Tab栏
    func restoreSelectedIndex() {
        shouldReserve = true
        selectedIndex = priorSelectedIndex
    }
    
    /// Only work in interactive transition
    /// tab栏的按钮首次出现时设置
    func tabButtonWillAppear() {
        if let selectItem = containerTabBar.subviews.first as? TabBarCustomItem {
            selectItem.didSelectItem()
        }
    }
    
    /// 设置Tab栏切换时按钮的状态
    ///
    /// - Parameters:
    ///   - fromIndex: 起始位置
    ///   - toIndex: 终止位置
    ///   - percent: 移动百分比
    func graduallyChangeTabButtonAppearWith(_ fromIndex: Int, toIndex: Int, percent: CGFloat) {
        let fromTabBarItem = containerTabBar.subviews[fromIndex] as! TabBarCustomItem
        let toTabBarItem = containerTabBar.subviews[toIndex] as! TabBarCustomItem
        if fromIndex < toIndex {
            //👈-》👉
            fromTabBarItem.willDeselectItem(percent)
            toTabBarItem.willSelectItem(percent)
        } else {
            //👉-》👈
            fromTabBarItem.willDeselectItem(percent)
            toTabBarItem.willSelectItem(percent)
        }
    }
    
    /// Only work in containerTabBar button tap
    func changeTabButtonAnimateWith(_ fromIndex: Int, toIndex: Int) {
        UIView.animate(withDuration: 0.3) {
            self.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: 1)
        }
    }
    
    // MARK: - Private Helper Method
    
    /// 添加子视图控制器
    fileprivate func addChildViewControllerButtons() {
        var buttonMargin: CGFloat = 0
        for (index, buttonTitle) in tabBarTitles.enumerated() {
            var image: UIImage? = nil
            if index < tabBarIcons.count {
                image = UIImage(named: tabBarIcons[index])
            }
            var selectedImage: UIImage? = nil
            if index < tabBarSelectedIcons.count {
                selectedImage = UIImage(named: tabBarSelectedIcons[index])
            }
            let tabBarItem = TabBarCustomItem(title: buttonTitle, image: image, selectedImage: selectedImage)
            tabBarItem.translatesAutoresizingMaskIntoConstraints = false
            tabBarItem.delegate = self
            containerTabBar.addSubview(tabBarItem)
            
            containerTabBar.addConstraint(NSLayoutConstraint(item: tabBarItem, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: tabBarItem.caculateItemSize.width))
            containerTabBar.addConstraint(NSLayoutConstraint(item: tabBarItem, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: kScrollTabBarHeight))
            containerTabBar.addConstraint(NSLayoutConstraint(item: tabBarItem, attribute: .left, relatedBy: .equal, toItem: containerTabBar, attribute: .left, multiplier: 1, constant: buttonMargin))
            containerTabBar.addConstraint(NSLayoutConstraint(item: tabBarItem, attribute: .centerY, relatedBy: .equal, toItem: containerTabBar, attribute: .centerY, multiplier: 1, constant: 0))
            buttonMargin += tabBarItem.caculateItemSize.width
        }
        tabButtonWillAppear()
    }
    
    /// Tab栏点击标题
    ///
    /// - Parameter button: 点击的Tab按钮
    fileprivate func tabItemSelectedTitle(_ button: TabBarCustomItem) {
        if let tappedIndex = containerTabBar.subviews.index(of: button), tappedIndex != selectedIndex {
            changeTabButtonAnimateWith(selectedIndex, toIndex: tappedIndex)
            selectedIndex = tappedIndex
        }
    }
    
    /// Tab栏点击Icon
    ///
    /// - Parameter button: 点击的Tab按钮
    fileprivate func tabItemSelectedIcon(_ button: TabBarCustomItem) {
        print("tabItemSelectedIcon")
    }
    
    /// 转场交互时调用进行视图设置
    ///
    /// - Parameters:
    ///   - fromIndex: 起始位置
    ///   - toIndex: 终止位置
    fileprivate func transitionViewControllerFromIndex(_ fromIndex: Int, toIndex: Int) {
        if tabChildViewControllers == nil || fromIndex == toIndex || fromIndex < 0 || toIndex < 0 || toIndex >= tabChildViewControllers!.count || (fromIndex >= tabChildViewControllers!.count && fromIndex != NSNotFound) {
            return
        }
        //called when init
        if fromIndex == NSNotFound {
            let selectedVC = tabChildViewControllers![toIndex]
            addChildViewController(selectedVC)
            privateContainerView.addSubview(selectedVC.view)
            selectedVC.didMove(toParentViewController: self)
            return
        }
        if containerTransitionDelegate != nil {
            containerTabBar.isUserInteractionEnabled = false
            
            let fromVC = tabChildViewControllers![fromIndex]
            let toVC = tabChildViewControllers![toIndex]
            containerTransitionContext = ContainerTransitionContext(containerViewController: self, containerView: privateContainerView, fromViewController: fromVC, toViewController: toVC)
            
            if interactive {
                priorSelectedIndex = fromIndex
                containerTransitionContext?.startInteractiveTranstionWith(containerTransitionDelegate!)
            } else {
                containerTransitionContext?.startNonInteractiveTransitionWith(containerTransitionDelegate!)
            }
        } else {
            //Transition Without Animation
            let priorSelectedVC = tabChildViewControllers![fromIndex]
            priorSelectedVC.willMove(toParentViewController: nil)
            priorSelectedVC.view.removeFromSuperview()
            priorSelectedVC.removeFromParentViewController()
            
            let newSelectedVC = tabChildViewControllers![toIndex]
            addChildViewController(newSelectedVC)
            privateContainerView.addSubview(newSelectedVC.view)
            newSelectedVC.didMove(toParentViewController: self)
        }
    }
}

// MARK: - 点击TabBar

extension ContainerViewController: TabBarCustomItemProtocol {
    func tabBarCustomItem(_ item: TabBarCustomItem, onClick type: TabBarTapActionType) {
        switch type {
        case .title:
            tabItemSelectedTitle(item)
        case .icon:
            tabItemSelectedIcon(item)
        }
    }
}

// MARK: - 监听

extension ContainerViewController {
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == "contentOffset", let tableView = object as? UITableView, selectedIndex != NSNotFound, let currentVC = tabChildViewControllers![selectedIndex] as? RankingTableViewController, tableView == currentVC.tableView {
            let contentOfSet = change![NSKeyValueChangeKey.newKey] as! CGPoint
            print(contentOfSet)
            print(containerTabBar.center)
            
            /// 更改伪Header视图Blur效果 + 伪Header视图联动
            if contentOfSet.y < 0 {
                let translateY = -contentOfSet.y
                let finalH = kCoverHeaderHeight + translateY
                let finalW = finalH * (kScreenWidth / kCoverHeaderHeight)
                header.bounds = CGRect(x: 0, y: 0, width: finalW, height: finalH)
                
                var headerCenter = header.center
                headerCenter.y = finalH / 2 
                header.center = headerCenter
            } else if contentOfSet.y <= kCoverHeaderHeight {
                let alpha = contentOfSet.y / kCoverHeaderHeight
                header.changeBlurView(alpha: alpha)
                header.bounds = CGRect(x: 0, y: 0, width: kScreenWidth, height: kCoverHeaderHeight)
                
                var headerCenter = header.center
                headerCenter.y = kCoverHeaderHeight / 2 - contentOfSet.y
                header.center = headerCenter
            } else {
                header.bounds = CGRect(x: 0, y: 0, width: kScreenWidth, height: kCoverHeaderHeight)
                
                var headerCenter = header.center
                headerCenter.y = kCoverHeaderHeight / 2 - contentOfSet.y
                header.center = headerCenter
            }
            
            /// containerTabBar视图联动
            var tabBarCenter = containerTabBar.center
            tabBarCenter.y = kCoverHeaderHeight + kScrollTabBarHeight / 2 - contentOfSet.y
            containerTabBar.center = tabBarCenter
            
            /// 多个表格contentOffset联动
            for innerViewController in tabChildViewControllers! {
                if let rankingViewController = innerViewController as? RankingTableViewController, rankingViewController != currentVC {
                    rankingViewController.tableView.contentOffset = contentOfSet
                }
            }
        }
    }
}
