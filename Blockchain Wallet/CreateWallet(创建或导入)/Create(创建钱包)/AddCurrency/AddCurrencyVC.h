//
//  AddCurrencyVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddCurrencyVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;

@property (nonatomic, strong) NSString *passwordString;
@property (nonatomic, strong) NSString *nameString;
@property (nonatomic, strong) NSString *mnemonicString;

//从搜索页面跳进来添加不存在的主链币
@property (nonatomic, assign) BOOL comeFromeAddingMore;

@end

NS_ASSUME_NONNULL_END
