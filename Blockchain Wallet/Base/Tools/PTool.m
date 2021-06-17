//
//  PTool.m
//  wine
//
//  Created by panerly on 2020/4/8.
//  Copyright © 2020 panerly. All rights reserved.
//

#import "PTool.h"
#import <CommonCrypto/CommonDigest.h>
#import "KeyChainStore.h"
#import <sys/utsname.h>
#import <AVFoundation/AVFoundation.h>
#import "UIViewControllerCJHelper.h"

@interface PTool()

@end

@implementation PTool


+(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

+ (NSString *)uuidString

{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    
    CFRelease(uuid_ref);
    
    CFRelease(uuid_string_ref);
    
    return [uuid lowercaseString];
}

+ (NSString*)timeuuid {

    char data[10];
    
    for (int x=0;x<10;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    NSDate *  datenow=[NSDate date];
    
    NSString *ns_sendCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendMessageCount"];
    int sendCount = [ns_sendCount intValue];
    NSDate *preSendTime = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"preSendTime"];
    
    if (preSendTime == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:datenow forKey:@"preSendTime"];
    }
    else
    {
        NSCalendar *chineseClendar = [ [ NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSUInteger unitFlags =  NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit | NSDayCalendarUnit| NSMonthCalendarUnit | NSYearCalendarUnit;
        
        NSDateComponents *DateComponent = [chineseClendar components:unitFlags fromDate:preSendTime toDate:datenow options:0];
        
        if ([DateComponent day] > 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject:datenow forKey:@"preSendTime"];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"sendMessageCount"];
            sendCount = 0;
        }
        else
        {
            sendCount ++;
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",sendCount] forKey:@"sendMessageCount"];
        }
        
    }
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    NSString * n_str = [NSString stringWithFormat:@"%@%@%@%@%@",
                        [[NSString alloc] initWithBytes:data length:10 encoding:NSUTF8StringEncoding]
                        ,@"-"
                        ,timeSp
                        ,@"-"
                        ,[NSString stringWithFormat:@"%d",sendCount]];
    
    return n_str;
}


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


