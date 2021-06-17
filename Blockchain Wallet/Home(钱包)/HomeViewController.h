//
//  HomeViewController.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *walletNameBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewToTop;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolViewToHeight;

@end

NS_ASSUME_NONNULL_END
