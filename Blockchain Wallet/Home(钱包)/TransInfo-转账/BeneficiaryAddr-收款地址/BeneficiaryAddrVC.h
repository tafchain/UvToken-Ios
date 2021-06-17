//
//  BeneficiaryAddrVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeneficiaryAddrVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet UILabel *codeAddrTitleLabel;//地址二维码
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImgView;
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;//收款地址
@property (weak, nonatomic) IBOutlet UILabel *addrDetailLabel;
@property (weak, nonatomic) IBOutlet UIButton *resCopyBtn;

@property (weak, nonatomic) IBOutlet UILabel *shareCodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shareCodeImgView;
@property (weak, nonatomic) IBOutlet UILabel *shareAddrLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareAddrDetailLabel;

@property (weak, nonatomic) IBOutlet UIButton *shareActionBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelActionBtn;

@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIView *shareContentView;
@property (weak, nonatomic) IBOutlet UIView *shareDarkBgView;
@property (weak, nonatomic) IBOutlet UIView *shareActionView;
@property (weak, nonatomic) IBOutlet UIView *bottomPaddingView;

@property (nonatomic, copy) NSString *addressStr;
@property (nonatomic, copy) NSString *coinTagStr;
@property (nonatomic, copy) NSString *typeStr;

@end

NS_ASSUME_NONNULL_END
