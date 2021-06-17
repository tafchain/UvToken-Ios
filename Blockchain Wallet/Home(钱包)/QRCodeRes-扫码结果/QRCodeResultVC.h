//
//  QRCodeResultVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeResultVC : UIViewController

@property (nonatomic, strong) NSString *result;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *resultCopyBtn;

@end

NS_ASSUME_NONNULL_END
