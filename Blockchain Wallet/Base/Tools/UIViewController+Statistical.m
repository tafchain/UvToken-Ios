//
//  UIViewController+Statistical.m
//  Taft
//
//  Created by panerly on 2020/11/13.
//  Copyright © 2020 panerly. All rights reserved.
//

#import "UIViewController+Statistical.h"
#import <objc/runtime.h>

@implementation UIViewController (Statistical)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(pj_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
//        //拦截 “setValue:forKey:”方法，替换自定义实现
//        SEL originalSetSelector = @selector(setValue:forKey:);
//        SEL swizzledSetSelector = @selector(pj_setValue:forKey:);
//        Method originalSetMethod = class_getInstanceMethod([NSObject class], originalSetSelector);
//        Method swizzledSetMethod = class_getInstanceMethod([NSObject class], swizzledSetSelector);
//
//        BOOL didAddSetMethod = class_addMethod([NSObject class], originalSetMethod, method_getImplementation(swizzledSetMethod), method_getImplementation(swizzledSetMethod));
//        if (didAddSetMethod) {
//            class_replaceMethod([NSObject class], swizzledSetSelector, method_getImplementation(originalSetMethod), method_getImplementation(originalSetMethod));
//        }else{
//            method_exchangeImplementations(originalSetMethod, swizzledSetMethod);
//        }
        
//        //拦截 “objectForKey:”方法，替换自定义实现
//        SEL originalObjcSelector = @selector(objectForKey:);
//        SEL swizzledObjcSelector = @selector(pj_objectForKey:);
//        Method originalObjcMethod = class_getInstanceMethod([NSObject class], originalObjcSelector);
//        Method swizzledObjcMethod = class_getInstanceMethod([NSObject class], swizzledObjcSelector);
//
//        BOOL didAddObjcMethod = class_addMethod([NSObject class], originalObjcMethod, method_getImplementation(swizzledObjcMethod), method_getImplementation(swizzledObjcMethod));
//        if (didAddObjcMethod) {
//            class_replaceMethod([NSObject class], swizzledObjcSelector, method_getImplementation(originalObjcMethod), method_getImplementation(originalObjcMethod));
//        }else{
//            method_exchangeImplementations(originalObjcMethod, swizzledObjcMethod);
//        }
    });
}


#pragma mark - Method Swizzling

- (void)pj_viewWillAppear:(BOOL)animated {
    
    // 去除 UIViewController、UINavigationController 等系统根控制器相关统计影响。
    // 这个看需求。去除是因为一般项目中控制器直接使用 UIViewController 的不多。
    
    Class nav = NSClassFromString(@"PJNav");
    Class tab = NSClassFromString(@"PJTabVC");
    Class input = NSClassFromString(@"UIInputWindowController");
    Class edit = NSClassFromString(@"UIEditingOverlayViewController");
    NSString *navStr = NSStringFromClass(nav);
    NSString *tabStr = NSStringFromClass(tab);
    NSString *classStr = NSStringFromClass([self class]);
    
    if (![self isMemberOfClass:[UIViewController class]] &&
        ![self isMemberOfClass:[UINavigationController class]] &&
        ![self isMemberOfClass:[UITabBarController class]] &&
        ![self isMemberOfClass:input] &&
        ![self isMemberOfClass:edit] &&
        ![classStr isEqualToString:navStr] &&
        ![classStr isEqualToString:tabStr]
        ) {
        // 添加统计代码
        NSLog(@"进入页面：%@", [self class]);
    }
    
    [self pj_viewWillAppear:animated];
}

- (void)pj_setValue:(id)value forKey:(NSString *)key{
    if (value == nil) {
        NSString *crashMessage = [NSString stringWithFormat:@"crashMessage:%@ setNilValue", key];
        NSLog(@"%@", crashMessage);
    }
    [self pj_setValue:value forKey:key];
}
//- (void)pj_objectForKey:(NSString *)key{
//
//    [self pj_objectForKey:key];
//}

@end
