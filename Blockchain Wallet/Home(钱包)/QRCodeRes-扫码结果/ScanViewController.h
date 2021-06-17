//
//  ScanViewController.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface ScanViewController : UIViewController

typedef void(^ScanBlock)(NSString *scanResultStr);

@property (weak, nonatomic) IBOutlet UIView *naviView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *albumBtn;

@property (nonatomic, copy) ScanBlock scanBlock;
@property (nonatomic, strong) NSString *returnRes;

@end

NS_ASSUME_NONNULL_END
