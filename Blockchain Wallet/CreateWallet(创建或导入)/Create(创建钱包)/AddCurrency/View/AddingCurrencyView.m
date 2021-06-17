//
//  AddingCurrencyView.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import "AddingCurrencyView.h"
#import "FLAnimatedImage.h"

@implementation AddingCurrencyView

- (instancetype)initWithFrame:(CGRect)frame ImgArr:(NSArray<UIImage *>*)imgArr
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUIWithImgArr:imgArr];
    }
    return self;
}

- (void)setUIWithImgArr:(NSArray<UIImage *>*)imgArr{
    
    [[NSBundle mainBundle] loadNibNamed:@"AddingCurrencyView" owner:self options:nil];
    self.baseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.baseView];
    
    self.tipsLabel.text = Localized(@"正在为您创建钱包中...");
    
    int rows = ceil(imgArr.count/3.0);
    
    CGFloat pointX = 30.0;//X坐标
    CGFloat pointY = 110;//Y坐标
    CGFloat padding = 30;//相邻间距
    CGFloat allWidth = KScreenWidth - 35*2;
    CGFloat height = (allWidth - 4*padding)/3; //view高度
    
    self.contentViewConstraint.constant = pointY + rows*(height+padding);
    
    for (int i = 0; i < imgArr.count; i++) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(pointX+padding*(i%3) + i%3*height, floor(i/3)*height+pointY+padding*floor(i/3), height, height)];
        
        [imgView setImage:imgArr[i]];
        
        imgView.alpha = 0.3f;
        
        imgView.tag = 200 + i;
        
        [self.contentView addSubview:imgView];
        
        int count = floor((i-floor(i/2))/2);
        
        DLog(@"count:%d   i:%d", count, i);
        
        if (i+count+1 < imgArr.count) {
            
            int j = count;
            UIImageView *paddingView = [[UIImageView alloc] initWithFrame:CGRectMake(pointX+padding*((i-j)%2) + (i-j)%2*height+height, floor((i-j)/2)*height+pointY+padding*floor((i-j)/2)+height/2-14/2, padding, 14)];
            
            [paddingView setImage:[UIImage imageNamed:@"icon_padding"]];
            
            [self.contentView addSubview:paddingView];
        }
        
        
        
        
        //gif loading
        FLAnimatedImageView *gifImgView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y, height+5, height+5)];
        
        gifImgView.center = imgView.center;
        
        NSURL *imgUrl = [[NSBundle mainBundle] URLForResource:@"icon_loading_gif" withExtension:@"gif"];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:imgUrl]];

        gifImgView.animatedImage = image;
        
        gifImgView.alpha = 0;
        
        gifImgView.tag = 300 + i;
        
        [self.contentView addSubview:gifImgView];
    }
    
    [PTool showExChangeOut:self.contentView dur:.5];
}

- (void)setCreatingIndex:(NSInteger)creatingIndex{
    _creatingIndex = creatingIndex;
    
    for (UIImageView *imgView in self.contentView.subviews) {
        if (imgView.tag > 199) {
            
            if (imgView.tag-200 < creatingIndex) {
                imgView.alpha = 1;
            }
        }
    }
    
    
    for (FLAnimatedImageView *imgView in self.contentView.subviews) {
        if (imgView.tag >= 300) {
            
            if (imgView.tag-300 == creatingIndex) {
                imgView.alpha = 1;
            }else{
                imgView.alpha = 0;
            }
        }
    }
}

- (UIColor*)RandomColor {
    
    NSInteger aRedValue =arc4random() %255;
    NSInteger aGreenValue =arc4random() %255;
    NSInteger aBlueValue =arc4random() %255;
    
    UIColor*randColor = [UIColor colorWithRed:aRedValue /255.0f green:aGreenValue /255.0f blue:aBlueValue /255.0f alpha:1.0f];
    return randColor;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"AddingCurrencyView"owner:self options:nil];
    self.baseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.baseView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self removeFromSuperview];
}

@end
