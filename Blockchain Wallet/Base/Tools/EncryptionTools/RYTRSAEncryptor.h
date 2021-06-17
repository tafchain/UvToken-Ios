//
//  RYTRSAEncryptor.h
//  SMSCodeTest
//
//  Created by timmy on 16/10/19.
//  Copyright © 2016年 任雨婷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rsa.h"


@interface RYTRSAEncryptor : NSObject

+ (void)keyWith:(void(^)(NSString *pubKey, NSString *priKey))block;

/**
 *  加密方法
 *
 *  @param str    需要加密的字符串
 *  @param pubKey 公钥字符串
 */
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;

+ (SecKeyRef)addPublicKey:(NSString *)key;

/**
 *  解密方法
 *
 *  @param str     需要解密的字符串
 *  @param privKey 私钥字符串
 */
+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;

+ (SecKeyRef)addPrivateKey:(NSString *)key;

RSA* createRSA(unsigned char* key);

EVP_PKEY*createEVP(unsigned char* key);

unsigned char* public_encrypt(unsigned char* data, int data_len, unsigned char* key, unsigned char* encrypted);

int private_decrypt(unsigned char* enc_data, int data_len, unsigned char* key, unsigned char* decrypted);

@end
