//
//  SDKGetBTCDetailTool.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import <walletsdk/Walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDKGetBTCDetailTool : NSObject<ApiGetBtcTransactionCallback>

typedef void(^SDKGetBtcTransBlock)(NSString *confirmations, NSString *trusted, NSString *errorStr);

@property (nonatomic, copy) SDKGetBtcTransBlock btcTransBlock;

@end

NS_ASSUME_NONNULL_END
