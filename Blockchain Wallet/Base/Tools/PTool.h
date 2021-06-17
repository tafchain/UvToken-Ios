//
//  PTool.h
//  wine
//
//  Created by panerly on 2020/4/8.
//  Copyright © 2020 panerly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <walletsdk/Walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface PTool : NSObject

//字典转化成json
+(NSString *)convertToJsonData:(NSDictionary *)dict;

//获取UUID
+ (NSString *)uuidString;

//通过时间戳生成UUID
+(NSString*)timeuuid;

//json字符串转化为字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

//验证是否是数组
+ (BOOL)isArray:(NSArray *)array;

//验证是否是字典
+ (BOOL)isDictionary:(NSDictionary *)dic;

//验证是否是string
+ (BOOL)isString:(NSString *)string;

//保存数据
+ (void)saveData:(NSObject *)object forKey:(NSString *)key;

//保存stringValue
+ (void)saveValue:(NSString *)value forKey:(NSString *)key;

//获取数据
+ (NSObject *)getDataFromKey:(NSString *)key;

//获取保存的值
+ (NSObject *)getValueFromKey:(NSString *)key;

//删除数据
+ (void)deleteObjectForKey:(NSString *)key;

//存储照片到本地
+ (void)saveImageToLocalImage:(UIImage *)image forKey:(NSString *)key;

//获取存储的照片
+ (UIImage *)getImageFromLocalForKey:(NSString *)key;

//计算文字高度
+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize;

+ (CGSize)getAttributeSizeWithText:(NSString *)text fontSize:(int)fontSize;

//图片转base64
+ (NSString *)imageToString:(UIImage *)image;
+ (NSString *)imageToBase64String:(UIImage *)image;
//base64转图片
+ (UIImage *)base64stringToImage:(NSString *)str;

//获取图片的宽高
+(CGSize)getImageSizeWithURL:(id)imageURL;


/**
 block回调
 
 @param currentVersion 当前版本号
 @param storeVersion 商店版本号
 @param openUrl 跳转到商店的地址
 @param isUpdate 是否为最新版本
 */
typedef void(^UpdateBlock)(NSString *currentVersion, NSString *storeVersion, NSString *openUrl, NSString *releaseNotes, BOOL isUpdate);

/**
 一行代码实现检测app是否为最新版本。appId，bundelId，随便传一个 或者都传nil 即可实现检测。

 @param appId    项目APPID，10位数字，有值默认为APPID检测，可传nil
 @param bundelId 项目bundelId，有值默认为bundelId检测，可传nil
 @param block    检测结果block回调
 */
+(void)updateWithAPPID:(NSString *)appId withBundleId:(NSString *)bundelId block:(UpdateBlock)block;


//压缩图片到指定大小
+(NSData *)compressWithImage:(UIImage *)img MaxLength:(NSUInteger)maxLength;

//保存图片到相册中
+ (void)saveImageToAlbum:(UIImage *)image;

//给view添加边框、圆角
+ (void)addBorderWithView:(UIView *)view Color:(UIColor *)color BorderWidth:(CGFloat)borderWidth CornerRadius:(CGFloat)cornerRadius;

//缩放动画
+ (void)showExChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur;

//消失动画
+ (void)dismissExChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur;
//给view添加阴影
+ (void)addShadowWithView:(UIView *)view Color:(UIColor *)color;
//字典转化为json字符串
+ (NSString *)gs_jsonStringCompactFormatForDictionary:(NSDictionary *)dicJson;

+ (CGSize)getImageSizeInfoWithURL:(id)URL;


/**
 获取当前控制器
 */
+ (UIViewController *)p_getCurrentVC;

//判断是否是email
+(BOOL)isValidateEmail:(NSString *)email;
//md5加密方法
+ (NSString *)md5EncryptWithString:(NSString *)string EncryptionKey:(NSString *)encryptionKey;
//哈希加密
+(NSString *)SHA256:(NSString *)string;
//获取当前时间戳
+(NSString *)getNowTimeTimestamp;
//判断密码是否符合规定（是否包含数字和字母且位数为8~30）
+ (int)isCorrectPwd:(NSString *)password;
//判断密码是否同时包含大小写字母和数字且位数为大于8
+ (BOOL)isAvailablePwd:(NSString *)password;
//时间戳转时间
+ (NSString *)ConvertStrToTime:(NSString *)timeStr;
//获取UUID
+(NSString *)getUUID;
//设备号
+ (NSString *)platformString;

/**
 改变 label 文字中某段文字的颜色和大小
 label      传入的文本内容（注：传入前要有文字）
 oneIndex   从首位文字开始
 endIndex   至末位文字结束
 color      字体颜色
 size       字体字号
 */
+ (void)YHLabelAttributedString:(UILabel *)label firstText:(NSString *)oneIndex toEndText:(NSString *)endIndex textColor:(UIColor *)color textSize:(CGFloat)size;
//MARK:获取钱包信息
+ (NSString *)getWalletInfo:(NSString *)wallet_id Type:(NSString *)type;

//金额保留响应小数
+(NSString *)stringByYouWantWithOriginString:(NSString *)originString;
/**
 过滤器/ 将.2f格式化的字符串，去除末尾0

 @param numberStr .2f格式化后的字符串
 @return 去除末尾0之后的
 */
+ (NSString *)removeSuffix:(NSString *)numberStr;
//MARK:字符串截取保留小数点后两位
+(NSString*)getTheCorrectNum:(NSString*)tempString;
//移除没必要的0
+ (NSString*)removeFloatAllZeroByString:(NSString *)balance;
//截取指定小数位的值
+ (NSString *)notRounding:(NSString*)price afterPoint:(NSInteger)position;
//获取状态栏网络情况
+ (NSString *)getStatusBarNetwork;
//判断当前时间戳与过去时间戳是否相差大于10分钟
+ (BOOL)timestampSubtractionWithPastTime:(NSString *)pastTime;
//判断传入的时间是否大于1分钟
+ (BOOL)isOver1MinuteWithPastTime:(NSString *)pastTime;
//上次存储的时间是否超过24H
+ (BOOL)isOver24H;
//统计日活
+ (void)dailyCount;
//获取状态栏高度
+ (CGFloat)getStatusBarHight;
//获取多语言：为swift而写
+ (NSString *)getLocalizedStringWithString:(NSString *)string;
//为view添加渐变颜色
+ (void)addGradientForView:(UIView *)view StartPoint:(CGPoint)startPoint EndPoint:(CGPoint)endPoint StartColor:(UIColor *)startColor EndColor:(UIColor *)endColor;
//判断相机是否可以打开
+ (void)isCamCanOpenWithBlock:(void(^)(BOOL canOpen))canOpen;
//找到当前显示的控制器
+ (UIViewController *)findVC;
//获取GIF图片数组
+ (NSArray *)getImagesFromGIF:(NSString *)gifName;
//获取当前钱包私钥
+ (void)getCurrentWalletPkString:(void(^)(NSString *pkString))pkString;
@end

NS_ASSUME_NONNULL_END
