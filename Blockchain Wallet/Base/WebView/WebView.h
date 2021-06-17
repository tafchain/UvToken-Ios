//
//  WebView.h
//  Taft
//
//  Created by panerly on 2020/11/13.
//  Copyright © 2020 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^WebClickBlock)(NSDictionary *param);
typedef void(^WebTitleStringBlock)(NSString *titleString);
typedef void(^NetworkErrBlock)(BOOL networkError);
typedef NSString*_Nullable(^WebSelectBlock)(NSString *type, NSDictionary *param);

@interface WebView : UIView

@property (nonatomic, assign) BOOL hiddenWeb;
@property (nonatomic, assign) BOOL reloadWeb;
@property (nonatomic, copy) WebClickBlock clickBlock;
@property (nonatomic, copy) WebTitleStringBlock webTitleString;
@property (nonatomic, copy) NetworkErrBlock networkError;
@property (nonatomic, copy) WebSelectBlock selectBlock;

- (instancetype)initWithFrame:(CGRect)frame Url:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
