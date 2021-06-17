//
//  UITextField+BottomLayer.m
//  Taft
//
//  Created by panerly on 2020/11/18.
//  Copyright © 2020 panerly. All rights reserved.
//

#import "UITextField+BottomLayer.h"
#import <objc/runtime.h>


@implementation UITextField (BottomLayer)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Class class = [self class];
//
//        SEL originalSelector = @selector(becomeFirstResponder);
//        SEL swizzledSelector = @selector(pj_becomeFirstResponder);
//
//        Method originalMethod = class_getInstanceMethod(class, originalSelector);
//        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//
//        BOOL didAddMethod = class_addMethod(class,
//                                            originalSelector,
//                                            method_getImplementation(swizzledMethod),
//                                            method_getTypeEncoding(swizzledMethod));
//
//        if (didAddMethod) {
//            class_replaceMethod(class,
//                                swizzledSelector,
//                                method_getImplementation(originalMethod),
//                                method_getTypeEncoding(originalMethod));
//        } else {
//            method_exchangeImplementations(originalMethod, swizzledMethod);
//        }
//
//
//
//        SEL originalSelectorResi = @selector(resignFirstResponder);
//        SEL swizzledSelectorResi = @selector(pj_resignFirstResponder);
//
//        Method originalMethodResi = class_getInstanceMethod(class, originalSelectorResi);
//        Method swizzledMethodResi = class_getInstanceMethod(class, swizzledSelectorResi);
//
//        BOOL didAddMethodResi = class_addMethod(class,
//                                            originalSelectorResi,
//                                            method_getImplementation(swizzledMethodResi),
//                                            method_getTypeEncoding(swizzledMethodResi));
//
//        if (didAddMethodResi) {
//            class_replaceMethod(class,
//                                swizzledSelector,
//                                method_getImplementation(originalMethodResi),
//                                method_getTypeEncoding(originalMethodResi));
//        } else {
//            method_exchangeImplementations(originalMethodResi, swizzledMethodResi);
//        }
//    });
//}


#pragma mark - Method Swizzling

- (void)pj_becomeFirstResponder {
    
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [UIColor blueColor].CGColor;
    bottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height - 1, KScreenWidth-20*2, 1.0f);
    bottomBorder.backgroundColor = [UIColor blueColor].CGColor;
    [self.layer addSublayer:bottomBorder];

    [self pj_becomeFirstResponder];
}

- (void)pj_resignFirstResponder{
    
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
    bottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height - 1, KScreenWidth-20*2, 1.0f);
    bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:bottomBorder];
    [self pj_resignFirstResponder];
}

@end