#pragma mark 判断是否是数组
+(BOOL)isArray:(NSArray *)array{
    
    if (array == nil) {
        return NO;
    }
    if ([array isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if (![array isKindOfClass:[NSArray class]]){
        return NO;
    }
    return YES;
}

#pragma mark 判断是否是字典
+(BOOL)isDictionary:(NSDictionary *)dic{
    
    if (dic == nil) {
        return NO;
    }
    if ([dic isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([dic isEqual:[NSNull null]]) {
        return NO;
    }
    if (![dic isKindOfClass:[NSDictionary class]]){
        return NO;
    }
    return YES;
}
#pragma mark 判断是否是字符串
+(BOOL)isString:(NSString *)string{
    
    if (string == nil) {
        return NO;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if (![string isKindOfClass:[NSString class]]){
        return NO;
    }
    if ([string isEqualToString:@"null"]) {
        return NO;
    }
    if ([string isEqualToString:@"<null>"]) {
        return NO;
    }
    if ([string isEqualToString:@"(null)"]) {
        return NO;
    }
    return YES;
}

+ (void)saveData:(NSObject *)object forKey:(NSString *)key{

    //把相应的 object 压缩对象成为二进制数据
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    
    //把压缩好的数据用 KVC 方式保存起来
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

}
+ (void)saveValue:(NSString *)value forKey:(NSString *)key{
    
    [[NSUserDefaults standardUserDefaults] setObject:value?value:@"null" forKey:key];
}

+ (NSObject *)getDataFromKey:(NSString *)key {
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return obj;
}


+ (NSObject *)getValueFromKey:(NSString *)key {
    
    NSString *value = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:key]];
    
    return value;
}

+ (void)deleteObjectForKey:(NSString *)key{

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];

    [[NSUserDefaults standardUserDefaults] synchronize];

}

+ (void)saveImageToLocalImage:(UIImage *)image forKey:(NSString *)key{
    // 本地沙盒目录

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    // 得到本地沙盒中名为"MyImage"的路径，"MyImage"是保存的图片名

    NSString *imageFilePath = [path stringByAppendingPathComponent:key];

    // 将取得的图片写入本地的沙盒中，其中0.5表示压缩比例，1表示不压缩，数值越小压缩比例越大

    BOOL success = [UIImageJPEGRepresentation(image, 1) writeToFile:imageFilePath atomically:YES];

    if (success){

    NSLog(@"写入本地成功");

    }
}

+ (UIImage *)getImageFromLocalForKey:(NSString *)key{
    // 本地沙盒目录

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    // 得到本地沙盒中名为"MyImage"的路径，"MyImage"是保存的图片名

    NSString *imageFilePath = [path stringByAppendingPathComponent:key];
    
    // 拿到沙盒路径图片

    UIImage *imgFromUrl=[[UIImage alloc]initWithContentsOfFile:imageFilePath];
    
    return imgFromUrl;
}


+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

+ (CGSize)getAttributeSizeWithText:(NSString *)text fontSize:(int)fontSize
{
    CGSize size=[text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
    
    if (@available(iOS 7.0, *)) {
        
        size=[text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
    }else{
        
        NSAttributedString *attributeSting = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
        size = [attributeSting size];
    }
    
    return size;
}


//MARK:image转base64
+ (NSString *)imageToString:(UIImage *)image {

//    NSData *imagedata = UIImagePNGRepresentation(image);
    CGFloat compression = 1;
    NSData *imagedata = UIImageJPEGRepresentation(image, compression);

    NSString *image64 = [imagedata base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    image64 = [NSString stringWithFormat:@"%@%@", [self imageFormatFromImageData:imagedata], image64];
    
    return image64;

}


//图片格式检查 data:image/jpg;base64,
+ (NSString *)imageFormatFromImageData:(NSData *)imageData{
    
    uint8_t first_byte;
    [imageData getBytes:&first_byte length:1];
    switch (first_byte) {
        case 0xFF:
            return @"data:image/jpeg;base64,";
        case 0x89:
            return @"data:image/png;base64,"; // https://www.w3.org/TR/PNG-Structure.html
        case 0x47:
            return @"data:image/gif;base64,";
        case 0x49:
        case 0x4D:
            return @"data:image/tiff;base64,";
        case 0x52:
            if ([imageData length] < 12) {
                return nil;
            }
            
            NSString *dataString = [[NSString alloc] initWithData:[imageData subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([dataString hasPrefix:@"RIFF"] && [dataString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            return nil;
    }
    return nil;
}

//MARK:image转base64
+ (NSString *)imageToBase64String:(UIImage *)image {

//    NSData *imagedata = UIImagePNGRepresentation(image);
    CGFloat compression = 1;
    NSData *imagedata = UIImageJPEGRepresentation(image, compression);

    NSString *image64 = [imagedata base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    image64 = [NSString stringWithFormat:@"%@", image64];
    
    return image64;

}

+(CGSize)getImageSizeWithURL:(id)imageURL

{
    NSURL* URL = nil;
    
    if([imageURL isKindOfClass:[NSURL class]]){
        
        URL = imageURL;
    }
    
    if([imageURL isKindOfClass:[NSString class]]){

        URL = [NSURL URLWithString:imageURL];

    }
    
    if(URL == nil){
        
        return CGSizeZero;// url不正确返回CGSizeZero
    }


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];

    NSString* pathExtendsion = [URL.pathExtension lowercaseString];

    CGSize size = CGSizeZero;

    if([pathExtendsion isEqualToString:@"png"]){

        size = [self getPNGImageSizeWithRequest:request];

    }
    else if([pathExtendsion isEqual:@"gif"]){
        
        size = [self getGIFImageSizeWithRequest:request];

    }
    else{
        
        size = [self getJPGImageSizeWithRequest:request];

    }
    if(CGSizeEqualToSize(CGSizeZero, size))// 如果获取文件头信息失败,发送异步请求请求原图
    {

        NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];

        UIImage* image = [UIImage imageWithData:data];

        if(image){

            size = image.size;

        }

    }
    return size;

}


//MARK:  获取PNG图片的大小

+(CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request

{
    [request setValue:@"bytes=16-23"forHTTPHeaderField:@"Range"];

    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    if(data.length ==8){

        int w1 =0, w2 =0, w3 =0, w4 =0;

        [data getBytes:&w1 range:NSMakeRange(0,1)];

        [data getBytes:&w2 range:NSMakeRange(1,1)];

        [data getBytes:&w3 range:NSMakeRange(2,1)];

        [data getBytes:&w4 range:NSMakeRange(3,1)];

        int w = (w1 <<24) + (w2 <<16) + (w3 <<8) + w4;

        int h1 =0, h2 =0, h3 =0, h4 =0;

        [data getBytes:&h1 range:NSMakeRange(4,1)];

        [data getBytes:&h2 range:NSMakeRange(5,1)];

        [data getBytes:&h3 range:NSMakeRange(6,1)];

        [data getBytes:&h4 range:NSMakeRange(7,1)];

        int h = (h1 <<24) + (h2 <<16) + (h3 <<8) + h4;

        return CGSizeMake(w, h);

    }
    return CGSizeZero;
}

//  获取gif图片的大小

+(CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request{
    
    [request setValue:@"bytes=6-9"forHTTPHeaderField:@"Range"];

    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    if(data.length ==4){

        short w1 =0, w2 =0;

        [data getBytes:&w1 range:NSMakeRange(0,1)];

        [data getBytes:&w2 range:NSMakeRange(1,1)];

        short w = w1 + (w2 <<8);

        short h1 =0, h2 =0;

        [data getBytes:&h1 range:NSMakeRange(2,1)];

        [data getBytes:&h2 range:NSMakeRange(3,1)];

        short h = h1 + (h2 <<8);

        return CGSizeMake(w, h);

    }
    return CGSizeZero;
}

//MARK:获取jpg图片的大小

+(CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request{

    [request setValue:@"bytes=0-209"forHTTPHeaderField:@"Range"];

    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    if([data length] <=0x58) {

        return CGSizeZero;

    }
    
    if([data length] <210) {// 肯定只有一个DQT字段

        short w1 = 0, w2 = 0;
        
        [data getBytes:&w1 range:NSMakeRange(0x60,0x1)];

        [data getBytes:&w2 range:NSMakeRange(0x61,0x1)];

        short w = (w1 <<8) + w2;

        short h1 =0, h2 =0;

        [data getBytes:&h1 range:NSMakeRange(0x5e,0x1)];

        [data getBytes:&h2 range:NSMakeRange(0x5f,0x1)];

        short h = (h1 <<8) + h2;

        return CGSizeMake(w, h);

    } else {

        short word =0x0;

        [data getBytes:&word range:NSMakeRange(0x15,0x1)];

        if(word ==0xdb) {

            [data getBytes:&word range:NSMakeRange(0x5a,0x1)];

            if(word ==0xdb) {// 两个DQT字段
                
                short w1 =0, w2 =0;

                [data getBytes:&w1 range:NSMakeRange(0xa5,0x1)];

                [data getBytes:&w2 range:NSMakeRange(0xa6,0x1)];

                short w = (w1 <<8) + w2;

                short h1 =0, h2 =0;

                [data getBytes:&h1 range:NSMakeRange(0xa3,0x1)];

                [data getBytes:&h2 range:NSMakeRange(0xa4,0x1)];

                short h = (h1 <<8) + h2;

                return CGSizeMake(w, h);

            } else{// 一个DQT字段
                
                short w1 =0, w2 =0;

                [data getBytes:&w1 range:NSMakeRange(0x60,0x1)];

                [data getBytes:&w2 range:NSMakeRange(0x61,0x1)];

                short w = (w1 <<8) + w2;

                short h1 =0, h2 =0;

                [data getBytes:&h1 range:NSMakeRange(0x5e,0x1)];

                [data getBytes:&h2 range:NSMakeRange(0x5f,0x1)];

                short h = (h1 <<8) + h2;

                return CGSizeMake(w, h);

            }

        } else {

            return CGSizeZero;

        }

    }

}


+(void)updateWithAPPID:(NSString *)appId withBundleId:(NSString *)bundelId block:(UpdateBlock)block{
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    __block NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    NSURLRequest *request;
    if (appId != nil) {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",appId]]];
        NSLog(@"【1】当前为APPID检测，您设置的APPID为:%@  当前版本号为:%@",appId,currentVersion);
    }else if (bundelId != nil){
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@&country=us",bundelId]]];
        NSLog(@"【1】当前为BundelId检测，您设置的bundelId为:%@  当前版本号为:%@",bundelId,currentVersion);
    }else{
        NSString *currentBundelId=infoDic[@"CFBundleIdentifier"];
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@&country=us",currentBundelId]]];
        NSLog(@"【1】当前为自动检测检测,  当前版本号为:%@",currentVersion);
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSLog(@"【2】开始检测...");
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"【3】检测失败，原因：\n%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                block(currentVersion,@"",@"",@"",NO);
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if ([appInfoDic[@"resultCount"] integerValue] == 0) {
                NSLog(@"检测出未上架的APP或者查询不到");
                block(currentVersion,@"",@"",@"",NO);
                return;
            }
            NSLog(@"【3】苹果服务器返回的检测结果：\n appId = %@ \n bundleId = %@ \n 开发账号名字 = %@ \n 商店版本号 = %@ \n 应用名称 = %@ \n 打开连接 = %@",appInfoDic[@"results"][0][@"artistId"],appInfoDic[@"results"][0][@"bundleId"],appInfoDic[@"results"][0][@"artistName"],appInfoDic[@"results"][0][@"version"],appInfoDic[@"results"][0][@"trackName"],appInfoDic[@"results"][0][@"trackViewUrl"]);
            NSString *appStoreVersion = appInfoDic[@"results"][0][@"version"];
            currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            if (currentVersion.length==2) {
                currentVersion  = [currentVersion stringByAppendingString:@"0"];
            }else if (currentVersion.length==1){
                currentVersion  = [currentVersion stringByAppendingString:@"00"];
            }
            appStoreVersion = [appStoreVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            if (appStoreVersion.length==2) {
                appStoreVersion  = [appStoreVersion stringByAppendingString:@"0"];
            }else if (appStoreVersion.length==1){
                appStoreVersion  = [appStoreVersion stringByAppendingString:@"00"];
            }
            if([currentVersion floatValue] < [appStoreVersion floatValue])
            {
                NSLog(@"【4】判断结果：当前版本号%@ < 商店版本号%@ 需要更新\n=========我是分割线========",[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],appInfoDic[@"results"][0][@"version"]);
                block(currentVersion,appInfoDic[@"results"][0][@"version"],appInfoDic[@"results"][0][@"trackViewUrl"],appInfoDic[@"results"][0][@"releaseNotes"],YES);
            }else{
                NSLog(@"【4】判断结果：当前版本号%@ > 商店版本号%@ 不需要更新\n========我是分割线========",[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],appInfoDic[@"results"][0][@"version"]);
                block(currentVersion,appInfoDic[@"results"][0][@"version"],appInfoDic[@"results"][0][@"trackViewUrl"],appInfoDic[@"results"][0][@"releaseNotes"],NO);
            }
        });
    }];
    [task resume];
}



+(NSData *)compressWithImage:(UIImage *)img MaxLength:(NSUInteger)maxLength{
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(img, compression);
    NSLog(@"Before compressing quality, image size = %ld KB",data.length/1024);
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(img, compression);
        //NSLog(@"Compression = %.1f", compression);
        //NSLog(@"In compressing quality loop, image size = %ld KB", data.length / 1024);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    NSLog(@"After compressing quality, image size = %ld KB", data.length / 1024);
    if (data.length < maxLength) return data;
    UIImage *resultImage = [UIImage imageWithData:data];
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        //NSLog(@"Ratio = %.1f", ratio);
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
        //NSLog(@"In compressing size loop, image size = %ld KB", data.length / 1024);
    }
    NSLog(@"After compressing size loop, image size = %ld KB", data.length / 1024);
    return data;
}

+ (UIImage *)base64stringToImage:(NSString *)str {

    NSData * imageData =[[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];

    UIImage *photo = [UIImage imageWithData:imageData];

    return photo;
}

+ (void)saveImageToAlbum:(UIImage *)image{
    
    [SVProgressHUD showWithStatus:@"保存中"];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{

    if (error == NULL) {
        
        DLog(@"保存成功！");
//        [PJToastView showInView:[UIApplication sharedApplication].keyWindow text:@"保存成功" duration:2 autoHide:YES];
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
    }else{
        
        [SVProgressHUD showErrorWithStatus:@"保存失败!"];
//        [PJToastView showInView:[UIApplication sharedApplication].keyWindow text:@"保存失败" duration:2 autoHide:YES];
        DLog(@"保存失败！");
    }
}


+ (void)addBorderWithView:(UIView *)view Color:(UIColor *)color BorderWidth:(CGFloat)borderWidth CornerRadius:(CGFloat)cornerRadius{
    view.layer.cornerRadius = cornerRadius;//设置那个圆角的有多圆
    view.layer.borderWidth = borderWidth;//设置边框的宽度，当然可以不要
    view.layer.borderColor = [color CGColor];//设置边框的颜色
    view.layer.masksToBounds = YES;//设为NO去试试
}

//缩放动画
+ (void)showExChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = dur;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    [changeOutView.layer addAnimation:animation forKey:nil];
}

//MARK:给view添加阴影
+ (void)addShadowWithView:(UIView *)view Color:(UIColor *)color{
    
//    UIBezierPath *shadowPath = [UIBezierPath
//    bezierPathWithRect:view.bounds];
//    view.layer.masksToBounds = NO;
//    view.layer.shadowColor = color.CGColor;
//    view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
//    view.layer.shadowOpacity = 0.5f;
//    view.layer.shadowPath = shadowPath.CGPath;
    
    view.layer.shadowColor=color.CGColor;

    view.layer.shadowOffset = CGSizeMake(2,2);

    view.layer.shadowOpacity = 0.3;//阴影透明度，默认0

    view.layer.shadowRadius = 3;//阴影半径，默认3
}

+ (void)dismissExChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur{
    
//    changeOutView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);//将要显示的view按照正常比例显示出来
//    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //InOut 表示进入和出去时都启动动画
//    [UIView setAnimationDuration:dur];//动画时间
//    changeOutView.transform=CGAffineTransformMakeScale(0.01f, 0.01f);//先让要显示的view最小直至消失
//    [UIView commitAnimations]; //启动动画
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = dur;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    [changeOutView.layer addAnimation:animation forKey:nil];
}


/**
 *  计算富文本字体高度
 *
 *  @param lineSpeace 行高
 *  @param font       字体
 *  @param width      字体所占宽度
 *
 *  @return 富文本高度
 */
+ (CGFloat)getSpaceLabelHeightwithAttrstr:(NSMutableAttributedString *)attrs Speace:(CGFloat)lineSpeace withFont:(UIFont*)font withWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    //    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    /** 行高 */
    paraStyle.lineSpacing = lineSpeace;
    // NSKernAttributeName字体间距
    CGSize size = [attrs boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size.height;
}

+ (NSString *)gs_jsonStringCompactFormatForDictionary:(NSDictionary *)dicJson {

    if (![dicJson isKindOfClass:[NSDictionary class]] || ![NSJSONSerialization isValidJSONObject:dicJson]) {

        return nil;

    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:0 error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;

}


/**
 *  根据图片url获取图片尺寸
 */
+ (CGSize)getImageSizeInfoWithURL:(id)URL{
    NSURL * url = nil;
    if ([URL isKindOfClass:[NSURL class]]) {
        url = URL;
    }
    if ([URL isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:URL];
    }
    if (!URL) {
        return CGSizeZero;
    }
    CGImageSourceRef imageSourceRef =     CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    CGFloat width = 0, height = 0;
    if (imageSourceRef) {
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
      if (imageProperties != NULL) {
          CFNumberRef widthNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
          if (widthNumberRef != NULL) {
              CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
          }
          CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
          if (heightNumberRef != NULL) {
            CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
        }
        CFRelease(imageProperties);
    }
    CFRelease(imageSourceRef);
    }
    return CGSizeMake(width, height);
}

#pragma mark - 获取当前屏幕显示的VC
+ (UIViewController *)p_getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    }else if([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    }else{
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

//MARK:利用正则表达式验证
+(BOOL)isValidateEmail:(NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    return [emailTest evaluateWithObject:email];
}

+ (int)isCorrectPwd:(NSString *)password{
    
    //数字条件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];

    //符合数字条件的有几个字节
    NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:password

                                                                       options:NSMatchingReportProgress

                                                                         range:NSMakeRange(0, password.length)];
    //英文字条件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];

    //符合英文字条件的有几个字节
    NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:password options:NSMatchingReportProgress range:NSMakeRange(0, password.length)];

    if (tNumMatchCount == password.length) {

        //全部符合数字，表示沒有英文
        return 1;

    } else if (tLetterMatchCount == password.length) {

        //全部符合英文，表示沒有数字
        return 2;

    } else if (tNumMatchCount + tLetterMatchCount == password.length && password.length >=8 && password.length <= 30) {

        //符合英文和符合数字条件的相加等于密码长度 且密码长度在规定范围内
        return 3;

    }
    //可能包含标点符号的情況，或是包含非英文的文字，这里再依照需求详细判断想呈现的错误
    return 4;
}

+ (BOOL)isAvailablePwd:(NSString *)password{
    
    if (password.length<8) {
        return NO;
    }
    
    NSInteger alength = [password length];

    BOOL daxie = NO;
    BOOL xiaoxie = NO;
    BOOL num = NO;
    
    for (int i = 0; i<alength; i++) {
        
        char commitChar = [password characterAtIndex:i];
        NSString *temp = [password substringWithRange:NSMakeRange(i,1)];
        const char *u8Temp = [temp UTF8String];
        
        if (3==strlen(u8Temp)){
            
            NSLog(@"字符串中含有中文");
            return NO;
        }else if((commitChar>64)&&(commitChar<91)){
            
            NSLog(@"字符串中含有大写英文字母");
            daxie = YES;
        }else if((commitChar>96)&&(commitChar<123)){
            
            NSLog(@"字符串中含有小写英文字母");
            xiaoxie = YES;
        }else if((commitChar>47)&&(commitChar<58)){
            
            NSLog(@"字符串中含有数字");
            num = YES;
        }else{
            
            NSLog(@"字符串中含有非法字符");
            return NO;
        }
    }
    if (daxie && xiaoxie && num) {
        return YES;
    }
    return NO;
}


//MARK:MD5加密
+ (NSString *)md5EncryptWithString:(NSString *)string EncryptionKey:(NSString *)encryptionKey{
    return [self md5:[NSString stringWithFormat:@"%@%@", encryptionKey, string]];
}


+ (NSString *)md5:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}

//MARK:哈希加密
+(NSString *)SHA256:(NSString *)string
{
    const char* str = [string UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    ret = (NSMutableString *)[ret lowercaseString];
    return ret;
}

//MARK:获取当前时间戳
+(NSString *)getNowTimeTimestamp{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;

    [formatter setDateStyle:NSDateFormatterMediumStyle];

    [formatter setTimeStyle:NSDateFormatterShortStyle];

    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要

    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];

    [formatter setTimeZone:timeZone];

    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];

    return timeSp;

}

//MARK:时间戳变为格式时间
+ (NSString *)ConvertStrToTime:(NSString *)timeStr {
    long long time=[timeStr longLongValue];
    //如果服务器返回的是13位字符串，需要除以1000，否则显示不正确(13位其实代表的是毫秒，需要除以1000)
    if (timeStr.length == 13) {
        
        time = [timeStr longLongValue] / 1000;
    }
    
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString*timeString=[formatter stringFromDate:date];
    
    return timeString;
}

//MARK:获取设备UUID
+(NSString *)getUUID {
    
    NSString * strUUID = (NSString *)[KeyChainStore load:@"com.vbhledger.Taft"];
    
    //首次执行该方法时，uuid为空
    
    if ([strUUID isEqualToString:@""] || !strUUID)
        
    {
        
        //生成一个uuid的方法
        
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain
        
        [KeyChainStore save:@"com.vbhledger.Taft" data:strUUID];
        
    }
    
    return strUUID;
}

//MARK:获取ios设备号
+ (NSString *)platformString {

    //需要导入头文件：#import <sys/utsname.h>
    NSString *padType = @"";
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";

    if ([deviceString isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";

    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";

    if ([deviceString isEqualToString:@"iPad1,1"]){
        padType = @"ipad";
        return @"iPad";
    }
    if ([deviceString isEqualToString:@"iPad1,2"]){
        padType = @"ipad";
        return @"iPad 3G";
    }
    if ([deviceString isEqualToString:@"iPad2,1"]){
        padType = @"ipad";
        return @"iPad 2 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad2,2"]){
        padType = @"ipad";
        return @"iPad 2";
    }
    if ([deviceString isEqualToString:@"iPad2,3"]){
        padType = @"ipad";
        return @"iPad 2 (CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad2,4"]){
        padType = @"ipad";
        return @"iPad 2";
    }
    if ([deviceString isEqualToString:@"iPad2,5"]){
        padType = @"ipad";
        return @"iPad Mini (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad2,6"]){
        padType = @"ipad";
        return @"iPad Mini";
    }
    if ([deviceString isEqualToString:@"iPad2,7"]){
        padType = @"ipad";
        return @"iPad Mini (GSM+CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad3,1"]){
        padType = @"ipad";
        return @"iPad 3 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad3,2"]){
        padType = @"ipad";
        return @"iPad 3 (GSM+CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad3,3"]){
        padType = @"ipad";
        return @"iPad 3";
    }
    if ([deviceString isEqualToString:@"iPad3,4"]){
        padType = @"ipad";
        return @"iPad 4 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad3,5"]){
        padType = @"ipad";
        return @"iPad 4";
    }
    if ([deviceString isEqualToString:@"iPad3,6"]){
        padType = @"ipad";
        return @"iPad 4 (GSM+CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad4,1"]){
        padType = @"ipad";
        return @"iPad Air (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad4,2"]){
        padType = @"ipad";
        return @"iPad Air (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad4,4"]){
        padType = @"ipad";
        return @"iPad Mini 2 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad4,5"]){
        padType = @"ipad";
        return @"iPad Mini 2 (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad4,6"]){
        padType = @"ipad";
        return @"iPad Mini 2";
    }
    if ([deviceString isEqualToString:@"iPad4,7"]){
        padType = @"ipad";
        return @"iPad Mini 3";
    }
    if ([deviceString isEqualToString:@"iPad4,8"]){
        padType = @"ipad";
        return @"iPad Mini 3";
    }
    if ([deviceString isEqualToString:@"iPad4,9"]){
        padType = @"ipad";
        return @"iPad Mini 3";
    }
    if ([deviceString isEqualToString:@"iPad5,1"]){
        padType = @"ipad";
        return @"iPad Mini 4 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad5,2"]){
        padType = @"ipad";
        return @"iPad Mini 4 (LTE)";
    }
    if ([deviceString isEqualToString:@"iPad5,3"]){
        padType = @"ipad";
        return @"iPad Air 2";
    }
    if ([deviceString isEqualToString:@"iPad5,4"]){
        padType = @"ipad";
        return @"iPad Air 2";
    }
    if ([deviceString isEqualToString:@"iPad6,3"]){
        padType = @"ipad";
        return @"iPad Pro 9.7";
    }
    if ([deviceString isEqualToString:@"iPad6,4"]){
        padType = @"ipad";
        return @"iPad Pro 9.7";
    }
    if ([deviceString isEqualToString:@"iPad6,7"]){
        padType = @"ipad";
        return @"iPad Pro 12.9";
    }
    if ([deviceString isEqualToString:@"iPad6,8"]){
        padType = @"ipad";
        return @"iPad Pro 12.9";
    }
    if ([deviceString isEqualToString:@"iPad6,11"]){
        padType = @"ipad";
        return @"iPad 5 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad6,12"]){
        padType = @"ipad";
        return @"iPad 5 (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad7,1"]){
        padType = @"ipad";
        return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad7,2"]){
        padType = @"ipad";
        return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad7,3"]){
        padType = @"ipad";
        return @"iPad Pro 10.5 inch (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad7,4"]){
        padType = @"ipad";
        return @"iPad Pro 10.5 inch (Cellular)";
    }

    if ([deviceString isEqualToString:@"AppleTV2,1"])    return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])    return @"Apple TV 4";

    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";

    return deviceString;


}

