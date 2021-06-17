//
//  ImportPrivatekeyVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/29.
// 

#import "ImportPrivatekeyVC.h"
#import "CreateWalletVC.h"

@interface ImportPrivatekeyVC ()

@property (nonatomic, strong) NSString *wallet_id;

@end

@implementation ImportPrivatekeyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
}

- (void)setUI{
    
    [self.importBtn setTitle:Localized(@"导入") forState:UIControlStateNormal];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@ %@",Localized(@"导入"), self.typeStr, Localized(@"钱包")];
    
    if ([self.typeStr isEqualToString:@"BTC"]) {
        
        self.tipsLabel.text = Localized(@"请填写您的BTC主链钱包私钥地址");
    }else if ([self.typeStr isEqualToString:@"ETH"]) {
        
        self.tipsLabel.text = Localized(@"请填写您的ETH主链钱包私钥地址");
    }else if ([self.typeStr isEqualToString:@"TRX"]) {
        
        self.tipsLabel.text = Localized(@"请填写您的TRX主链钱包私钥地址");
    }else if ([self.typeStr isEqualToString:@"TAF"]) {
        
        self.tipsLabel.text = Localized(@"请填写您的TAF主链钱包私钥地址");
    }
}

- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)importAction:(UIButton *)sender {
    
    if (self.textView.text.length < 1) {
        [LSStatusBarHUD showMessageAndImage:Localized(@"请填写私钥地址!")];
        return;
    }
    
    
    
    //    CreateWalletVC *createW = [[CreateWalletVC alloc] init];
    //    createW.type = ComeFromPK;
    //
    //    if (indexPath.row == 0) {
    //
    //        createW.typeStr = @"BTC";
    //    }else if (indexPath.row == 1) {
    //
    //        createW.typeStr = @"ETH";
    //    }else{
    //
    //        createW.typeStr = @"TAF";
    //    }
    //    [self.navigationController pushViewController:createW animated:YES];
    
    
    CreateWalletVC *createW = [[CreateWalletVC alloc] init];
    createW.type = ComeFromPK;
    createW.typeStr = self.typeStr;
    createW.pkString = self.textView.text;
    
    [self.navigationController pushViewController:createW animated:YES];
    
    
//    [self validatePK];
}
//
//- (void)validatePK{
//
//    [LSStatusBarHUD showLoading:Localized(@"正在导入...")];
//
//    //获取Documents路径
//    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString * documentsPath = [[document objectAtIndex:0] stringByAppendingPathComponent:@"keystore"];
//    ApiImportPrivateKeyRequest *req = [[ApiImportPrivateKeyRequest alloc] init];
//    req.coinType = self.typeStr;
//    req.keystoreDir = documentsPath;
//    req.privateKey = self.textView.text;
//    req.passphrase = self.passwordStr;
//
//    dispatch_queue_t queue = dispatch_queue_create("com.taft.tafwallet.importPK", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//
//        SdkImportPrivateKey(req, self);
//    });
//}
//
////MARK:ApiImportPrivateKeyCallback
//- (void)failure:(NSError * _Nullable)err {
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([err.localizedDescription isEqualToString:@"address already exists"]) {
//
//            [LSStatusBarHUD showMessageAndImage:Localized(@"已存在，请勿重复导入")];
//        }else{
//
//            [LSStatusBarHUD showMessageAndImage:Localized(@"请输入正确的私钥地址")];
//        }
//    });
//}
//
//- (void)success:(ApiImportPrivateKeyResponse * _Nullable)p0 {
//
//    PWS(weakSelf);
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        Wallet *wallet = [Wallet MR_createEntity];
//        wallet.name = weakSelf.nameStr;
//        wallet.password = [SecurityUtil encryptAESData:weakSelf.passwordStr];
//        wallet.type = weakSelf.typeStr;
//        wallet.wallet_id = p0.walletId;
//        wallet.is_backup = NO;
//        weakSelf.wallet_id = p0.walletId;
//
//
//        Coin *coin = [Coin MR_createEntity];
//        coin.wallet_id = p0.walletId;
//        coin.name = weakSelf.typeStr;
//        coin.key_id = p0.keyId;
//        coin.address = p0.address;
//
//        if ([weakSelf.typeStr isEqualToString:@"BTC"]) {
//
//            Coin *coin_usdt = [Coin MR_createEntity];
//            coin_usdt.wallet_id = p0.walletId;
//            coin_usdt.name = @"USDT";
//            coin_usdt.key_id = p0.keyId;
//            coin_usdt.address = p0.address;
//            coin_usdt.coin_tag = @"OMNI";
//        }
//
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//
//        [LSStatusBarHUD showMessage:Localized(@"导入成功")];
//        [PTool saveValue:p0.walletId forKey:@"defaultWalletAddress"];
//        [self performSelector:@selector(enterHome) withObject:nil afterDelay:1];
//    });
//}
//
//- (void)enterHome{
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSELECTCENTERINDEX object:nil];
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

@end
