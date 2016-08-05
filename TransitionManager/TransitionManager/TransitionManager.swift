//
//  TransitionManager.swift
//  Transition
//
//  Created by Cem Olcay on 12/02/15.
//  Copyright (c) 2015 Cem Olcay. All rights reserved.
//

import UIKit

protocol TransitionManagerDelegate {

    /// Transition animation method implementation
    func transition(
        container: UIView,
        fromViewController: UIViewController,
        toViewController: UIViewController,
        isDismissing: Bool,
        duration: TimeInterval,
        completion: () -> Void)

    /// Interactive transitions,
    /// update percent in gesture handler
    var interactionTransitionController: UIPercentDrivenInteractiveTransition? { get set }
}

class TransitionManagerAnimation: NSObject, TransitionManagerDelegate {

    // MARK: TransitionManagerDelegate

    func transition(
        container: UIView,
        fromViewController: UIViewController,
        toViewController: UIViewController,
        isDismissing: Bool,
        duration: TimeInterval,
        completion: () -> Void) {
        completion()
    }

    private var _interactionTransitionController: UIPercentDrivenInteractiveTransition? = nil
    var interactionTransitionController: UIPercentDrivenInteractiveTransition? {
        get {
            return _interactionTransitionController
        } set {
            _interactionTransitionController = newValue
        }
    }
}

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {

    // MARK: Properties

    private var transitionAnimation: TransitionManagerAnimation!
    private var isDismissing: Bool = false
    private var duration: TimeInterval = 0.30

    // MARK: Lifecycle

    init (transitionAnimation: TransitionManagerAnimation) {
        self.transitionAnimation = transitionAnimation
    }

    // MARK: UIViewControllerAnimatedTransitioning

    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)
        transitionAnimation.transition(
        container: container,
        fromViewController: fromViewController!,
        toViewController: toViewController!,
        isDismissing: isDismissing,
        duration: transitionDuration(transitionContext),
        completion: {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }

    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    // MARK: UIViewControllerTransitioningDelegate

    func animationController(forPresentedController presented: UIViewController,
                             presenting: UIViewController,
        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            isDismissing = false
            return self
    }

    func animationController(forDismissedController dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            isDismissing = true
            return self
    }

    func interactionController(forPresentation animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        isDismissing = false
        return transitionAnimation.interactionTransitionController
    }

    func interactionController(forDismissal animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        isDismissing = true
        return transitionAnimation.interactionTransitionController
    }

    // MARK: UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            isDismissing = true
        } else {
            isDismissing = false
        }
        return self
    }

    func navigationController(_ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return transitionAnimation.interactionTransitionController
    }
}
