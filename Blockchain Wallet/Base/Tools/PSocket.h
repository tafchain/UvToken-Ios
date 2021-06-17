//
//  PSocket.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/5/6.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSocket : NSObject<SRWebSocketDelegate>

@property (nonatomic, strong)SRWebSocket *webSocket;

+ (instancetype)sharedInstance;

- (void)connectURL:(NSString *)urlStr;

- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
