//
//  PercentDrivenInteractive.swift
//  ScrollViewController
//
//  Created by Cobb on 2018/5/4.
//  Copyright © 2018年 Cobb. All rights reserved.
//

import UIKit

/// 手势控制的转场类 
class PercentDrivenInteractive: NSObject, UIViewControllerInteractiveTransitioning {
    
    /// 转场协议类
    weak var containerTransitionContext: ContainerTransitionContext?
    
    /// 开始手势转场
    ///
    /// - Parameter transitionContext: 转场协议类
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        if let context = transitionContext as? ContainerTransitionContext {
            containerTransitionContext = context
            containerTransitionContext?.activateInteractiveTransition()
        } else {
            fatalError("\(transitionContext) is not class or subclass of ContainerTransitionContext")
        }
    }
    
    /// 更新转场百分比
    ///
    /// - Parameter percentComplete: 百分比
    func updateInteractiveTransition(_ percentComplete: CGFloat){
        containerTransitionContext?.updateInteractiveTransition(percentComplete)
    }
    
    /// 取消转场
    func cancelInteractiveTransition(){
        containerTransitionContext?.cancelInteractiveTransition()
    }
    
    /// 完成转场
    func finishInteractiveTransition(){
        containerTransitionContext?.finishInteractiveTransition()
    }
}
