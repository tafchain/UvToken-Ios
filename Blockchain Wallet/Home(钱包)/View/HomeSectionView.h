//
//  HomeSectionView.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface HomeSectionView : UIView

typedef void(^HomeAddBlock)(void);

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, copy) HomeAddBlock addBlock;

@end

NS_ASSUME_NONNULL_END
