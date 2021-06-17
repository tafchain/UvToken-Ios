//
//  CommonWebViewController.m
//  Dow
//
//  Created by panerly on 2019/3/6.
//  Copyright © 2019 panerly. All rights reserved.
//

#import "CommonWebViewController.h"
#import <WebKit/WebKit.h>
#import "YJWebProgressLayer.h"
#import "UIView+ExtendRegion.h"
#import "WebViewJavascriptBridge.h"
#import "Blockchain_Wallet-Swift.h"
#import "TradesListViewController.h"

@interface CommonWebViewController ()
<
WKNavigationDelegate,
WKUIDelegate
>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) YJWebProgressLayer *webProgressLayer;  //  进度条
@property WebViewJavascriptBridge* bridge;

@property (nonatomic, strong) NSDictionary *shareDic;

@end

@implementation CommonWebViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

//- (BOOL)prefersHomeIndicatorAutoHidden{
//    return YES;
//}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_webProgressLayer finishedLoadWithError:nil];
    
    NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
    if(index == NSNotFound) {
        //如果有dapp连接则断开连接
//        [[WalletApproveTool shared] disConnectAction];
        [SVProgressHUD dismiss];
    }
}

- (void)stopHtmlVoice{

    if (_webView) {
        
        _webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;

        NSString *iframe = @"var meta = document.getElementsByTagName('iframe')[0];var vids = meta.contentWindow.document.getElementsByTagName('video'); for( var i = 0; i < vids.length; i++ ){vids[i].pause()}";
        [_webView evaluateJavaScript:iframe completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    PWS(weakSelf);
    if (_webView) {
        
        [_webView evaluateJavaScript:@"document.location.href" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            DLog(@"当前webURL：%@ 开始webUrl:%@ 解析错误：%@", response, weakSelf.webUrl, error);
            if (![response isEqualToString:weakSelf.webUrl]) {
            }
        }];
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];

    self.webUrl = [self WM_FUNC_urlEncode:self.webUrl];
    [self setUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"loginRefreshData" object:nil];
}

- (NSString *)WM_FUNC_urlEncode:(NSString *)urlStr{
    NSMutableCharacterSet *set  = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [set addCharactersInString:@"#"];
    return [urlStr stringByAddingPercentEncodingWithAllowedCharacters:set];
}

- (void)connectWalletWithWCString:(NSString *)wcString{
    
    PWS(weakSelf);
    TradesListViewController *tradeVC = [TradesListViewController new];
    
    WalletApproveTool *tool = [WalletApproveTool shared];
    tool.wcString = wcString;
    tool.privateKeyStr = nil;
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
    Coin *ethCoin = nil;
    for (Coin *coin in arr) {
        if ([coin.name isEqualToString:@"ETH"]) {
            ethCoin = coin;
        }
    }
    if (nil == ethCoin) {
        [LSStatusBarHUD showMessageAndImage:Localized(@"请选择ETH钱包后重试")];
        [SVProgressHUD dismiss];
        return;
    }
    tool.ethAddressStr = ethCoin.address;
    [tool connectTapped];
    tool.transParamBlock = ^(NSDictionary * _Nonnull param, int64_t requestId) {
        tradeVC.dic = param;
        tradeVC.requestId = requestId;
        [weakSelf.navigationController pushViewController:tradeVC animated:YES];
    };
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)loginSuccess{

    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)popAction{
    //如果有dapp连接则断开连接
//    [[WalletApproveTool shared] disConnectAction];
    [SVProgressHUD dismiss];
    //退出控制器
    [self.navigationController popViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)setUI{
    
    [self loadWebView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
}


-(void)endFullScreen{

    DLog(@"退出全屏");
//    [[UIApplication sharedApplication] setStatusBarHidden:false animated:false];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

}

- (YJWebProgressLayer *)webProgressLayer{
    if (!_webProgressLayer) {
        _webProgressLayer = [[YJWebProgressLayer alloc] init];
    }
    _webProgressLayer.frame = CGRectMake(0, 42, KScreenWidth, 2);
    [self.naviView.layer addSublayer:_webProgressLayer];
    return _webProgressLayer;
}

- (IBAction)closeAction:(UIButton *)sender {
    
    //如果有dapp连接则断开连接
//    [[WalletApproveTool shared] disConnectAction];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backAction:(UIButton *)sender {
    if (self.webView.canGoBack==YES) {
        //返回上级页面
        [self.webView goBack];
        
    }else{
        
        //如果有dapp连接则断开连接
//        [[WalletApproveTool shared] disConnectAction];
        [SVProgressHUD dismiss];
        //退出控制器
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
        [self.navigationController popViewControllerAnimated:YES];
        self.navigationController.navigationBar.hidden = YES;
    }
}

- (WKWebView *)webView{
    if (_webView == nil) {
        //clean data
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes] completionHandler:^(NSArray * __nonnull records) {
            
        }];
        //allWebsiteDataTypes清除所有缓存
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
        }];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.allowsInlineMediaPlayback = YES;
        if (@available(iOS 10.0, *)) {
            configuration.mediaTypesRequiringUserActionForPlayback = false;
        } else {
            // Fallback on earlier versions
        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 100, KScreenWidth, KScreenHeight-100) configuration:configuration];
        _webView.scrollView.scrollEnabled = YES;
        _webView.navigationDelegate = self;
        _webView.allowsLinkPreview = YES;
        _webView.UIDelegate = self;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 13.0, *)) {
            _webView.scrollView.backgroundColor = [UIColor systemBackgroundColor];
        } else {
            // Fallback on earlier versions
            _webView.scrollView.backgroundColor = [UIColor whiteColor];
        }
        [self.view addSubview:_webView];
        [_webView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).with.offset(self.naviView.frame.origin.x+44);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            } else {
                // Fallback on earlier versions
                make.top.equalTo(self.view.mas_top).with.offset(self.naviView.frame.origin.x+44);
                make.bottom.equalTo(self.view.mas_bottom);
            }
        }];
        [self setWebBridge];
    }
    return _webView;
}

