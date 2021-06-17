//
//  BackupTipsView.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackupTipsView : UIView

typedef void(^BackupCloseBlock)(void);
typedef void(^BackupBlock)(void);

@property (strong, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UILabel *tipsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *backupBtn;
@property (nonatomic, copy) BackupCloseBlock closeBlock;
@property (nonatomic, copy) BackupBlock backupBlock;

@end

NS_ASSUME_NONNULL_END