//MARK:改变文字中的个别文字的大小颜色等属性
+ (void)YHLabelAttributedString:(UILabel *)label firstText:(NSString *)oneIndex toEndText:(NSString *)endIndex textColor:(UIColor *)color textSize:(CGFloat)size {
    // 创建 Attributed
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:label.text];
    // 需要改变的首位文字位置
    NSUInteger firstLoc = [[noteStr string] rangeOfString:oneIndex].location;
    // 需要改变的末位文字位置
//    NSUInteger endLoc = [[noteStr string] rangeOfString:endIndex].location + 1;
    NSUInteger endLoc = [[noteStr string] rangeOfString:endIndex].location + [[noteStr string] rangeOfString:endIndex].length;
    // 需要改变的区间
    NSRange range = NSMakeRange(firstLoc, endLoc - firstLoc);
    // 改变颜色
    [noteStr addAttribute:NSForegroundColorAttributeName value:color range:range];
    // 改变字体大小及类型
    [noteStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:size] range:range];
    // 为 label 添加 Attributed
    [label setAttributedText:noteStr];
}


//MARK:获取钱包信息
+ (NSString *)getWalletInfo:(NSString *)wallet_id Type:(NSString *)type{// name:返回name ...
    
    NSString *walletName = @"";
    
    NSArray *allWallet = [Wallet MR_findByAttribute:@"wallet_id" withValue:wallet_id];
    
    for (Wallet *wallet in allWallet) {
        
        if ([type isEqualToString:@"name"]) {
            
            return wallet.name;
        }
        if ([type isEqualToString:@"type"]) {
            
            return wallet.type;
        }
        if ([type isEqualToString:@"password"]) {
            
            return wallet.password;
        }
        if ([type isEqualToString:@"is_backup"]) {
            
            return [NSString stringWithFormat:@"%d", wallet.is_backup];
        }
    }
    return walletName;
}
//MARK:保留固定小数点金额
+(NSString *)stringByYouWantWithOriginString:(NSString *)originString{
    NSString *MM = @"";
    if ([originString containsString:@"."]) {
        NSArray *array_XString = [originString componentsSeparatedByString:@"."];
        NSString *string_XLast = array_XString.lastObject;
        if (string_XLast.length == 1 ) {
            MM = [NSString stringWithFormat:@"%.1f",[originString floatValue]];
        }else if (string_XLast.length >=2){
            MM = [NSString stringWithFormat:@"%.2f",[originString floatValue]];
        }
        if (string_XLast.length >=2){
            if ([MM hasSuffix:@"00"]) {
                MM = [NSString stringWithFormat:@"%.0f" , [MM floatValue]];
            }else if ([MM hasSuffix:@"0"]){
                MM = [NSString stringWithFormat:@"%.1f" , [MM floatValue]];
            }
        }else if (string_XLast.length ==1 ){
            if ([MM hasSuffix:@"0"]) {
                MM =[NSString stringWithFormat:@"%.0f" , [MM floatValue]];
            }
        }
    }else{
        MM =originString;
    }
    if ([MM hasSuffix:@".00"]) {
        MM = [NSString stringWithFormat:@"%.0f",[MM floatValue]];
    }
    return MM;
}

