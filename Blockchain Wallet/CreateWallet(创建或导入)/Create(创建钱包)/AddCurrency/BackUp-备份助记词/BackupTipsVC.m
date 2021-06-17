//
//  BackupTipsVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import "BackupTipsVC.h"
#import "MnemonicVC.h"

@interface BackupTipsVC ()
{
    UIView *maskView;
}
@end

@implementation BackupTipsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUI];
    [self addMaskView];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!maskView) {
        
        [self addMaskView];
    }
}

- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUI{
    
    self.titleLabel.text = Localized(@"创建钱包");
    self.midLabel.text = Localized(@"已为您创建去中心化的钱包");
    self.tipsLabel.text = Localized(@"提示");
    self.tipsDesLabel.text = Localized(@"助记词等于整个钱包的所有控制权，请妥善保管助记词丢失将无法找回，请务必备份");
    [self.backupBtn setTitle:Localized(@"立即备份") forState:UIControlStateNormal];
    [self.laterBackUpBtn setTitle:Localized(@"稍后备份") forState:UIControlStateNormal];
    
    [PTool saveValue:self.wallet_id forKey:@"defaultWalletAddress"];
}

//添加到Windows上 防止系统返回造成重复创建
- (void)addMaskView{
    
    if (maskView) {
        maskView = nil;
    }
    UIButton *backupBtn = [[UIButton alloc] init];
    UIButton *laterBackUpBtn = [[UIButton alloc] init];
//    [backupBtn setBackgroundImage:[UIImage imageNamed:@"icon_yellow_left_right"] forState:UIControlStateNormal];
//    backupBtn.clipsToBounds = YES;
//    backupBtn.layer.cornerRadius = 5.0f;
//    [laterBackUpBtn setTitleColor:[UIColor systemOrangeColor] forState:UIControlStateNormal];
//    [backupBtn setTitle:Localized(@"立即备份") forState:UIControlStateNormal];
//    [laterBackUpBtn setTitle:Localized(@"稍后备份") forState:UIControlStateNormal];
    [backupBtn addTarget:self action:@selector(backupAction:) forControlEvents:UIControlEventTouchUpInside];
    [laterBackUpBtn addTarget:self action:@selector(backupLaterAction:) forControlEvents:UIControlEventTouchUpInside];
    
    maskView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    [maskView addSubview:backupBtn];
    [maskView addSubview:laterBackUpBtn];
    
    [laterBackUpBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
         
        make.left.equalTo(maskView.mas_left).with.offset(20);
        make.right.equalTo(maskView.mas_right).with.offset(-20);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(maskView.mas_safeAreaLayoutGuideBottom).with.offset(-20);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(maskView.mas_bottom).with.offset(-20);
        }
        make.height.equalTo(40);
    }];
    
    
    [backupBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
          
        make.left.equalTo(maskView.mas_left).with.offset(20);
        make.bottom.equalTo(laterBackUpBtn.mas_top).with.offset(-20);
        make.right.equalTo(maskView.mas_right).with.offset(-20);
        make.height.equalTo(44);
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:maskView];
}


- (IBAction)backupAction:(UIButton *)sender {
    [maskView removeFromSuperview];
    maskView = nil;
    MnemonicVC *mnemonic = [MnemonicVC new];
    mnemonic.wallet_id = self.wallet_id;
    mnemonic.pwdStr = self.pwdStr;
    [self.navigationController pushViewController:mnemonic animated:YES];
}

- (IBAction)backupLaterAction:(UIButton *)sender {
    
    [PTool saveValue:self.wallet_id forKey:@"defaultWalletAddress"];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSELECTCENTERINDEX object:nil];
}


@end
