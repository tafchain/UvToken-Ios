//
//  SDKGetBlockHeader.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/31.
//

#import <Foundation/Foundation.h>
#import <walletsdk/Walletsdk.h>

NS_ASSUME_NONNULL_BEGIN
@interface SDKGetBlockHeader : NSObject<ApiGetBlockHeaderCallback>

typedef void(^SDKGetHeaderBlock)(NSString *height, NSString *errorStr);

@property (nonatomic, copy) SDKGetHeaderBlock getHeaderBlock;

@end

NS_ASSUME_NONNULL_END
