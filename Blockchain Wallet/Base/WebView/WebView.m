//
//  WebView.m
//  Taft
//
//  Created by panerly on 2020/11/13.
//  Copyright © 2020 panerly. All rights reserved.
//

#import "WebView.h"
#import <WebKit/WebKit.h>
#import "YJWebProgressLayer.h"
#import "UIView+ExtendRegion.h"
#import "WebViewJavascriptBridge.h"
#import "CommonWebViewController.h"

@interface WebView()
<
WKNavigationDelegate,
WKUIDelegate,
UIScrollViewDelegate
>
{
    NSString *canRemoveWeb;
    int count;
}
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSString *webUrl;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) YJWebProgressLayer *webProgressLayer;  //  进度条

@property WebViewJavascriptBridge* bridge;


@end

@implementation WebView


- (instancetype)initWithFrame:(CGRect)frame Url:(NSString *)url{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.webUrl = url;
        canRemoveWeb = @"YES";
        count = 0;
        [PTool saveValue:@"YES" forKey:@"canLoadWebViewPage"];
        [self loadWebView];
        [self addSubview:self.topView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAddress) name:@"uploadAddress" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSignature) name:@"signedData" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadCurrency) name:CHANGECURRENCY object:nil];
    }
    return self;
}

//MARK:webview
- (WKWebView *)webView{
    if (_webView == nil) {
        
        
        NSMutableString *javascript = [NSMutableString string];
        [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
        [javascript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        [self _cleanCache];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.allowsInlineMediaPlayback = YES;
        if (@available(iOS 10.0, *)) {
            configuration.mediaTypesRequiringUserActionForPlayback = false;
        } else {
            // Fallback on earlier versions
            configuration.mediaPlaybackRequiresUserAction = false;
        }
        
        [configuration.userContentController addUserScript:noneSelectScript];
        
        _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
        _webView.scrollView.scrollEnabled = YES;
        _webView.navigationDelegate = self;
        _webView.allowsLinkPreview = YES;
        _webView.UIDelegate = self;
        _webView.backgroundColor = baseColor;
        
        _webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_webView];
        
        _webView.allowsLinkPreview = NO;
        
        [_webView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self.mas_bottom);
            }
            make.top.equalTo(self.mas_top);
        }];
        [self setWebBridge];
    }
    return _webView;
}

- (YJWebProgressLayer *)webProgressLayer{
    if (!_webProgressLayer) {
        _webProgressLayer = [[YJWebProgressLayer alloc] init];
        _webProgressLayer.frame = CGRectMake(0, 0, KScreenWidth, 1);
        [self.topView.layer addSublayer:_webProgressLayer];
    }
    return _webProgressLayer;
}

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, -2, KScreenWidth, 1)];
        _topView.backgroundColor = [UIColor clearColor];
    }
    return _topView;
}

#pragma mark - 设置桥 H5与原生交互

- (void)setWebBridge{
    
//    if (_bridge) { return; }
//
//    //设置能够进行桥接
//    [WebViewJavascriptBridge enableLogging];
//
//    // 初始化*WebViewJavascriptBridge*实例,设置代理,进行桥接
//    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
//
//    [_bridge setWebViewDelegate:self];
    
    
    if(!_bridge){
        _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView
                                              showJSconsole:YES
                                              enableLogging:YES];
    }
    
    PWS(weakSelf);
    
    
    #pragma mark -- 用户点击跳转指定页面
    //MARK:原生响应H5跳转指定页面
    [self.bridge registerHandler:@"push" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@", data[@"url"]];
        if (urlString.length > 0) {
            
            [weakSelf pushToNext:urlString];
        }else{
            
            [PJToastView showInView:self text:Localized(@"clickNoResponse") duration:2 autoHide:YES];
        }
    }];
    
    //MARK:原生发送数据给H5
    NSString *currentLanguage = (NSString *)[PTool getValueFromKey:@"appLanguage"];
    NSDictionary *param = @{@"lanuage":[currentLanguage isEqualToString:@"zh-Hans"]?@"zh-Hans":@"en"};
    [weakSelf.bridge callHandler:@"selectLanguage" data:[PTool convertToJsonData:param]];
    
    //MARK:H5向本地数据库插入数据
    [self.bridge registerHandler:@"webClickAction" handler:^(id  _Nonnull data, WVJBResponseCallback  _Nonnull responseCallback) {

        if (self.clickBlock) {
            self.clickBlock(data);
        }
    }];
    
    [self.bridge registerHandler:@"getAddress" handler:^(id  _Nonnull data, WVJBResponseCallback  _Nonnull responseCallback) {

        if (self.clickBlock) {
            self.clickBlock(data);
        }
    }];
    
    [self.bridge registerHandler:@"getCurrencyType" handler:^(id  _Nonnull data, WVJBResponseCallback  _Nonnull responseCallback) {
        NSString *currency = (NSString *)[PTool getValueFromKey:@"selectedCurrencyUnit"];
        responseCallback(currency);
    }];
}

