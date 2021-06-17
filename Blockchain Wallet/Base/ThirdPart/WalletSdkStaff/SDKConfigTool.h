//
//  SDKConfigTool.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import <walletsdk/Walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDKConfigTool : NSObject<ApiParamCallback>

typedef void(^SDKConfigBlock)(NSString *httpUrl, NSString *net);

@property (nonatomic, copy) SDKConfigBlock configBlock;

@end

NS_ASSUME_NONNULL_END
