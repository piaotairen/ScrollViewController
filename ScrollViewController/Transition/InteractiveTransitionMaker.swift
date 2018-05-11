//
//  InteractiveTransitionMaker.swift
//  Livestar.swift
//
//  Created by Cobb on 2017/7/10.
//  Copyright © 2017年 Cobb. All rights reserved.
//

import UIKit

/// 转场辅助类的协议
@objc protocol InteractiveTransitionMakerProtocol {
    
    /// 生成实现转场的动画协议的类
    ///
    /// - Parameters:
    ///   - containerController: 转场所在控制器
    ///   - fromVc: 转场前控制器
    ///   - toVc: 转场后控制器
    /// - Returns: 返回动画协议的类
    func containerController(_ containerController: ContainerViewController,  animationControllerForTransitionFromViewController fromVc: UIViewController, toViewController toVc: UIViewController) -> UIViewControllerAnimatedTransitioning?
    
    /// 生成实现转场的协议的类
    ///
    /// - Parameters:
    ///   - containerController: 转场所在控制器
    ///   - animationController: 遵循动画协议的控制器
    /// - Returns: 返回实现转场的协议的类
    @objc optional func containerController(_ containerController: ContainerViewController, interactionControllerForAnimation animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
}

/// 转场辅助类 生成对应的转场协议类
class InteractiveTransitionMaker: NSObject, InteractiveTransitionMakerProtocol {
    
    /// 手势交互转场控制器
    var interactionController = PercentDrivenInteractive()
    
    /// 协议方法 见 InteractiveTransitionMakerProtocol
    func containerController(_ containerController: ContainerViewController, animationControllerForTransitionFromViewController fromVc: UIViewController, toViewController toVc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fromIndex = containerController.tabChildViewControllers!.index(of: fromVc)!
        let toIndex = containerController.tabChildViewControllers!.index(of: toVc)!
        let tabChangeDirection: TabOperationDirection = toIndex < fromIndex ? TabOperationDirection.left : TabOperationDirection.right
        let transitionType = TransitionType.tabTransition(direction: tabChangeDirection)
        let slideAnimationController = AnimationTransitionController(type: transitionType, bind:true)
        return slideAnimationController
    }
    
    /// 协议方法 见 InteractiveTransitionMakerProtocol
    func containerController(_ containerController: ContainerViewController, interactionControllerForAnimation animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}