/**
 过滤器/ 将.2f格式化的字符串，去除末尾0
 @param numberStr .2f格式化后的字符串
 @return 去除末尾0之后的
 */
+ (NSString *)removeSuffix:(NSString *)numberStr{
    
    if (numberStr.length > 1) {
        
        if ([numberStr componentsSeparatedByString:@"."].count == 2) {
            NSString *last = [numberStr componentsSeparatedByString:@"."].lastObject;
            if ([last isEqualToString:@"00"]) {
                numberStr = [numberStr substringToIndex:numberStr.length - (last.length + 1)];
                return numberStr;
            }else{
                if ([[last substringFromIndex:last.length -1] isEqualToString:@"0"]) {
                    numberStr = [numberStr substringToIndex:numberStr.length - 1];
                    return numberStr;
                }
            }
        }
        return numberStr;
    }else{
        return @"0";
    }
}

//MARK:字符串截取保留小数点后两位
+(NSString*)getTheCorrectNum:(NSString*)tempString
{
    if ([tempString isEqualToString:@"0"]) {
        return @"0";
    }
    //计算截取的长度
    NSUInteger endLength = tempString.length;
    //判断字符串是否包含 .
    if ([tempString containsString:@"."]) {
        //取得 . 的位置
        NSRange pointRange = [tempString rangeOfString:@"."];
        NSLog(@"取得 . 的位置:%lu",pointRange.location);
        //判断 . 后面有几位
        NSUInteger f = tempString.length - 1 - pointRange.location;
        //如果大于2位就截取字符串保留两位,如果小于两位,直接截取
        if (f > 3) {
            endLength = pointRange.location + 3;
        }
    }
    //先将tempString转换成char型数组
    NSUInteger start = 0;
    const char *tempChar = [tempString UTF8String];
    //遍历,去除取得第一位不是0的位置
    for (int i = 0; i < tempString.length; i++) {
        if (tempChar[i] == '0') {
            start++;
        }else {
            break;
        }
    }
    //根据最终的开始位置,计算长度,并截取
    NSRange range = {start,endLength-start};
    tempString = [tempString substringWithRange:range];
    return tempString;
}

