//
//  SearchViewController.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AddCoinTypeBlock)(BOOL success);

@interface SearchViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *sectionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addMainChainLabel;
@property (weak, nonatomic) IBOutlet UIView *addMainChainView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addMainChainHeight;

@property (nonatomic, copy) AddCoinTypeBlock addCoinBlock;

@property (nonatomic, copy) NSString *wallet_id;
@property (nonatomic, copy) NSString *addressStr;
@property (nonatomic, copy) NSString *keyIDStr;
@property (nonatomic, copy) NSMutableArray *searchTypeArr;

@end

NS_ASSUME_NONNULL_END
