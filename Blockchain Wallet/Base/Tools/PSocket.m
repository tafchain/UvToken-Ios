//
//  PSocket.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/5/6.
//

#import "PSocket.h"

@implementation PSocket

+ (instancetype)sharedInstance{
    
    static PSocket *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[PSocket alloc] init];
    });
    return singleton;
}

- (void)connectURL:(NSString *)urlStr{
    
    PWS(weakSelf);
    //Url
    NSURL *url = [NSURL URLWithString:urlStr];
    //请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //初始化请求
    weakSelf.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    //代理协议
    weakSelf.webSocket.delegate = self;
    //直接连接
    [weakSelf.webSocket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    DLog(@"连接成功，可以立刻登录你公司后台的服务器了，还有开启心跳");
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    DLog(@"连接失败，这里可以实现掉线自动重连，要注意以下几点");
    DLog(@"1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连");
    DLog(@"2.判断调用层是否需要连接，例如用户都没在聊天界面，连接上去浪费流量");
    //关闭心跳包
    [webSocket close];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    //关闭心跳包
    [webSocket close];
    DLog(@"连接断开，清空socket对象，清空该清空的东西，还有关闭心跳!");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message  {
    DLog("收到了信息%@", message);
    //收到数据代理方法
}

- (void)disconnect{
    PWS(weakSelf);
    [weakSelf.webSocket close];
}

@end