+ (NSString*)removeFloatAllZeroByString:(NSString *)balance{
    
    NSString *testNumber = balance;
    NSString *outNumber  = [NSString
        stringWithFormat:@"%@", [[NSDecimalNumber decimalNumberWithString:testNumber] stringValue]];
    return outNumber;
}

/// 截取指定小数位的值
/// @param price 需要转化的数据
/// @param position 有效小数位
+ (NSString *)notRounding:(NSString*)price afterPoint:(NSInteger)position{
    
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *roundedOunces;
    roundedOunces = [[NSDecimalNumber decimalNumberWithString:price] decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

    return [NSString stringWithFormat:@"%@",roundedOunces];
}
+ (NSString *)getStatusBarNetwork{
//    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
//    [[AFNetworkReachabilityManager sharedManager ] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        switch (status) {
//            case -1:
//                NSLog(@"未知网络");
//                break;
//            case 0:
//                NSLog(@"网络不可达");
//                break;
//            case 1:
//                NSLog(@"GPRS网络");
//                break;
//            case 2:
//                NSLog(@"wifi网络");
//                break;
//            default:
//                break;
//        }
//        if(status ==AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi)
//        {
//            NSLog(@"有网");
//        }else
//        {
//            NSLog(@"没有网");
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localized(@"设备已离线") message:Localized(@"网络已断开，请检查网络链接。") delegate:self cancelButtonTitle:Localized(@"知道了") otherButtonTitles:nil, nil];
//            alert.delegate = self;
//            [alert show];
//            return @"";
//        }
//    }];
    return @"unknow";
}

