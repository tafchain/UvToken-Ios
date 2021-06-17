//
//  ImportViewController.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/29.
//

#import "ImportViewController.h"
#import "ImportPrivatekeyVC.h"
#import "ImportMnemonicVC.h"
#import "CreateWalletVC.h"
#import "CurrencyModel.h"
#import "AddCurrencyCell.h"
#import <walletsdk/Walletsdk.h>
#import "ImportPrivatekeyVC.h"


@interface ImportViewController ()
<UIScrollViewDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL isLastEnter;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *imgArr;

@end

@implementation ImportViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.alertView.transform = CGAffineTransformMakeTranslation(0, -300);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUI];
    [self createData];
}

- (void)setUI{
    
    self.textView.delegate = self;
    self.titleLabel.text = Localized(@"导入钱包");
    self.tipsLabel.text = Localized(@"钱包服务器不保存您的助记词等信息");
    self.alertLabel.text = Localized(@"当前助记词拼写错误，请检查");
    [self.mnemonicBtn setTitle:Localized(@"助记词导入") forState:UIControlStateNormal];
    [self.pkBtn setTitle:Localized(@"私钥导入") forState:UIControlStateNormal];
    self.mnemonicTipsLabel.text = Localized(@"请填写您的助记词，用空格分开");
    [self.importBtn setTitle:Localized(@"导入") forState:UIControlStateNormal];
    
    isLastEnter = NO;
    
    self.tipsHeight.constant = 20+[PTool sizeWithText:Localized(@"钱包服务器不保存您的助记词等信息") font:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(KScreenWidth, 100)].height;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AddCurrencyCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AddCurrencyCellID"];
    
    self.textView.delegate = self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        return NO;
    }
    return YES;
}

- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createData{
    
    NSArray *name = @[@"BTC", @"ETH", @"TRX"];//, @"TAF"
    NSArray *des  = @[@"Bitcoin", @"Ethereum", @"TRON"];//, @"Tafchain"
    NSArray *icon = @[@"icon_btc", @"icon_eth", @"icon_trx"];//, @"icon_taf"
    
    for (int i = 0; i < name.count; i++) {
        
        CurrencyModel *model = [[CurrencyModel alloc] init];
        model.name = name[i];
        model.des  = des[i];
        model.selectStatus = 3;
        model.icon = icon[i];
        [self.dataArr addObject:model];
    }
    [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([scrollView isKindOfClass:[UITableView class]]) {
        return;
    }
    CGFloat offSetX = -scrollView.contentOffset.x;
    
    
    if (fabs(offSetX) == KScreenWidth) {
        [self.pkBtn setTitleColor:baseColor forState:UIControlStateNormal];
        [self.mnemonicBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }else{
        
        [self.mnemonicBtn setTitleColor:baseColor forState:UIControlStateNormal];
        [self.pkBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    self.lineViewToLeftConstraint.constant = fabs(offSetX)/2;
}



//MARK:UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddCurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCurrencyCellID" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ImportPrivatekeyVC *importPK = [ImportPrivatekeyVC new];
    if (indexPath.row == 0) {
        
        importPK.typeStr = @"BTC";
    }else if (indexPath.row == 1) {
        
        importPK.typeStr = @"ETH";
    }else if (indexPath.row == 2) {
        
        importPK.typeStr = @"TRX";
    }else if (indexPath.row == 3) {
        
        importPK.typeStr = @"TAF";
    }
    [self.navigationController pushViewController:importPK animated:YES];
}


//MARK:LAZY
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
- (NSMutableArray *)imgArr{
    if (!_imgArr) {
        _imgArr = [NSMutableArray array];
    }
    return _imgArr;
}

//MARK:选择私钥币种导入
- (IBAction)importWayAction:(UIButton *)sender {
    
    if (sender.tag == 300) {
        
        [self.mnemonicBtn setTitleColor:baseColor forState:UIControlStateNormal];
        [self.pkBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        
        [self.pkBtn setTitleColor:baseColor forState:UIControlStateNormal];
        [self.mnemonicBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.scrollView setContentOffset:CGPointMake(KScreenWidth, 0) animated:YES];
    }
    [self.view endEditing:YES];
}

//MARK:输入助记词 进行下一步
- (IBAction)importMnemonicAction:(UIButton *)sender {
    
    NSArray *arr = [self.textView.text componentsSeparatedByString:@" "];
    NSMutableArray *mnemonicArr = [NSMutableArray array];
    //去除最后一个空格
    for (int i = 0; i < arr.count; i++) {
        NSString *str = arr[i];
        if (str.length >= 1) {
            [mnemonicArr addObject:str];
        }
    }
    if (mnemonicArr.count < 12 || mnemonicArr.count > 12) {
        [LSStatusBarHUD showMessageAndImage:@"请输入12个助记词！"];
        return;
    }
    DLog(@"助记词：%@", mnemonicArr);
    
    isLastEnter = YES;
    
    [self isValidMnemonic:[mnemonicArr componentsJoinedByString:@" "]];
}

- (void)textViewDidChange:(UITextView *)textView{
    
    if (textView.text.length < 2) {
        return;
    }
    NSArray *arr = [self.textView.text componentsSeparatedByString:@" "];
    NSMutableArray *mnemonicArr = [NSMutableArray array];
    
    //去除最后一个空格
    for (int i = 0; i < arr.count; i++) {
        NSString *str = arr[i];
        if (str.length > 0) {
            [mnemonicArr addObject:str];
        }
    }
    
    if (mnemonicArr.count < 12) {
        self.importBtn.alpha = 0.3f;
        self.importBtn.userInteractionEnabled = NO;
    }else{
        self.importBtn.alpha = 1;
        self.importBtn.userInteractionEnabled = YES;
    }
    
    NSString *lastString = [textView.text substringFromIndex:textView.text.length-1];
    DLog(@"最后一个字符：%@", lastString)
    if ([lastString containsString:@" "]) {
        
        [self isValidMnemonic:[mnemonicArr componentsJoinedByString:@" "]];
    }
    
    isLastEnter = NO;
}

//MARK:验证助记词是否合法
- (void)isValidMnemonic:(NSString *)mnemonic{
    
    DLog(@"需要验证的助记词：%@", mnemonic);
//    ApiVerifyMultiMnemonicRequest *req = [[ApiVerifyMultiMnemonicRequest alloc] init];
//    req.word = mnemonic;
//    dispatch_queue_t queue = dispatch_queue_create("com.vbhledger.tafwallet.verifymnemonic", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//
//        SdkVerifyMultiMnemonic(req, self);
//    });
    
    PWS(weakSelf);
    ApiVerifyMultiMnemonicRequest *req = [[ApiVerifyMultiMnemonicRequest alloc] init];
    req.word = mnemonic;
    dispatch_queue_t queue = dispatch_queue_create("com.vbhledger.tafwallet.verifymnemonic", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSError *error = nil;
        ApiVerifyMultiMnemonicResponse *res = Uv1VerifyMultiMnemonic(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (res.invalidWord.length > 0) {
                
                [weakSelf showWrongView];
                [PTool addBorderWithView:self.textView Color:[UIColor redColor] BorderWidth:1.0f CornerRadius:5.0f];
                DLog(@"不合法的助记词：%@", res.invalidWord);
                weakSelf.alertLabel.text = [NSString stringWithFormat:@"%@[%@]", Localized(@"当前助记词拼写错误，请检查"), res.invalidWord];
            }else{
                [PTool addBorderWithView:weakSelf.textView Color:COLORRGB(244, 245, 249) BorderWidth:1.0f CornerRadius:5.0f];
                [weakSelf hideWrongView];
                if (self->isLastEnter) {
                    [weakSelf nextAction];
                }
            }
        });
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//MARK:隐藏错误view
- (void)hideWrongView{
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.alertView.transform = CGAffineTransformMakeTranslation(0, -300);
    } completion:^(BOOL finished) {
        
        self.alertLabel.text = Localized(@"当前助记词拼写错误，请检查");
    }];
}

//MARK:显示错误view
- (void)showWrongView{
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

//MARK:输入完成且正确
- (void)nextAction{
    
    NSArray *arr = [self.textView.text componentsSeparatedByString:@" "];
    NSMutableArray *mnemonicArr = [NSMutableArray array];
    //去除最后一个空格
    for (int i = 0; i < arr.count; i++) {
        NSString *str = arr[i];
        if (str.length >= 1) {
            [mnemonicArr addObject:str];
        }
    }
    
    CreateWalletVC *createW = [[CreateWalletVC alloc] init];
    createW.type = ComeFromMnemonic;
    createW.mnemonicString = [mnemonicArr componentsJoinedByString:@" "];
    [self.navigationController pushViewController:createW animated:YES];
}

@end
