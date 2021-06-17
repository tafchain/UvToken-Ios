//
//  PJPopTransition.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/25.
//

#import "PJPopTransition.h"
#import "WalletViewController.h"
#import "ScanViewController.h"

@implementation PJPopTransition{
    id<UIViewControllerContextTransitioning> _transitionContext;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return .5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _transitionContext = transitionContext;
    ScanViewController *fromVC = (ScanViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    WalletViewController *toVC = (WalletViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *contentView = [transitionContext containerView];
    [contentView addSubview:toVC.view];
    [contentView addSubview:fromVC.view];
    
    UIButton *pushBtn = toVC.scanBtn;
    
    CGPoint finalPoint = pushBtn.center;
    CGPoint startPoint = CGPointMake(0, [UIScreen mainScreen].bounds.size.height);
    
    UIBezierPath *maskLayerFinalPath = [UIBezierPath bezierPathWithOvalInRect:pushBtn.frame];
    
    double radius = sqrt((pow(finalPoint.x, 2) + pow(startPoint.y, 2)));
    
    UIBezierPath *maskLayerStartPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(pushBtn.frame, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskLayerFinalPath.CGPath;
    fromVC.view.layer.mask = maskLayer;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    maskLayerAnimation.delegate = self;
    
    maskLayerAnimation.fromValue = (__bridge id)(maskLayerStartPath.CGPath);
    maskLayerAnimation.toValue = (__bridge id)(maskLayerFinalPath.CGPath);
    maskLayerAnimation.duration = .5f;
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [maskLayer addAnimation:maskLayerAnimation forKey:@"popPath"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    [_transitionContext completeTransition:![_transitionContext transitionWasCancelled]];
    [_transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [_transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
}

@end
