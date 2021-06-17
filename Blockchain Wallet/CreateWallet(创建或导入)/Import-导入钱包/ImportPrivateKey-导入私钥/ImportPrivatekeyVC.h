//
//  ImportPrivatekeyVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImportPrivatekeyVC : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *importBtn;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, copy) NSString *passwordStr;
@property (nonatomic, copy) NSString *typeStr;
@property (nonatomic, copy) NSString *nameStr;

@end

NS_ASSUME_NONNULL_END
