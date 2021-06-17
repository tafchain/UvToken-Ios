//
//  TRXTransViewController.h
//  Blockchain Wallet
//
//  Created by 陈俭红 on 2021/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRXTransViewController : UIViewController
@property (nonatomic, copy) NSString *typeString;
@property (nonatomic, copy) NSString *coinTagString;
@property (nonatomic, copy) NSString *balanceString;

@property (nonatomic, copy) NSString *keyIDString;
@property (nonatomic, copy) NSString *addressString;
@property (nonatomic, copy) NSString *tokenAddressString;
@end

NS_ASSUME_NONNULL_END