+ (BOOL)timestampSubtractionWithPastTime:(NSString *)pastTime{
    
    NSString *beginTimestamp = pastTime;
    NSString *endTimestamp = [self getNowTimeTimestamp];
        
    NSTimeInterval timer1 = [beginTimestamp doubleValue];
    NSTimeInterval timer2 = [endTimestamp doubleValue];
        
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timer1];
        
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:timer2];
        
    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit =NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:unit fromDate:date toDate:date2 options:0];

    if (cmps.day > 0) {
        return NO;
    }else if (cmps.hour > 0){
        return NO;
    }else if (cmps.minute < 10){
        return YES;
    }
    
    return NO;
}
//MARK:判断传入的时间是否大于1分钟
+ (BOOL)isOver1MinuteWithPastTime:(NSString *)pastTime{
    
    NSString *beginTimestamp = pastTime;
    NSString *endTimestamp = [self getNowTimeTimestamp];
        
    NSTimeInterval timer1 = [beginTimestamp doubleValue];
    NSTimeInterval timer2 = [endTimestamp doubleValue];
        
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timer1];
        
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:timer2];
        
    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit =NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:unit fromDate:date toDate:date2 options:0];

    if (cmps.day > 0) {
        return YES;
    }else if (cmps.hour > 0){
        return YES;
    }else if (cmps.minute > 1){
        return YES;
    }
    return NO;
}

