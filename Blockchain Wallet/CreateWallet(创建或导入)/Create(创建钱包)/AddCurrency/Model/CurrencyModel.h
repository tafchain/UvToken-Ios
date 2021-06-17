//
//  CurrencyModel.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CurrencyModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *des;
@property (nonatomic, assign) NSInteger selectStatus; //0:不可选择 1:未选中 2：已选中
@property (nonatomic, strong) NSString *icon;

@end

NS_ASSUME_NONNULL_END
