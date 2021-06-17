//
//  PJHud.h
//  Taft
//
//  Created by panerly on 2020/11/20.
//  Copyright © 2020 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PJHud : UIView

+ (void)showWithString:(NSString *)string BackGroudnColor:(UIColor *)color loading:(BOOL)loading duration:(CGFloat)duration AutoHide:(BOOL)autoHide;

+ (void)hide;

@end

NS_ASSUME_NONNULL_END
