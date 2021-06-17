//
//  PJPushTransiton.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/25.
//

#import "PJPushTransiton.h"
#import "WalletViewController.h"
#import "ScanViewController.h"

@implementation PJPushTransiton{
    id<UIViewControllerContextTransitioning> _transitionContext;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return .5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _transitionContext = transitionContext;
    WalletViewController *fromVC = (WalletViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ScanViewController *toVC = (ScanViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *contentView = [transitionContext containerView];
    
    [contentView addSubview:fromVC.view];
    [contentView addSubview:toVC.view];
    
    UIButton *pushBtn = fromVC.scanBtn;
    CGPoint startPoint = pushBtn.center;
    
    CGPoint finalPoint = CGPointMake(0, [UIScreen mainScreen].bounds.size.height);
    
    UIBezierPath *maskLayerStartPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(pushBtn.center.x, pushBtn.center.y, 0, 0)];
    double radius = sqrt(pow(startPoint.x, 2) + pow((finalPoint.y - startPoint.y), 2));
    UIBezierPath *maskLayerFinalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(pushBtn.frame, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskLayerFinalPath.CGPath;
    toVC.view.layer.mask = maskLayer;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.delegate = self;
    
    maskLayerAnimation.fromValue = (__bridge id)(maskLayerStartPath.CGPath);
    maskLayerAnimation.toValue = (__bridge id)(maskLayerFinalPath.CGPath);
    maskLayerAnimation.duration = .5f;
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [maskLayer addAnimation:maskLayerAnimation forKey:@"pushPath"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [_transitionContext completeTransition:![_transitionContext transitionWasCancelled]];
    [_transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [_transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
}
@end
