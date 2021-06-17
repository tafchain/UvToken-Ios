//
//  RYTAESEncryptor.m
//  SMSCodeTest
//
//  Created by timmy on 16/10/19.
//  Copyright © 2016年 任雨婷. All rights reserved.
//

#import "RYTAESEncryptor.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation RYTAESEncryptor

//AES加密
+ (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv withNSData:(NSData *)data
{
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    bzero(ivPtr, sizeof(ivPtr));
    
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    int newSize = 0;
    
    if(diff > 0)
    {
        newSize = (int)(dataLength + diff);
    }
    
    char dataPtr[newSize];
    memcpy(dataPtr, [data bytes], [data length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x00;
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,kCCAlgorithmAES128,0x00,keyPtr,kCCKeySizeAES128,ivPtr,dataPtr,sizeof(dataPtr),buffer,bufferSize,&numBytesEncrypted);
    
    if(cryptStatus == kCCSuccess)
    {
        //        NSData *data =[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        //        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    return nil;
}

//AES解密
+ (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv withNSData:(NSData *)data
{
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    bzero(ivPtr, sizeof(ivPtr));
    
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,kCCAlgorithmAES128,0x00,keyPtr,kCCKeySizeAES128,ivPtr,[data bytes],dataLength,buffer,bufferSize,&numBytesEncrypted);
    
    if(cryptStatus == kCCSuccess)
    {
        //        NSData *data =[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        // NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    return nil;
    
}


@end
