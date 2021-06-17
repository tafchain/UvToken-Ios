//
//  PJNav.m
//  Dow
//
//  Created by panerly on 2019/3/4.
//  Copyright © 2019 panerly. All rights reserved.
//

#import "PJNav.h"

@interface PJNav ()

@end

@implementation PJNav

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.hidden = NO;
//    self.navigationBar.barStyle        = UIStatusBarStyleDefault;
    self.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationBar setTintColor:[UIColor grayColor]];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUI) name:CHANGELANGUAGE object:nil];
}

- (void)setUI{
    
    for (UIViewController *VC in self.childViewControllers) {
        
        DLog(@"导航栏下控制器---%@", [VC class]);
        NSString *vcStr = NSStringFromClass([VC class]);
        if ([vcStr isEqualToString:@"WalletViewController"]) {
            
            VC.title = Localized(@"钱包");
        }else if ([vcStr isEqualToString:@"MarketViewController"]) {
            
            VC.title = Localized(@"行情");
        }else if ([vcStr isEqualToString:@"MyViewController"]) {
            
            VC.title = Localized(@"我的");
        }else if ([vcStr isEqualToString:@"TradeViewController"]) {
            
            VC.title = Localized(@"交易");
        }
    }
}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item{
    
    self.navigationBar.topItem.title = @"";
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = [UIImage imageNamed:@"icon_back"];
    
    [UINavigationBar appearance].backIndicatorImage = [UIImage imageNamed:@"icon_back"];
    return YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {

    if (self.childViewControllers.count > 0) {

        viewController.hidesBottomBarWhenPushed = YES;
    }

    [super pushViewController:viewController animated:animated];
}

- (void)showViewController:(UIViewController *)vc sender:(id)sender{
    if (self.childViewControllers.count > 0) {
        vc.hidesBottomBarWhenPushed = YES;
    }
    [super showViewController:vc sender:sender];
}

//- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
//    [super popViewControllerAnimated:animated];
//    NSString *goBack =  [[NSUserDefaults standardUserDefaults] objectForKey:@"webCanGoBack"];
//    if ([goBack isEqualToString:@"YES"]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"webGoBack" object:nil];
//        return nil;
//    }
//    return self.childViewControllers[0];
//}

- (void)backBtnClick {
    [self popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
