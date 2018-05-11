//
//  AnimationTransitionController.swift
//  ScrollViewController
//
//  Created by Cobb on 2018/5/4.
//  Copyright © 2018年 Cobb. All rights reserved.
//

import UIKit

/// 转场类型枚举
///
/// - navigationTransition: 导航转场
/// - tabTransition: tabBar转场
/// - modalTransition: 模态转场
enum TransitionType {
    case navigationTransition(operation: UINavigationControllerOperation)
    case tabTransition(direction: TabOperationDirection)
    case modalTransition(operation: ModalOperation)
}

/// tabBar转场方向
///
/// - left: 左
/// - right: 右
enum TabOperationDirection {
    case left, right
}

/// 模态转场类型
///
/// - presentation: 呈现
/// - dismissal: 消失
enum ModalOperation {
    case presentation, dismissal
}

/// 控制转场的动画类
class AnimationTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// 转场类型
    fileprivate var transitionType: TransitionType
    
    /// 控制转场变换
    fileprivate var transitionBind: Bool
    
    /// 实例化
    ///
    /// - Parameters:
    ///   - type: 转场类型
    ///   - bind: 控制转场变换
    init(type: TransitionType, bind:Bool) {
        transitionType = type
        transitionBind = bind
        super.init()
    }
    
    /// 转场时间
    ///
    /// - Parameter transitionContext: 转场context上下文
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    /// 转场具体实现
    ///
    /// - Parameter transitionContext: 转场context上下文
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        
        let fromView = fromVC.view
        let toView = toVC.view
        var translation = containerView.frame.width
        var toViewTransform = CGAffineTransform.identity
        var fromViewTransform = CGAffineTransform.identity
        
        switch transitionType {
        case .navigationTransition(let operation):
            translation = operation == .push ? translation : -translation
            toViewTransform = CGAffineTransform(translationX: translation, y: 0)
            fromViewTransform = CGAffineTransform(translationX: -translation, y: 0)
        case .tabTransition(let direction):
            translation = direction == .left ? translation : -translation
            fromViewTransform = CGAffineTransform(translationX: translation, y: 0)
            toViewTransform = CGAffineTransform(translationX: -translation, y: 0)
        case .modalTransition(let operation):
            translation =  containerView.frame.height
            toViewTransform = CGAffineTransform(translationX: 0, y: (operation == .presentation ? translation : 0))
            fromViewTransform = CGAffineTransform(translationX: 0, y: (operation == .presentation ? 0 : translation))
        }
        
        switch transitionType {
        case .modalTransition(let operation):
            switch operation {
            case .presentation:
                containerView.addSubview(toView!)
            case .dismissal:
                break
            }
        default:
            containerView.addSubview(toView!)
        }
        
        toView?.transform = toViewTransform
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            if (self.transitionBind) {
                fromView?.transform = fromViewTransform
            }
            toView?.transform = CGAffineTransform.identity
        }, completion: { finished in
            fromView?.transform = CGAffineTransform.identity
            toView?.transform = CGAffineTransform.identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
