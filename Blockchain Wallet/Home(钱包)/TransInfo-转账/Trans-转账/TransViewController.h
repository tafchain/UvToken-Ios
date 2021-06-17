//
//  TransViewController.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransViewController : UIViewController

@property (nonatomic, copy) NSString *typeString;
@property (nonatomic, copy) NSString *keyIDString;
@property (nonatomic, copy) NSString *coinTagString;
@property (nonatomic, copy) NSString *balanceString;
@property (nonatomic, copy) NSString *addressString;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *transAddrTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *transAmountTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *assetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *minerFeeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *minerFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minerFeeTransCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *slowLabel;
@property (weak, nonatomic) IBOutlet UILabel *recommendLabel;
@property (weak, nonatomic) IBOutlet UILabel *fastLabel;
@property (weak, nonatomic) IBOutlet UILabel *slowRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *recommendRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fastRateLabel;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIButton *allAmountBtn;
@property (weak, nonatomic) IBOutlet UIButton *customFeeBtn;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (weak, nonatomic) IBOutlet UITextField *addrTextField;
@property (weak, nonatomic) IBOutlet UITextField *transAmountTextField;
@property (weak, nonatomic) IBOutlet UITextField *memoTextField;

@property (weak, nonatomic) IBOutlet UIView *customFeeView;
@property (weak, nonatomic) IBOutlet UIView *gasPriceView;
@property (weak, nonatomic) IBOutlet UIView *gasView;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UITextField *gasPriceTextField;
@property (weak, nonatomic) IBOutlet UITextField *gasTextField;

@property (weak, nonatomic) IBOutlet UIImageView *arrImgView;
@property (weak, nonatomic) IBOutlet UIView *sliderView;

@property (weak, nonatomic) IBOutlet UILabel *feeAlertLabel;

//转账详情提醒View相关
@property (weak, nonatomic) IBOutlet UIView *darkBgView;
@property (weak, nonatomic) IBOutlet UIView *transDetailView;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailToAddrLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailMinerFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailRemarksLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLeftToAddrLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLeftMinerFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLeftRemarksLabel;
@property (weak, nonatomic) IBOutlet UIButton *alertConfirmBtn;

@end

NS_ASSUME_NONNULL_END