- (NSDictionary *)shareDic{
    if (!_shareDic) {
        _shareDic = [NSDictionary dictionary];
    }
    return _shareDic;
}

//设置桥 传用户信息
- (void)setWebBridge{
    
    if (_bridge) { return; }
    if(!_bridge){
              _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView
              showJSconsole:YES
              enableLogging:YES];
       }
}

-(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

- (void)loadWebView {
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view bringSubviewToFront:self.naviView];
//    if ([self isHasChineseWithStr:self.webUrl]) {
//        self.webUrl = [self URLEncodeString:self.webUrl];
//    }
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.webUrl]]];
    NSLog(@"weburl: %@", self.webUrl);
}
- (BOOL)isHasChineseWithStr:(NSString *)strFrom {
    for (int i=0; i<strFrom.length; i++) {
        NSRange range =NSMakeRange(i, 1);
        NSString * strFromSubStr=[strFrom substringWithRange:range];
        const char *cStringFromstr = [strFromSubStr UTF8String];
        if (strlen(cStringFromstr)==3) {
            //汉字
            return YES;
        } else if (strlen(cStringFromstr)==1) {
            //字母
        }
    }
    return NO;
}
- (NSString *)URLEncodeString:(NSString *)url {
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodedString = [url stringByAddingPercentEncodingWithAllowedCharacters:set];
    return encodedString;
}

#pragma mark - navigationDelegate Methods
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"web开始接收网页内容");
    
    if (self.webView.canGoBack==YES) {
        self.closeBtn.hidden = NO;
        self.maskWidth.constant = 90.0f;
    }else{
        self.closeBtn.hidden = YES;
        self.maskWidth.constant = 50.0f;
    }
    PWS(weakSelf);
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        if (object) {
            
            weakSelf.titleLabel.text = [NSString stringWithFormat:@"%@", object];
        }
    }];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"webViewDidStartLoad");
    [_webProgressLayer removeFromSuperlayer];
    _webProgressLayer = nil;
    [self.webProgressLayer startLoad];
    if (self.webView.canGoBack==YES) {
        self.closeBtn.hidden = NO;
        self.maskWidth.constant = 90.0f;
    }else{
        self.closeBtn.hidden = YES;
        self.maskWidth.constant = 50.0f;
    }
    
    PWS(weakSelf);
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        if (object) {

            weakSelf.titleLabel.text = [NSString stringWithFormat:@"%@", object];
        }
    }];
    
    
    
    
//    NSString* reqUrl = [NSString stringWithFormat:@"%@", [webView.URL absoluteString]];
    
    
//    if ([reqUrl hasPrefix:@"https://openapi.alipay.com/"] || [reqUrl hasPrefix:@"alipay://"]) {
//        BOOL bSucc = [[UIApplication sharedApplication] openURL:webView.URL];
//
//        // NOTE: 如果跳转失败，则跳转itune下载支付宝App
//        if (!bSucc) {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
//                                                           message:@"未检测到支付宝客户端，请安装后重试。"
//                                                          delegate:self
//                                                 cancelButtonTitle:@"立即安装"
//                                                 otherButtonTitles:nil];
//            [alert show];
//        }
//    }
//
//    if ([reqUrl hasPrefix:@"https://wxpay"] || [reqUrl hasPrefix:@"tenpay://"]) {
//        BOOL bSucc = [[UIApplication sharedApplication] openURL:webView.URL];
//
//        // NOTE: 如果跳转失败
//        if (!bSucc) {
//        }
//    }
    
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    // NOTE: 跳转itune下载支付宝App
//    NSString* urlStr = @"https://itunes.apple.com/cn/app/zhi-fu-bao-qian-bao-yu-e-bao/id333206289?mt=8";
//    NSURL *downloadUrl = [NSURL URLWithString:urlStr];
//    [[UIApplication sharedApplication]openURL:downloadUrl];
//}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
    if (webView.URL.absoluteString.length < 1) {
        return;
    }
    [self.webProgressLayer finishedLoadWithError:error];
    __weak typeof(self)weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"加载失败") message:Localized(@"是否重试？") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *retry = [UIAlertAction actionWithTitle:Localized(@"重试") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf loadWebView];
    }];
    [alert addAction:cancel];
    [alert addAction:retry];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    if (webView.scrollView.contentSize.height < 10) {
        [webView reload];
    }
    [self.webProgressLayer finishedLoadWithError:nil];
    if (self.webView.canGoBack==YES) {
        self.closeBtn.hidden = NO;
        self.maskWidth.constant = 90.0f;
    }else{
        self.closeBtn.hidden = YES;
        self.maskWidth.constant = 50.0f;
    }
    _webProgressLayer = nil;
    
    PWS(weakSelf);
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        if (object) {

            weakSelf.titleLabel.text = [NSString stringWithFormat:@"%@", object];
        }
    }];
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)dealloc{
    
    DLog(@"webview销毁");
}

@end
