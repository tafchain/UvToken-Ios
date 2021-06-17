//
//  BackupPKVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/19.
//

#import "BackupPKVC.h"
#import <walletsdk/Walletsdk.h>

@interface BackupPKVC ()

@end

@implementation BackupPKVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUI];
    [self getPKData];
}

- (void)setUI{
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", self.type, Localized(@"私钥")];
    self.alertLabel.text = Localized(@"私钥备份风险提醒");
    [self.knowBtn setTitle:Localized(@"知道了") forState:UIControlStateNormal];
    [self.resCopyBtn setTitle:Localized(@"复制") forState:UIControlStateNormal];
    
    CGFloat height = [PTool sizeWithText:Localized(@"私钥备份风险提醒") font:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(KScreenWidth-48*2-20*2, 100)].height;
    if (height > 16) {
        
        self.alertHeight.constant = 180+height;
    }
}

//MARK:获取pk数据
- (void)getPKData{
    
    //获取Documents路径
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsPath = [[document objectAtIndex:0] stringByAppendingPathComponent:@"keystore"];
//    ApiExportPrivateKeyRequest *req = [[ApiExportPrivateKeyRequest alloc] init];
//    req.coinType = self.type;
//    req.keyId = self.key_id;
//    req.keystoreDir = documentsPath;
//    req.passphrase = self.passwordString;
//    dispatch_queue_t queue = dispatch_queue_create("com.taft.tafwallet.backupPK", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//
//        SdkExportPrivateKey(req, self);
//    });
    
    PWS(weakSelf);
    
    NSArray *arr = [Wallet MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
    NSString *type = @"Multi";
    for (Wallet *wallet in arr) {
        
        type = wallet.type;
    }
    
    if (![type isEqualToString:@"Multi"]) {
        
        [[PWallet shareInstance] getPKDataFromSingleChainWithCoinType:self.type WalletID:self.wallet_id Password:self.passwordString privateKey:^(NSString * _Nonnull privateKey) {
            weakSelf.textView.text = privateKey;
        } failure:^(NSError * _Nonnull failure) {
            
            [LSStatusBarHUD showMessageAndImage:Localized(@"未知错误，请重试")];
        }];
        return;
    }
    
    
    NSArray *coinArr = [Coin MR_findByAttribute:[self.type isEqualToString:@"AECO"]?@"address":@"wallet_id" withValue:self.wallet_id];
    for (Coin *coins in coinArr) {
        
        if ([coins.name isEqualToString:self.type]) {
            
//            NSDictionary *param = @{
//                @"password":self.passwordString,
//                @"wallet_id":self.wallet_id,
//                @"account":coins.account,
//                @"change":coins.change,
//                @"index":coins.index,
//                @"coin":coins.coin
//            };
            
//            NSDictionary *param = @{
//                @"password":self.passwordString,
//                @"wallet_id":self.wallet_id,
//                @"account":[NSNumber numberWithLong:coins.account],
//                @"change":[NSNumber numberWithLong:coins.change],
//                @"index":[NSNumber numberWithLong:coins.index],
//                @"coin":[NSNumber numberWithLong:coins.coin]
//            };
//
//            [[PWallet shareInstance] getPKDataFromMasterWithParam:param privateKey:^(NSString * _Nonnull privateKey) {
//                weakSelf.textView.text = privateKey;
//            } failure:^(NSError * _Nonnull failure) {
//                [LSStatusBarHUD showMessageAndImage:Localized(@"未知错误，请重试")];
//            }];
            
            ApiExportPrivateKeyFromMasterRequest *req = [[ApiExportPrivateKeyFromMasterRequest alloc] init];
            req.account = coins.account;
            req.change = coins.change;
            req.coin = coins.coin;
            req.index = coins.index;
            req.passphrase = self.passwordString;
            req.walletId = coins.wallet_id;
            req.keystoreDir = documentsPath;
            
            NSError *error = nil;
            ApiExportPrivateKeyFromMasterResponse *res = Uv1ExportPrivateKeyFromMaster(req, &error);
            if (res.privateKey) {
                weakSelf.textView.text = res.privateKey;
            }else{
                [LSStatusBarHUD showMessageAndImage:Localized(@"未知错误，请重试")];
            }
            
            Uv1GarbageCollection();
        }
    }
}

////MARK:ApiExportPrivateKeyCallback
//- (void)success:(ApiExportPrivateKeyResponse *)p0{
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        self.textView.text = p0.privateKey;
//    });
//}
//- (void)failure:(NSError *)err{
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        [LSStatusBarHUD showMessageAndImage:Localized(@"未知错误，请重试")];
//    });
//}

- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)resCopyAction:(UIButton *)sender {
    
    
//    NSArray *arr = [Coin MR_findByAttribute:@"key_id" withValue:self.key_id];
//    if (arr.count > 0) {
//        for (Coin *coin in arr) {
//            coin.is_backup = YES;
//        }
//    }
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [UIPasteboard generalPasteboard].string = self.textView.text;
    [LSStatusBarHUD showMessage:Localized(@"复制成功")];
}

- (IBAction)removeTipsViewAction:(UIButton *)sender {
    
    [UIView animateWithDuration:.5 animations:^{
        
        self.alertContentView.transform = CGAffineTransformMakeScale(.01f, .01f);
        self.alertContentView.alpha = .3f;
    } completion:^(BOOL finished) {
        [self.alertView removeFromSuperview];
    }];
}

@end
