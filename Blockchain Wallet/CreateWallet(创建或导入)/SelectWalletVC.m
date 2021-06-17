//
//  SelectWalletVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/25.
//

#import "SelectWalletVC.h"
#import "CreateWalletVC.h"

@interface SelectWalletVC ()

@end

@implementation SelectWalletVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.titleLabel.text = Localized(@"多链钱包");
    self.desLabel.text = Localized(@"支持BTC、ETH、TRX 等主流公链");
    self.createWalletLabel.text = Localized(@"创建钱包");
    self.createDesLabel.text = Localized(@"没有钱包 ， 首次使用");
    self.importWalletLabel.text = Localized(@"导入钱包");
    self.importWalletDesLabel.text = Localized(@"已有钱包，支持助记词、私钥等方式导入");
    
    CGFloat height = [PTool sizeWithText:Localized(@"已有钱包，支持助记词、私钥等方式导入") font:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(KScreenWidth-40-10-40-40, 100)].height;
    if (height > 17) {
        
        self.importBtnHeightConstraint.constant = 70+height;
    }
}

//MARK:创建钱包
- (IBAction)createWalletAction:(UIButton *)sender {
    
    CreateWalletVC *createW = [[CreateWalletVC alloc] init];
    createW.type = ComeFromCreating;
    [self.navigationController pushViewController:createW animated:YES];
}

//MARK:导入钱包
- (IBAction)importWallet:(UIButton *)sender {
    
    Class name = NSClassFromString(@"ImportViewController");//ImportViewController  MnemonicVC
    [self.navigationController pushViewController:[[name alloc] init] animated:YES];
}

- (IBAction)enterHome:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSELECTCENTERINDEX object:nil];
}

@end
