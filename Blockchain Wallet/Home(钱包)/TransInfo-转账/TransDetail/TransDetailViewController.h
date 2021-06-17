//
//  TransDetailViewController.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/3/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransDetailViewController : UIViewController

@property (nonatomic, copy) NSString *currencyType;
@property (nonatomic, copy) NSString *coinTagString;
@property (nonatomic, copy) NSString *status;

@property (nonatomic, copy) NSString *moneyStr;
@property (nonatomic, copy) NSString *minerFeeStr;
@property (nonatomic, copy) NSString *receiveAddrStr;
@property (nonatomic, copy) NSString *payAddrStr;
@property (nonatomic, copy) NSString *tradeNumStr;
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *memoStr;
@property (nonatomic, copy) NSString *addrStr;//本币地址
@property (nonatomic, copy) NSString *gasPrice;
@property (nonatomic, assign) NSInteger action;//0:
@property (nonatomic, assign) BOOL showSpeedUpBtnView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

//左侧描述
@property (weak, nonatomic) IBOutlet UILabel *moneyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *minerFeeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveAddrTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *payAddrTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tradeNumTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *queryDetailTitleLabel;

//右侧数值
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *minerFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveAddrLabel;
@property (weak, nonatomic) IBOutlet UILabel *payAddrLabel;
@property (weak, nonatomic) IBOutlet UILabel *tradeNumLabel;

//
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *baseViewHeight;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *minerFeeLineViewPadding;
@property (weak, nonatomic) IBOutlet UIView *minerFeeLineView;

@property (weak, nonatomic) IBOutlet UIButton *receiveAddrCopyBtn;
@property (weak, nonatomic) IBOutlet UIButton *payAddrCopyBtn;
@property (weak, nonatomic) IBOutlet UILabel *memoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;

//加速
@property (weak, nonatomic) IBOutlet UIView *speedupBtnView;//只有pendding状态才显示
@property (weak, nonatomic) IBOutlet UIButton *cancelSpeedBtn;//取消加速按钮
@property (weak, nonatomic) IBOutlet UIButton *speedBtn;//加速按钮

//加速弹出view
@property (weak, nonatomic) IBOutlet UIView *speedView;
@property (weak, nonatomic) IBOutlet UIView *speedDarkBgView;
@property (weak, nonatomic) IBOutlet UIView *speedupContentView;
@property (weak, nonatomic) IBOutlet UIImageView *speedupLogo;

@property (weak, nonatomic) IBOutlet UILabel *sTitleLabel;//交易加速、取消交易title
@property (weak, nonatomic) IBOutlet UILabel *sPayInfoTitle;//支付信息title
@property (weak, nonatomic) IBOutlet UILabel *sReceiveTitleLabel;//收款地址title
@property (weak, nonatomic) IBOutlet UILabel *sPayAddrTitleLabel;//付款地址title
@property (weak, nonatomic) IBOutlet UILabel *sTxIdTitleLabel;//交易哈希值title
@property (weak, nonatomic) IBOutlet UILabel *sSpeedUpTitleLabel;//加速交易title
@property (weak, nonatomic) IBOutlet UILabel *sBeforeTitleLabel;//加速前title
@property (weak, nonatomic) IBOutlet UILabel *sAfterTitleLabel;//加速后title
@property (weak, nonatomic) IBOutlet UILabel *sMinerFeeTitleLabel;//矿工费title

@property (weak, nonatomic) IBOutlet UILabel *sAmountLabel;//交易金额
@property (weak, nonatomic) IBOutlet UILabel *sReceiveLabel;//收款地址
@property (weak, nonatomic) IBOutlet UILabel *sPayAddrLabel;//付款地址
@property (weak, nonatomic) IBOutlet UILabel *sTxIdLabel;//交易哈希值
@property (weak, nonatomic) IBOutlet UIButton *sRecommandBtn;//推荐btn
@property (weak, nonatomic) IBOutlet UIButton *sFastBtn;//急速btn
@property (weak, nonatomic) IBOutlet UILabel *sRecommandLabel;//推荐
@property (weak, nonatomic) IBOutlet UILabel *sFastLabel;//急速
@property (weak, nonatomic) IBOutlet UILabel *sBeforeLabel;//加速前的gasprice
@property (weak, nonatomic) IBOutlet UILabel *sAfterLabel;//加速后的gasprice
@property (weak, nonatomic) IBOutlet UILabel *sMinerFeeLabel;//矿工费
@property (weak, nonatomic) IBOutlet UILabel *sMinerFeeDesLabel;//矿工费计算描述
@property (weak, nonatomic) IBOutlet UIButton *sConfirmSpeedUpBtn;//确认急速btn

@end

NS_ASSUME_NONNULL_END
