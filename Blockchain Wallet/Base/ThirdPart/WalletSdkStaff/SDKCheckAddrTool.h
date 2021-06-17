//
//  SDKCheckAddrTool.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import <walletsdk/Walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDKCheckAddrTool : NSObject<ApiValidateAddressCallback>

typedef void(^SDKValidateAddressBlock)(BOOL validate, NSString *errorStr);

@property (nonatomic, copy) SDKValidateAddressBlock validateBlock;

@end

NS_ASSUME_NONNULL_END
