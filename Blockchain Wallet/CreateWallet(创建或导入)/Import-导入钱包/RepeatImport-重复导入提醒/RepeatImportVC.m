//
//  RepeatImportVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/20.
//

#import "RepeatImportVC.h"
#import "ImportViewController.h"

@interface RepeatImportVC ()

@end

@implementation RepeatImportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUI];
}

- (void)setUI{
    
    self.titleLabel.text = Localized(@"重复导入");
    self.tipsLabel.text = Localized(@"已导入该钱包，无法重复导入");
    [self.repeatImportBtn setTitle:Localized(@"重新导入") forState:UIControlStateNormal];
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//重新导入
- (IBAction)reImportAction:(UIButton *)sender {
//    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSELECTCENTERINDEX object:nil];
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[ImportViewController class]]) {
            ImportViewController * vc = (ImportViewController *)controller;
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}
@end
