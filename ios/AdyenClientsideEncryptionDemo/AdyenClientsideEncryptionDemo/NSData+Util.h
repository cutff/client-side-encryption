//
//  NSData+Bignum.h
//  AdyenClientsideEncryption
//
//  Created by Jeroen Koops on 8/7/13.
//  Copyright (c) 2013 Adyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/bn.h>

@interface NSData (Util)

+ (NSData*)dataWithHexString:(NSString*)hexString;
+ (NSData*)secureRandomDataWithLength:(NSUInteger)length;
- (BIGNUM*)newBignum;

- (NSString*)toHexString;
@end