//MARK:上次存储的时间是否超过24H
+ (BOOL)isOver24H{
    
    //获取上次存储的时间
    NSString *beginTimestamp = (NSString *)[self getValueFromKey:@"statisticalTime"];
    NSString *endTimestamp = [self getNowTimeTimestamp];
    if (!beginTimestamp || beginTimestamp.length < 1) {
        
        [PTool saveValue:[self getNowTimeTimestamp] forKey:@"statisticalTime"];
        return YES;
    }
        
    NSTimeInterval timer1 = [beginTimestamp doubleValue];
    NSTimeInterval timer2 = [endTimestamp doubleValue];
        
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timer1];
        
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:timer2];
        
    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit =NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:unit fromDate:date toDate:date2 options:0];

    if (cmps.day > 0) {
        return YES;
    }
    return NO;
}
//MARK:统计日活
+ (void)dailyCount{
    
    if (![self isOver24H]) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/wallet/statistics/dailycount", (NSString *)[PTool getValueFromKey:walletHttpAPI]];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];//手机系统版本
    NSString *platformString = [NSString stringWithFormat:@"%@ %@", [PTool platformString], phoneVersion];//手机型号
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSString *uuid_string = [self getUUID];
    
    NSDictionary *param = @{
        @"phone_type":platformString,
        @"device_uuid":uuid_string,
        @"app_version":app_Version,
        @"brand":@"iPhone",
        @"os_version":phoneVersion
    };
//    //设置公共参数
//    [parameters setObject:platformString forKey:@"phone_type"]; //手机型号
//    [parameters setObject:uuid_string forKey:@"device_uuid"];   //设备唯一识别码
//    [parameters setObject:app_Version forKey:@"app_version"];   //当前APP版本号
//    [parameters setObject:@"iPhone" forKey:@"brand"];           //手机品牌
//    [parameters setObject:phoneVersion forKey:@"os_version"];   //系统版本
    
    [[PHTTPClient shareInstance] requestMethod:METHOD_POST parameters:param url:url success:^(id  _Nonnull responseObject) {
        
        [PTool saveValue:[self getNowTimeTimestamp] forKey:@"statisticalTime"];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

+ (CGFloat)getStatusBarHight {
    float statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
        statusBarHeight = statusBarManager.statusBarFrame.size.height;
    }
    else {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    return statusBarHeight;
}
//MARK:获取多语言：为swift而写
+ (NSString *)getLocalizedStringWithString:(NSString *)string{
    return Localized(string);
}

//MARK:为view添加渐变颜色
+ (void)addGradientForView:(UIView *)view StartPoint:(CGPoint)startPoint EndPoint:(CGPoint)endPoint StartColor:(UIColor *)startColor EndColor:(UIColor *)endColor{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    gradientLayer.locations = @[@0.3, @0.5, @1.0];
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    gradientLayer.frame = view.bounds;
    [view.layer addSublayer:gradientLayer];
}

//MARK:判断相机是否可以打开
+ (void)isCamCanOpenWithBlock:(void(^)(BOOL canOpen))canOpen{
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
                case AVAuthorizationStatusNotDetermined: {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if (granted) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                if (canOpen) {
                                    canOpen(YES);
                                }
                            });
                            NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                        } else {
                            NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                        }
                    }];
                    break;
                }
                case AVAuthorizationStatusAuthorized: {
                    
                    if (canOpen) {
                        canOpen(YES);
                    }
                    break;
                }
                case AVAuthorizationStatusDenied: {
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"温馨提示") message:Localized(@"相机授权提示") preferredStyle:(UIAlertControllerStyleAlert)];
                    UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:nil];
                    [alertC addAction:alertA];
                    [[self findVC] presentViewController:alertC animated:YES completion:nil];
                    break;
                }
                case AVAuthorizationStatusRestricted: {
                    NSLog(@"因为系统原因, 无法访问相册");
                    break;
                }
            default:
                break;
        }
        return;
    }
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"温馨提示") message:Localized(@"未检测到您的摄像头") preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:nil];
    [alertC addAction:alertA];
    [[self findVC] presentViewController:alertC animated:YES completion:nil];
}

