//
//  ScrollTabBarViewController.swift
//  ScrollViewController
//
//  Created by Cobb on 2018/5/4.
//  Copyright © 2018年 Cobb. All rights reserved.
//

import UIKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

/// 可滚动手势交互的TabBar控制器
class ScrollTabBarViewController: ContainerViewController {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addInteractiveGesture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
    }
    
    // MARK: - Priavte
    
    /// 添加滑动交互手势
    private func addInteractiveGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ScrollTabBarViewController.handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    /// pan手势滑动调用 控制视图控制器切换灵敏度核心算法
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        if tabChildViewControllers == nil || tabChildViewControllers?.count < 2 || containerTransitionDelegate == nil || !(containerTransitionDelegate is InteractiveTransitionMaker) {
            return;
        }
        let delegate = containerTransitionDelegate as! InteractiveTransitionMaker
        let translationX =  gesture.translation(in: view).x
        let translationAbs = translationX > 0 ? translationX : -translationX
        let progress = translationAbs / view.frame.width
        
        switch gesture.state {
        case .began:
            interactive = true
            let velocityX = gesture.velocity(in: view).x
            if velocityX < 0 {
                if selectedIndex < tabChildViewControllers!.count - 1 {
                    selectedIndex += 1
                }
            } else {
                if selectedIndex > 0 {
                    selectedIndex -= 1
                }
            }
        case .changed:
            delegate.interactionController.updateInteractiveTransition(progress)
        case .cancelled, .ended:
            interactive = false
            if progress > 0.4 {
                delegate.interactionController.finishInteractiveTransition()
            } else {
                delegate.interactionController.cancelInteractiveTransition()
            }
        default: break
        }
    }
}
