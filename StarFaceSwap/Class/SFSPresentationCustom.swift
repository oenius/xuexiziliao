//
//  SFSTransitioningDelegate.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

class SFSTransitioningDelegate: NSObject {
    
    static let instance = SFSTransitioningDelegate()
    
    fileprivate var isPresent:Bool = false
    fileprivate var duration:TimeInterval = 0.5
    
    
    static func shareInstance() -> SFSTransitioningDelegate {
        return instance
    }
    
    
    
}

extension SFSTransitioningDelegate:UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate{
    //MARK:UIViewControllerTransitioningDelegate
    
    //返回一个继承UIPresentationController的对象
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let present = SFSPresentationController(presentedViewController: presented, presenting: presenting)
        return present
    }
    
    //返回一个遵守UIViewControllerAnimatedTransitioning的对象，这里是self
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = true
        return self
    }
    //返回一个遵守UIViewControllerAnimatedTransitioning的对象，这里是self
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = false
        return self
    }
    
    //MARK:UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            let toView = transitionContext.view(forKey: .to)
            toView?.alpha = 0.0
            UIView.animate(withDuration: duration, animations: { 
                toView?.alpha = 1.0
                }, completion: { (compled) in
                    transitionContext.completeTransition(true)
            })
        }
        else{
            let fromView = transitionContext.view(forKey: .from)
            fromView?.alpha = 1.0
            UIView.animate(withDuration: duration, animations: {
                fromView?.alpha = 0.0
                }, completion: { (compled) in
                    transitionContext.completeTransition(true)
            })
        }
    }
}


class SFSPresentationController: UIPresentationController {
    
    fileprivate var guoduView:UIView?
    
    override func presentationTransitionWillBegin() {
        guoduView = UIView(frame: (self.containerView?.bounds)!)
        guoduView?.alpha = 0.0
        
        self.containerView?.addSubview(guoduView!)
        
        self.presentedView?.frame = (self.containerView?.bounds)!
        self.containerView?.addSubview(self.presentedView!)
        
        // 与过渡效果一起执行背景 View 的淡入效果
        weak var weakSelf = self
        self.presentedViewController.transitionCoordinator?.animateAlongsideTransition(in: guoduView, animation: { (context) in
                weakSelf?.guoduView?.alpha = 1.0
            }, completion: { (context) in
                
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            guoduView?.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        // 与过渡效果一起执行背景 View 的淡入效果
        weak var weakSelf = self
        self.presentedViewController.transitionCoordinator?.animateAlongsideTransition(in: guoduView, animation: { (context) in
            weakSelf?.guoduView?.alpha = 0.0
            }, completion: { (context) in
                
        })
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.presentedView?.removeFromSuperview()
            guoduView?.removeFromSuperview()
        }
    }
    
}


















