//
//  BeneficiaryAddrVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/13.
//

#import "BeneficiaryAddrVC.h"
#import "SGQRCode.h"

@interface BeneficiaryAddrVC ()

@end

@implementation BeneficiaryAddrVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUI];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
        
//    self.qrcodeImgView.image = [SGQRCodeObtain generateQRCodeWithData:self.addressStr size:self.qrcodeImgView.frame.size.width color:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    self.qrcodeImgView.image = [SGQRCodeObtain generateQRCodeWithData:self.addressStr size:self.qrcodeImgView.frame.size.width logoImage:[UIImage imageNamed:@"icon_logo_taft_s"] ratio:self.qrcodeImgView.frame.size.width/3];
    self.shareCodeImgView.image = self.qrcodeImgView.image;
}

- (void)setUI{
    
    if (![self.coinTagStr containsString:@"null"]) {//代币
        
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@) %@", self.typeStr, [self.coinTagStr containsString:@"null"]?@"":self.coinTagStr, Localized(@"收款")];
    }else{
        
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", self.typeStr, Localized(@"收款")];
    }
    [self.shareBtn setTitle:Localized(@"分享") forState:UIControlStateNormal];
    self.codeAddrTitleLabel.text = Localized(@"收款二维码");
    self.addrLabel.text = Localized(@"收款地址");
    [self.resCopyBtn setTitle:Localized(@"复制") forState:UIControlStateNormal];
    self.shareCodeLabel.text = Localized(@"收款二维码");
    self.shareAddrLabel.text = Localized(@"收款地址");
    [self.shareActionBtn setTitle:Localized(@"分享") forState:UIControlStateNormal];
    [self.cancelActionBtn setTitle:Localized(@"取消") forState:UIControlStateNormal];
    self.shareAddrDetailLabel.text = self.addressStr;
    
    self.addrDetailLabel.text = self.addressStr;
    
    [PTool addBorderWithView:self.resCopyBtn Color:baseColor BorderWidth:1 CornerRadius:5];
    [self.resCopyBtn setTitleColor:baseColor forState:UIControlStateNormal];
    
    /**
//    self.qrcodeImgView.image = [SGQRCodeObtain generateQRCodeWithData:self.addrDetailLabel.text size:self.qrcodeImgView.frame.size.width logoImage:[UIImage imageNamed:@"icon_logo_taft_s"] ratio:self.qrcodeImgView.frame.size.width/3];
    self.qrcodeImgView.image = [SGQRCodeObtain generateQRCodeWithData:self.addressStr size:self.qrcodeImgView.frame.size.width color:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    self.shareCodeImgView.image = self.qrcodeImgView.image;
    
//    self.shareCodeImgView.image = [SGQRCodeObtain generateQRCodeWithData:self.addrDetailLabel.text size:self.shareCodeImgView.frame.size.width logoImage:[UIImage imageNamed:@"icon_logo_taft_s"] ratio:self.shareCodeImgView.frame.size.width/3];
    **/
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareAction:(UIButton *)sender {
    
    self.shareView.hidden = NO;
    
    self.shareContentView.transform = CGAffineTransformMakeTranslation(0, -KScreenHeight);
    self.shareActionView.transform = CGAffineTransformMakeTranslation(0, self.shareActionView.frame.size.height+100);
    self.bottomPaddingView.transform = CGAffineTransformMakeTranslation(0, self.shareActionView.frame.size.height+100);
    self.shareContentView.hidden = NO;
    self.shareDarkBgView.hidden = NO;
    self.shareDarkBgView.alpha = 0;
    [UIView animateWithDuration:.3 animations:^{
        self.shareDarkBgView.alpha = 0.3;
        self.shareContentView.transform = CGAffineTransformIdentity;
        self.shareActionView.transform = CGAffineTransformIdentity;
        self.bottomPaddingView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)shareContentAction:(UIButton *)sender {
    
//    [PTool saveImageToAlbum:[self imageWithView:self.shareContentView]];
    
//    NSString *textToShare = @"这是要分享的文本内容";
    
    UIImage *imageToShare = [self imageWithView:self.shareContentView];
    
//    NSURL *urlToShare = [NSURL URLWithString:@"https://www.toutiao.com"];
    
//    NSArray *activityItems = @[textToShare, imageToShare, urlToShare];
    NSArray *activityItems = @[imageToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:^{
            
    }];
}
- (IBAction)cancelShareAction:(UIButton *)sender {
    
//    self.shareView.hidden = YES;
    [self removeShareViewAction];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self removeShareViewAction];
}

- (void)removeShareViewAction{
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.shareContentView.transform = CGAffineTransformMakeTranslation(0, -KScreenHeight);
        self.shareActionView.transform = CGAffineTransformMakeTranslation(0, self.shareActionView.frame.size.height+100);
        self.bottomPaddingView.transform = CGAffineTransformMakeTranslation(0, self.shareActionView.frame.size.height+100);
        self.shareDarkBgView.alpha = 0;
    } completion:^(BOOL finished) {
        self.shareDarkBgView.hidden = YES;
        self.shareView.hidden = YES;
    }];
}

- (IBAction)resCopyAction:(UIButton *)sender {
    
    [UIPasteboard generalPasteboard].string = self.addrDetailLabel.text;
    [LSStatusBarHUD showMessage:Localized(@"复制成功")];
}


- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}


@end
