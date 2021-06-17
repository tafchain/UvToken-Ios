//
//  PJTabVC.m
//  Dow
//
//  Created by panerly on 2019/3/4.
//  Copyright © 2019 panerly. All rights reserved.
//

#import "PJTabVC.h"
#import "PJNav.h"


//#import "WalletViewController.h"
#import "MarketViewController.h"
#import "TradeViewController.h"
#import "MyViewController.h"

#import "HomeViewController.h"
#import "FinancialViewController.h"
#import "FinancialNewViewController.h"

@interface PJTabVC ()

@end

@implementation PJTabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    HomeViewController *home = [HomeViewController new];
//    WalletViewController *wallet = [WalletViewController new];
    MarketViewController *market = [MarketViewController new];
    TradeViewController *tradeVC = [TradeViewController new];
    FinancialNewViewController *finVC = [FinancialNewViewController new];
    MyViewController *my = [MyViewController new];
    
    DLog(@"%@%@%@%@", Localized(@"钱包"),Localized(@"行情"),Localized(@"我的"),Localized(@"tab_account"));
    
//    [self addOneChlildVc:wallet title:Localized(@"钱包") imageName:@"home_unselect" selectedImageName:@"home_selected"];
    [self addOneChlildVc:home title:Localized(@"钱包") imageName:@"home_unselect" selectedImageName:@"home_selected"];
//    if ([SDKConfig isEqualToString:@"regtest"]) {
//
        [self addOneChlildVc:market title:Localized(@"交易") imageName:@"trade_unselect" selectedImageName:@"trade_selected"];
//    }
    if ([AECOConfig isEqualToString:@"show"]) {//交易所
        [self addOneChlildVc:tradeVC title:Localized(@"交易") imageName:@"trade_unselect" selectedImageName:@"trade_selected"];
    }
//    if ([SDKConfig isEqualToString:@"regtest"]) {
        
        [self addOneChlildVc:finVC title:Localized(@"DApp") imageName:@"licai_unselect" selectedImageName:@"licai_selected"];
//    }
    
    [self addOneChlildVc:my title:Localized(@"我的") imageName:@"my_unselect" selectedImageName:@"my_selected"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUI) name:CHANGELANGUAGE object:nil];
}

- (void)setUI{
    
    
//    if ([[PTool p_getCurrentVC] isKindOfClass:[SaleViewController class]]) {
//
//        [PTool p_getCurrentVC].title = Localized(@"tab_presale");
//    }
//    if ([[PTool p_getCurrentVC] isKindOfClass:[DiscoverViewController class]]) {
//
//        [PTool p_getCurrentVC].title = Localized(@"tab_discover");
//    }
}

- (void)addOneChlildVc:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
//    //自定义tabbarItem的颜色
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                       [UIColor blackColor], NSForegroundColorAttributeName,
//                                                       nil] forState:UIControlStateNormal];
//    UIColor *titleHighlightedColor = navigateColor;
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                       titleHighlightedColor, NSForegroundColorAttributeName,
//                                                       nil] forState:UIControlStateSelected];
//
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                       [UIFont fontWithName:@"JXK" size:13], NSFontAttributeName,
//                                                       nil] forState:UIControlStateNormal];
    
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [UITabBar appearance].translucent = NO;
    
    self.tabBar.tintColor = [UIColor blackColor];
    
    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    // 设置标题
    // 相当于同时设置了tabBarItem.title和navigationItem.title
    childVc.title = title;
    
    // 设置图标
    childVc.tabBarItem.image = [UIImage imageNamed:imageName];
    // 设置选中的图标
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    
    // 声明这张图片用原图(别渲染)
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = selectedImage;
    
    childVc.edgesForExtendedLayout = UIRectEdgeNone;
    
    [childVc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    
    // 添加为tabbar控制器的子控制器
    PJNav *nav = [[PJNav alloc] initWithRootViewController:childVc];
    [self addChildViewController:nav];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
//    NSInteger index = [self.tabBar.items indexOfObject:item];
//    //    [self animationWithIndex:index];
//    NSArray *nameArr = @[@"主页", @"资讯", @"关于", @"账户信息"];
//    NSArray *tabName = @[@"tab_home", @"tab_news", @"tab_about", @"tab_account"];
//    [LogPoint logWithMsg:nameArr[index] Formid:@"0" Type:tabName[index]];
}

@end
