//
//  UITextField+BottomLayer.h
//  Taft
//
//  Created by panerly on 2020/11/18.
//  Copyright © 2020 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (BottomLayer)

+ (void)pj_becomeFirstResponder;
+ (void)pj_resignFirstResponder;

+ (void)addBorderLayer;
@end

NS_ASSUME_NONNULL_END