//上传地址数据给H5
- (void)uploadAddress{
    
    NSString *address = (NSString *)[PTool getValueFromKey:defaultAddress];
    NSDictionary *param = @{
        @"address":[address containsString:@"null"]?@"aec1nm8gj0d665gj5ea9hvdv4mjyztpvq9gd8j740d":address
    };
    [self.bridge callHandler:@"uploadAddressInfo" data:[PTool convertToJsonData:param]];
}
//上传签名后的数据给H5
- (void)uploadSignature{
    
    NSString *uploadSignature = (NSString *)[PTool getValueFromKey:@"signedData"];
    [self.bridge callHandler:@"uploadSignature" data:uploadSignature];
    [PTool saveValue:@"" forKey:@"signedData"];
}

/// 上传用户选择的货币种类
- (void)uploadCurrency{
    
    NSString *currency = (NSString *)[PTool getValueFromKey:@"selectedCurrencyUnit"];
    [self.bridge callHandler:@"switchCurrency" data:[PTool convertToJsonData:@{@"currency":currency}]];
}

//MARK:跳转到二级页面
- (void)pushToNext:(NSString *)url{
    

    [PTool saveValue:@"YES" forKey:@"canLoadWebViewPage"];
    
    CommonWebViewController *webVC = [CommonWebViewController new];
    
    NSString *currentLanguage = (NSString *)[PTool getValueFromKey:@"appLanguage"];
    if ([url containsString:@"?"]) {
        
        webVC.webUrl = [NSString stringWithFormat:@"%@&language=%@", url, currentLanguage];
    }else{
        
        webVC.webUrl = [NSString stringWithFormat:@"%@?language=%@", url, currentLanguage];
    }
    [[PTool p_getCurrentVC].navigationController pushViewController:webVC animated:YES];
}

- (void)setHiddenWeb:(BOOL)hiddenWeb{
    _hiddenWeb = hiddenWeb;
    
    canRemoveWeb = _hiddenWeb?@"YES": @"NO";
}

- (void)setReloadWeb:(BOOL)reloadWeb{
    _reloadWeb = reloadWeb;
    if (_reloadWeb) {
        [self loadWebView];
    }
}

//MARK:清理缓存
- (void)_cleanCache{
    
    //clean data
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes] completionHandler:^(NSArray * __nonnull records) {
        
    }];
    /*
     在磁盘缓存上。
     WKWebsiteDataTypeDiskCache,
     
     html离线Web应用程序缓存。
     WKWebsiteDataTypeOfflineWebApplicationCache,
     
     内存缓存。
     WKWebsiteDataTypeMemoryCache,
     
     本地存储。
     WKWebsiteDataTypeLocalStorage,
     
     Cookies
     WKWebsiteDataTypeCookies,
     
     会话存储
     WKWebsiteDataTypeSessionStorage,
     
     IndexedDB数据库。
     WKWebsiteDataTypeIndexedDBDatabases,
     
     查询数据库。
     WKWebsiteDataTypeWebSQLDatabases
     */
    NSArray * types = @[WKWebsiteDataTypeCookies, WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeSessionStorage];
    //allWebsiteDataTypes清除所有缓存
    //        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    
    NSSet *websiteDataTypes = [NSSet setWithArray:types];
    
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        
    }];
}


- (void)loadWebView{
    
    self.webView.scrollView.delegate = self;
    
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[self.webUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]]];
    
    
    //    NSURL *url = [[NSBundle mainBundle] URLForResource:@"/dist/index.htm" withExtension:nil];
    //    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    NSLog(@"weburl: %@", self.webUrl);
        
    [self networkReachability];
    
    if (@available(iOS 11.0, *)){
        for (UIView* subview in self.webView.scrollView.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"WKContentView")])
            {
                for (UIGestureRecognizer* longPress in subview.gestureRecognizers) {
                    if ([longPress isKindOfClass:UILongPressGestureRecognizer.class]) {
                        [subview removeGestureRecognizer:longPress];
                        return;
                    }
                }
            }
        }
    }
    
    if (@available(iOS 8.0, *)){
        for (UIView* subview in self.webView.scrollView.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"WKContentViewMinusAccessoryView")])
            {
                for (UIGestureRecognizer* longPress in subview.gestureRecognizers) {
                    if ([longPress isKindOfClass:UILongPressGestureRecognizer.class]) {
                        [subview removeGestureRecognizer:longPress];
                    }
                }
            }
        }
    }
}

