//
//  ContainerTransitionContext.swift
//  ScrollViewController
//
//  Created by Cobb on 2018/5/4.
//  Copyright © 2018年 Cobb. All rights reserved.
//

import UIKit

/// 转场结束
let K_NOTIFI_TRANSITION_END = "com.phicomm.notification.transition.end"

/// 转场中断
let K_NOTIFI_TRANSITION_INTERRUPT = "livestar.Notification.InteractionEnd"

/// 转场控制核心类
class ContainerTransitionContext: NSObject, UIViewControllerContextTransitioning {
    
    // MARK: - 获取view、控制器
    
    /// 转场容器视图
    public var containerView: UIView {
        return privateContainerView
    }
    
    /// 根据指定KEY获取视图控制器
    ///
    /// - Parameter key: from、to
    /// - Returns: 返回视图控制器
    public func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        switch key {
        case UITransitionContextViewControllerKey.from:
            return privateFromViewController
        case UITransitionContextViewControllerKey.to:
            return privateToViewController
        default: return nil
        }
    }
    
    @objc @available(iOS 8.0, *)
    
    /// 根据指定KEY获取视图
    ///
    /// - Parameter key: from、to
    /// - Returns: 返回视图
    public func view(forKey key: UITransitionContextViewKey) -> UIView? {
        switch key {
        case UITransitionContextViewKey.from:
            return privateFromViewController.view
        case UITransitionContextViewKey.to:
            return privateToViewController.view
        default: return nil
        }
    }
    
    // MARK: Protocol Method - Getting the Transition Frame Rectangles
    
    /// 初始化视图Frame
    ///
    /// - Parameter vc: 视图位置
    public func initialFrame(for vc: UIViewController) -> CGRect {
        return CGRect.zero
    }
    
    /// 最终视图Frame
    ///
    /// - Parameter vc: 指定控制器
    /// - Returns: 视图位置
    public func finalFrame(for vc: UIViewController) -> CGRect {
        return vc.view.frame
    }
    
    // MARK: Protocol Method - Getting the Transition Behaviors
    
    /// present的样式
    public var presentationStyle: UIModalPresentationStyle {
        return .custom
    }
    
    // MARK: Protocol Method - Reporting the Transition Progress
    
    /// 结束转场
    ///
    /// - Parameter didComplete: 转场是否完成
    func completeTransition(_ didComplete: Bool) {
        if didComplete {
            privateToViewController.didMove(toParentViewController: privateContainerViewController)
            
            privateFromViewController.willMove(toParentViewController: nil)
            privateFromViewController.view.removeFromSuperview()
            privateFromViewController.removeFromParentViewController()
        } else {
            privateToViewController.didMove(toParentViewController: privateContainerViewController)
            
            privateToViewController.willMove(toParentViewController: nil)
            privateToViewController.view.removeFromSuperview()
            privateToViewController.removeFromParentViewController()
        }
        
        transitionEnd()
    }
    
    /// 更新转场进度
    ///
    /// - Parameter percentComplete: 转场进度百分比
    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        if animationController != nil && isInteractive == true {
            transitionPercent = percentComplete
            privateContainerView.layer.timeOffset = CFTimeInterval(percentComplete) * transitionDuration
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: percentComplete)
        }
    }
    
    /// 结束手势交互的转场
    func finishInteractiveTransition() {
        isInteractive = false
        let pausedTime = privateContainerView.layer.timeOffset
        privateContainerView.layer.speed = 1.0
        privateContainerView.layer.timeOffset = 0.0
        privateContainerView.layer.beginTime = 0.0
        let timeSincePause = privateContainerView.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        privateContainerView.layer.beginTime = timeSincePause
        
        let displayLink = CADisplayLink(target: self, selector: #selector(ContainerTransitionContext.finishChangeButtonAppear(_:)))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
        //当 ScrollTabBarViewController 作为一个子 VC 内嵌在其他容器 VC 内，比如 NavigationController 里时，在 ScrollTabBarViewController 内完成一次交互转场后
        //在外层的 NavigationController push 其他 VC 然后 pop 返回时，且仅限于交互控制，会出现 containerView 不见的情况，pop 完成后就恢复了。
        //根源在于此时 beginTime 被修改了，在转场结束后恢复为 0 就可以了。解决灵感来自于如果没有一次完成了交互转场而全部是中途取消的话就不会出现这个 Bug。
        //感谢简书用户@dasehng__ 反馈这个 Bug。
        let remainingTime = CFTimeInterval(1 - transitionPercent) * transitionDuration
        perform(#selector(ContainerTransitionContext.fixBeginTimeBug), with: nil, afterDelay: remainingTime)
    }
    
    /// 取消手势交互的转场
    func cancelInteractiveTransition() {
        isInteractive = false
        isCancelled = true
        let displayLink = CADisplayLink(target: self, selector: #selector(ContainerTransitionContext.reverseCurrentAnimation(_:)))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        NotificationCenter.default.post(name: Notification.Name(rawValue: K_NOTIFI_TRANSITION_INTERRUPT), object: self)
    }
    
    /// 转场是否被取消
    public var transitionWasCancelled: Bool {
        return isCancelled
    }
    
    // MARK: Protocol Method - Getting the Rotation Factor
    
    @available(iOS 8.0, *)
    
    /// 目标变换
    public var targetTransform: CGAffineTransform {
        return CGAffineTransform.identity
    }
    
    // MARK: Protocol Method - Pause Transition
    
    @available(iOS 10.0, *)
    
    /// 中止手势交互转场
    public func pauseInteractiveTransition() {
        
    }
    
    // MARK: Addtive Property
    
    /// 动画转场控制类
    fileprivate var animationController: UIViewControllerAnimatedTransitioning?
    
    // MARK: Private Property for Protocol Need
    
    /// 转场前视图控制器
    unowned fileprivate var privateFromViewController: UIViewController
    
    /// 转场后视图控制器
    unowned fileprivate var privateToViewController: UIViewController
    
    /// 转场容器控制器
    unowned fileprivate var privateContainerViewController: ContainerViewController
    
    /// 容器视图
    unowned fileprivate var privateContainerView: UIView
    
    // MARK: Property for Transition State
    
    /// 是否动画
    public var isAnimated: Bool {
        if animationController != nil {
            return true
        }
        return false
    }
    
    /// 是否支持手势交互
    public var isInteractive = false
    
    /// 是否取消转场
    fileprivate var isCancelled = false
    
    /// from的TabBar位置
    fileprivate var fromIndex: Int = 0
    
    /// to的TabBar位置
    fileprivate var toIndex: Int = 0
    
    /// 转场时间
    fileprivate var transitionDuration: CFTimeInterval = 0
    
    /// 转场百分比
    fileprivate var transitionPercent: CGFloat = 0
    
    // MARK: Public Custom Method
    
    /// 实例化转场控制类
    ///
    /// - Parameters:
    ///   - containerViewController: 转场所在控制器
    ///   - containerView: 容器视图
    ///   - fromVC: 转场前视图控制器
    ///   - toVC: 转场后视图控制器
    init(containerViewController: ContainerViewController, containerView: UIView, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) {
        privateContainerViewController = containerViewController
        privateContainerView = containerView
        privateFromViewController = fromVC
        privateToViewController = toVC
        fromIndex = containerViewController.tabChildViewControllers!.index(of: fromVC)!
        toIndex = containerViewController.tabChildViewControllers!.index(of: toVC)!
        super.init()
        //每次转场开始前都会生成这个对象，调整 toView 的尺寸适用屏幕
        privateToViewController.view.frame = privateContainerView.bounds
    }
    
    /// 开始手势转场
    ///
    /// - Parameter delegate: 转场协议生产者
    func startInteractiveTranstionWith(_ delegate: InteractiveTransitionMakerProtocol) {
        animationController = delegate.containerController(privateContainerViewController, animationControllerForTransitionFromViewController: privateFromViewController, toViewController: privateToViewController)
        transitionDuration = animationController!.transitionDuration(using: self)
        if privateContainerViewController.interactive == true {
            if let interactionController = delegate.containerController?(privateContainerViewController, interactionControllerForAnimation: animationController!) {
                interactionController.startInteractiveTransition(self)
            } else {
                fatalError("Need for interaction controller for interactive transition.")
            }
        } else {
            fatalError("ContainerTransitionContext's Property 'interactive' must be true before starting interactive transiton")
        }
    }
    
    /// 开始无手势转场
    ///
    /// - Parameter delegate: 转场协议生产者
    func startNonInteractiveTransitionWith(_ delegate: InteractiveTransitionMakerProtocol) {
        animationController = delegate.containerController(privateContainerViewController, animationControllerForTransitionFromViewController: privateFromViewController, toViewController: privateToViewController)
        transitionDuration = animationController!.transitionDuration(using: self)
        activateNonInteractiveTransition()
    }
    
    /// PercentDrivenInteractive's startInteractiveTransition: will call this method
    func activateInteractiveTransition() {
        isInteractive = true
        isCancelled = false
        privateContainerViewController.addChildViewController(privateToViewController)
        privateContainerView.layer.speed = 0
        animationController?.animateTransition(using: self)
    }
    
    // MARK: Private Helper Method
    
    /// 进行无手势转场处理
    fileprivate func activateNonInteractiveTransition() {
        isInteractive = false
        isCancelled = false
        privateContainerViewController.addChildViewController(privateToViewController)
        animationController?.animateTransition(using: self)
    }
    
    /// 转场结束
    fileprivate func transitionEnd() {
        if animationController != nil && animationController!.responds(to: #selector(UIViewControllerAnimatedTransitioning.animationEnded(_:))) == true {
            animationController!.animationEnded!(!isCancelled)
        }
        //If transition is cancelled, recovery data.
        if isCancelled {
            privateContainerViewController.restoreSelectedIndex()
            isCancelled = false
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: K_NOTIFI_TRANSITION_END), object: self)
    }
    
    //修复内嵌在其他容器 VC 交互返回的转场中 containerView 消失并且的转场结束后自动恢复的 Bug。
    @objc fileprivate func fixBeginTimeBug() {
        privateContainerView.layer.beginTime = 0.0
    }
    
    /// 反转当前动画
    ///
    /// - Parameter displayLink: 定时器
    @objc fileprivate func reverseCurrentAnimation(_ displayLink: CADisplayLink) {
        let timeOffset = privateContainerView.layer.timeOffset - displayLink.duration
        if timeOffset > 0 {
            privateContainerView.layer.timeOffset = timeOffset
            transitionPercent = CGFloat(timeOffset / transitionDuration)
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: transitionPercent)
        } else {
            displayLink.invalidate()
            privateContainerView.layer.timeOffset = 0
            privateContainerView.layer.speed = 1
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: 0)
            
            //修复闪屏Bug: speed 恢复为1后，动画会立即跳转到它的最终状态，而 fromView 的最终状态是移动到了屏幕之外，因此在这里添加一个假的掩人耳目。
            //为何不等 completion block 中恢复 fromView 的状态后再恢复 containerView.layer.speed，事实上那样做无效，原因未知。
            let fakeFromView = privateFromViewController.view.snapshotView(afterScreenUpdates: false)
            privateContainerView.addSubview(fakeFromView!)
            perform(#selector(ContainerTransitionContext.removeFakeFromView(_:)), with: fakeFromView, afterDelay: 1/60)
        }
    }
    
    /// 删除截屏的视图
    ///
    /// - Parameter fakeView: 截屏的视图
    @objc fileprivate func removeFakeFromView(_ fakeView: UIView) {
        fakeView.removeFromSuperview()
    }
    
    /// 结束转场按钮布局
    ///
    /// - Parameter displayLink: 定时器
    @objc fileprivate func finishChangeButtonAppear(_ displayLink: CADisplayLink) {
        let percentFrame = 1 / (transitionDuration * 60)
        transitionPercent += CGFloat(percentFrame)
        if transitionPercent < 1.0 {
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: transitionPercent)
        } else {
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: 1)
            displayLink.invalidate()
        }
    }
}
