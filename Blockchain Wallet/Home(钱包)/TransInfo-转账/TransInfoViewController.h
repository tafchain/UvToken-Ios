//
//  TransInfoViewController.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransInfoViewController : UIViewController

@property (nonatomic, copy) NSString *currencyType;
@property (nonatomic, copy) NSString *keyIDString;
@property (nonatomic, copy) NSString *coinTagString;
@property (nonatomic, copy) NSString *balanceString;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *currencyImgView;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addrTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *transBtn;

@property (nonatomic, strong) NSString *addressStr;
@property (nonatomic, copy) NSString *imageStr;
@property (nonatomic, copy) NSString *contactAddressStr;

@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

@end

NS_ASSUME_NONNULL_END
