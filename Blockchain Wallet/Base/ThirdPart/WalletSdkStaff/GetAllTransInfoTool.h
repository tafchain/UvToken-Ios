//
//  GetAllTransInfoTool.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/31.
//

#import <Foundation/Foundation.h>
#import <walletsdk/Walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetAllTransInfoTool : NSObject<ApiGetAddressesTxIdsCallback>

typedef void(^SDKGetAllTransInfoBlock)(NSString *txIds, NSString *errorStr);

@property (nonatomic, copy) SDKGetAllTransInfoBlock getTransInfoBlock;

@end

NS_ASSUME_NONNULL_END
