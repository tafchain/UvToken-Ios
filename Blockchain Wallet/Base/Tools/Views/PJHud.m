//
//  PJHud.m
//  Taft
//
//  Created by panerly on 2020/11/20.
//  Copyright © 2020 panerly. All rights reserved.
//

#import "PJHud.h"
#import <objc/runtime.h>
#import "PTimer.h"

static void *phudKey = &phudKey;

@interface PJHud()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;

@end

@implementation PJHud



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.alpha = 0;
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = .4f;
        [self addSubview:_backgroundView];
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14.0f];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
        //设置小菊花的frame
        _activityIndicator.frame= CGRectMake(0, 0, 30, 30);
        //设置小菊花颜色
        _activityIndicator.color = [UIColor whiteColor];
        //设置背景颜色
//        _activityIndicator.backgroundColor = [UIColor whiteColor];
        //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
        _activityIndicator.hidesWhenStopped = NO;
        //在相应的方法里调用开始菊花和结束菊花
        [_activityIndicator startAnimating];
        [self addSubview:_activityIndicator];
        [self addSubview:_contentLabel];
    }
    return self;
}


+ (void)showWithString:(NSString *)string BackGroudnColor:(UIColor *)color loading:(BOOL)loading duration:(CGFloat)duration AutoHide:(BOOL)autoHide{
    
    if (!string || !color) {
        return;
    }
    
    
    [[PTimer sharedInstance] checkExistTimer:@"PJHud" completion:^(BOOL doExist) {
        [[PTimer sharedInstance] cancelTimerWithName:@"PJHud"];
    }];
    
    UIView *view = [UIApplication sharedApplication].keyWindow;
    
    PJHud *hud = objc_getAssociatedObject(view, phudKey);
    if (!hud) {
        hud = [[PJHud alloc] init];
        objc_setAssociatedObject(view, phudKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    hud.contentLabel.text = string;
    
    // layout
    CGSize size = CGSizeMake(KScreenWidth-38*2, 62);
    
    hud.contentLabel.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGFloat strSize = [string boundingRectWithSize:CGSizeMake(KScreenWidth, 62) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.width;
    
    if (loading) {
        
        [hud.activityIndicator startAnimating];
        [hud.activityIndicator mas_remakeConstraints:^(MASConstraintMaker *make) {

            make.left.equalTo(hud.mas_centerX).with.offset(-strSize/2-30-10);
            make.size.equalTo(CGSizeMake(30, 30));
            make.centerY.equalTo(hud.contentLabel.centerY);
        }];
    }else{
        
        [hud.activityIndicator stopAnimating];
        [hud.activityIndicator removeFromSuperview];
    }
    
    hud.bounds = CGRectMake(0, 0, size.width, size.height);
    hud.center = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 8);
    hud.backgroundColor = color;
    
    if (hud.superview) {
        
        [hud removeFromSuperview];
    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        [view addSubview:hud];
//        [UIView animateWithDuration:0.3 animations:^{
//
//                             hud.alpha = 1;
//                         } completion:^(BOOL finished) {
//
//                             if (autoHide) {
//
//                                 [UIView animateWithDuration:0.3 delay:duration options:0 animations:^{
//
//                                     hud.alpha = 0;
//                                 } completion:^(BOOL finished) {
//
//                                     [hud removeFromSuperview];
//                                 }
//                                  ];
//                             }
//                         }
//         ];
//    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [view addSubview:hud];
        
        hud.alpha = 1;
        
        [self exChangeOut:hud dur:duration autoHide:autoHide];
    });
    
}

+ (void)hide{
    
    UIView *view = [UIApplication sharedApplication].keyWindow;
    PJHud *hud= objc_getAssociatedObject(view, phudKey);
    if (!view || !hud) {
        return;
    }
    
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         hud.alpha = 0;
//                     }
//                     completion:^(BOOL finished) {
//                         [hud removeFromSuperview];
//                     }];
    [self hideHud:view dur:.3];
}


+ (void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur autoHide:(BOOL)autoHide{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = .5f;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.1, -100, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(1.0, 10, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(1.0, -10, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(1.0, 1.0, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    [changeOutView.layer addAnimation:animation forKey:nil];
    
    if (autoHide) {
        
//        PWS(weakSelf);
//        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((dur-.5f) * NSEC_PER_SEC));
//
//        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//            [weakSelf hideHud:changeOutView dur:.3];
//        });
        
        
        PWS(weakSelf);
        __block int count = 0;
        [[PTimer sharedInstance] scheduledDispatchTimerWithName:@"PJHud" timeInterval:(dur-.5f) queue:dispatch_get_main_queue() repeats:YES fireInstantly:YES action:^{
            count++;
            if (count > 1) {
                
                [weakSelf hideHud:changeOutView dur:.3];
            }
        }];
    }
}

+ (void)hideHud:(UIView *)changeOutView dur:(CFTimeInterval)dur{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = dur;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.1, 10, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(1.2, -200, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    [changeOutView.layer addAnimation:animation forKey:nil];
    
    PWS(weakSelf);
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC));

    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        
        [weakSelf removeAction];
    });
}

+ (void)removeAction{
    
    UIView *view = [UIApplication sharedApplication].keyWindow;
    PJHud *hud= objc_getAssociatedObject(view, phudKey);
    [hud removeFromSuperview];
}


//- (void)up{
//
////    UIView *view = [UIApplication sharedApplication].keyWindow;
////    PJHud *hud= objc_getAssociatedObject(view, phudKey);
////
////    [UIView animateWithDuration:2 animations:^{
////         hud.frame = CGRectMake(SIZE.width/2.0 - 30, self.animationView.frame.origin.y + 10, 60, 60);
////    }];
////    [UIView animateWithDuration:2 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
////        self.animationView.frame = CGRectMake(SIZE.width/2.0 - 30, self.animationView.frame.origin.y - 10, 60, 60);
////    } completion:^(BOOL finished) {
////        [self up];
////    }];
//}

@end