//MARK:找到当前显示的控制器
+ (UIViewController *)findVC{
    
    UIViewController *currentShowViewController = [UIViewControllerCJHelper findCurrentShowingViewController];
    return currentShowViewController;
}

//MARK:获取GIF图片数组
+ (NSArray *)getImagesFromGIF:(NSString *)gifName {
    NSURL *gifImageUrl = [[NSBundle mainBundle]URLForResource:gifName withExtension:@"gif"];
    //获取Gif图的原数据
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)gifImageUrl, NULL);
    //获取Gif图有多少帧
    size_t count = CGImageSourceGetCount(gifSource);
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < count; i++) {
        //生成一张CGImageRef类型的图片
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [images addObject:image];
        CGImageRelease(imageRef);
    }
    //得到图片数组
    return images;
}

//
+ (NSString *)base58CheckSum:(NSString *)targetString{
    if (targetString.length != 42) {
        return @"";
    }
    
    return nil;
}

+ (void)getCurrentWalletPkString:(void (^)(NSString * _Nonnull))pkString{
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    NSArray * arr = [Coin MR_findByAttribute:@"address" withValue:defaultWallet];
    NSString * wallet_id = @"";
    for (Coin * coin in arr) {
        if ([coin.name isEqualToString:@"ETH"]) {
            wallet_id = coin.wallet_id;
        }
    }
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    PwdInputView * inputView = [[PwdInputView alloc] initWithFrame:keyWindow.bounds];
    inputView.titleLabel.text = Localized(@"输入钱包密码");
    inputView.inputString = ^(NSString * _Nonnull str) {
        [[PWallet shareInstance] verifyWalletPwdWithWalletID:wallet_id Pwd:str valid:^(BOOL valid) {
            if (valid) {
                if (pkString) {
                    [self getPkStringWithWalletID:wallet_id Password:str block:^(NSString *privateKey) {
                        if (privateKey && privateKey.length) {
                            pkString(privateKey);
                        } else {
                            [LSStatusBarHUD showMessageAndImage:Localized(@"获取私钥失败")];
                        }
                    }];
                }
            } else {
                [LSStatusBarHUD showMessageAndImage:Localized(@"密码错误")];
            }
        }];
    };
    [keyWindow addSubview:inputView];
}
    
+ (void)getPkStringWithWalletID:(NSString *)wallet_id Password:(NSString *)password block:(void((^)(NSString * privateKey)))block{
    NSArray *arr = [Wallet MR_findByAttribute:@"wallet_id" withValue:wallet_id];
    NSString *type = @"Multi";
    for (Wallet *wallet in arr) {
        type = wallet.type;
    }
    if (![type isEqualToString:@"Multi"]) {
        [[PWallet shareInstance] getPKDataFromSingleChainWithCoinType:@"ETH" WalletID:wallet_id Password:password privateKey:^(NSString * _Nonnull privateKey) {
            block(privateKey);
        } failure:^(NSError * _Nonnull failure) {
            [LSStatusBarHUD showMessageAndImage:Localized(@"未知错误，请重试")];
        }];
        return;
    }
    NSArray *coinArr = [Coin MR_findByAttribute:@"wallet_id" withValue:wallet_id];
    for (Coin *coins in coinArr) {
        if ([coins.name isEqualToString:@"ETH"]) {
            ApiExportPrivateKeyFromMasterRequest *req = [[ApiExportPrivateKeyFromMasterRequest alloc] init];
            req.account = coins.account;
            req.change = coins.change;
            req.coin = coins.coin;
            req.index = coins.index;
            req.passphrase = password;
            req.walletId = coins.wallet_id;
            req.keystoreDir = [[PWallet shareInstance] walletPath];
            NSError *error = nil;
            ApiExportPrivateKeyFromMasterResponse *res = Uv1ExportPrivateKeyFromMaster(req, &error);
            if (res.privateKey) {
                block(res.privateKey);
            }else{
                [LSStatusBarHUD showMessageAndImage:Localized(@"未知错误，请重试")];
            }
            Uv1GarbageCollection();
        }
    }
}
@end