//MARK:检测网络状况
- (void)networkReachability
{
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch(status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                [PTool saveValue:@"YES" forKey:@"networkNeedReload"];
                if (self.networkError) {
                    self.networkError(YES);
                }
                [self.hud hideAnimated:YES];
                break;
            case AFNetworkReachabilityStatusUnknown:
                [PTool saveValue:@"YES" forKey:@"networkNeedReload"];
                if (self.networkError) {
                    self.networkError(YES);
                }
                NSLog(@"未知");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                
                break;
            default:
                break;
        }
        
    }];
    [manager stopMonitoring];
}
//MARK:网络错误
- (void)showNetErrorAlert{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"netLostStr") message:Localized(@"checkNetworkStr") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"confirmStr") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    [[PTool p_getCurrentVC] presentViewController:alert animated:YES completion:^{
        
    }];
}

#pragma mark - navigationDelegate Methods
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"跳转到其他的服务器");
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"web开始接收网页内容");
    
//    NSString *js = [NSString stringWithFormat:@"iosCallback(\'%@\')", @"window.onload=()=>{document.getElementsByClassName('js_smartbanner')[0].style.display='none';document.getElementsByTagName('html')[0].style.marginTop=0;}"];
//    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable rest, NSError * _Nullable error) {
//
//    }];
    
    PWS(weakSelf);
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        if (object) {
            
            NSString *titleString = [NSString stringWithFormat:@"%@", object];
            if (titleString.length > 0) {
                
                if (weakSelf.webTitleString) {
                    weakSelf.webTitleString(titleString);
                }
            }
        }
    }];
    
    count++;
    if (count >= 2) {
        if ([canRemoveWeb isEqualToString:@"YES"]) {
            
            [self removeFromSuperview];
        }
    }
    DLog(@"跳转第%d次",count);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"webViewDidStartLoad");
    
    if (_webProgressLayer) {
        
        [_webProgressLayer removeFromSuperlayer];
        _webProgressLayer = nil;
    }
    [self.webProgressLayer startLoad];
    
    PWS(weakSelf);
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        if (object) {
            
            NSString *titleString = [NSString stringWithFormat:@"%@", object];
            if (titleString.length > 0) {
                
                if (weakSelf.webTitleString) {
                    weakSelf.webTitleString(titleString);
                }
            }
        }
    }];
}



- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
    [self.webProgressLayer finishedLoadWithError:error];
    [self.hud hideAnimated:YES];
    NSLog(@"didFailLoadWithError===%@", error);
    
    __weak typeof(self)weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"loadFailedStr") message:Localized(@"ifRetryAgainStr") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancelStr") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *retry = [UIAlertAction actionWithTitle:Localized(@"retryAgainStr") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf loadWebView];
    }];
    [alert addAction:cancel];
    [alert addAction:retry];
    [[PTool p_getCurrentVC] presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    DLog(@"didFinishNavigation");
//    NSString *js = [NSString stringWithFormat:@"iosCallback(\'%@\')", @"window.onload=()=>{document.getElementsByClassName('js_smartbanner')[0].style.display='none';document.getElementsByTagName('html')[0].style.marginTop=0;}"];
//    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable rest, NSError * _Nullable error) {
//
//    }];
    [self.webProgressLayer finishedLoadWithError:nil];
    _webProgressLayer = nil;
    
    PWS(weakSelf);
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        if (object) {
            
            NSString *titleString = [NSString stringWithFormat:@"%@", object];
            if (titleString.length > 0) {
                
                if (weakSelf.webTitleString) {
                    weakSelf.webTitleString(titleString);
                }
            }
        }
    }];
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSURL *URL = navigationAction.request.URL;

    NSString *scheme = [URL scheme];

    if ([scheme isEqualToString:@"tel"]) {

        NSString *resourceSpecifier = [URL resourceSpecifier];

        NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", resourceSpecifier];

        /// 防止iOS 10及其之后，拨打电话系统弹出框延迟出现

        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];

        });

    }
    if ([webView.URL.absoluteString hasPrefix:@"https://apps.apple.com"]) {
        
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"confirmStr") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [[PTool p_getCurrentVC] presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"cancelStr") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"confirmStr") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [[PTool p_getCurrentVC] presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:Localized(@"confirmStr") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [[PTool p_getCurrentVC] presentViewController:alertController animated:YES completion:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString * body = (NSString * )message.body;
    if ([body containsString:@"wc:"]) {
        if (self.clickBlock) {
            self.clickBlock(@{@"data":body});
        }
    }
}

//MARK:UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return nil;
}

@end
