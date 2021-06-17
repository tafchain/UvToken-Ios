//
//  PJToastView.h
//  cocolion
//
//  Created by panerly on 2018/9/14.
//  Copyright © 2018 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PJToastView : UIView

+ (void)showInView:(nonnull UIView *)view text:(nonnull NSString *)text duration:(CGFloat)duration autoHide:(BOOL)autoHide;
+ (void)hideInView:(nonnull UIView *)view;
+ (BOOL)isShowingInView:(nonnull UIView *)view;

@end

NS_ASSUME_NONNULL_END
