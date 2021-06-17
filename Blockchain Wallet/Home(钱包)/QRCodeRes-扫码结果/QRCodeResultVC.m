//
//  QRCodeResultVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/4.
//

#import "QRCodeResultVC.h"

@interface QRCodeResultVC ()

@end


@implementation QRCodeResultVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [PJHud showWithString:self.result BackGroudnColor:[UIColor redColor] loading:NO duration:3 AutoHide:YES];
    
//    NSError *error = nil;
//    NSString *str = HelloTestReturnE(self.result, &error);
//
//    if (!error) {
//
//        self.textView.text = str;
//    }
    
//    HelloAbc *abc = [[HelloAbc alloc] init];
//
//    DLog(@"%@", [abc b:@"hh"]);
//
//    HelloReturnE(self.result, &error);
//
//    DLog(@"%@", error);
//
//    @try {
//
//        DLog(@"%@", HelloTestReturnE(self.result, &error));
//
//    } @catch (NSException *exception) {
//
//
//    } @finally {
//
//    }
    
    self.textView.text = self.result;
    
//    HelloStartFile(@"1", self);
//    id res =  HelloStartFile();
//    DLog(@"%@---%ld---%@", ((HelloResp *)res).msg, ((HelloResp *)res).code , ((HelloUserInfoResp *)res).name);
    
    
    self.titleLabel.text = Localized(@"扫描结果");
    
    [self.resultCopyBtn setTitle:Localized(@"复制") forState:UIControlStateNormal];
}
- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK:复制结果
- (IBAction)resultCopyAction:(UIButton *)sender {
    
    [UIPasteboard generalPasteboard].string = self.textView.text;
    [PJToastView showInView:self.view text:Localized(@"复制成功") duration:2 autoHide:YES];
}


//- (void)onSuccess:(id<HelloResp>)file{
//
//    DLog(@"%@--- %@ --- %@", file.name, file.code, file.sex);
//}
//
//- (void)onError:(NSString *)err{
//
//    DLog(@"有错误:%@", err);
//}


@end
