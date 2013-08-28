//
//  NSData+Bignum.m
//  AdyenClientsideEncryption
//
//  Created by Jeroen Koops on 8/7/13.
//  Copyright (c) 2013 Adyen. All rights reserved.
//

#import "NSData+Util.h"
#include <openssl/rand.h>

@implementation NSData (Util)

unsigned char parseHexDigit(unsigned char c) {
    if(c >= '0' && c <= '9') {
        return c - '0';
    } else if (c >= 'a' && c <= 'f') {
        return c + 10 - 'a';
    } else if (c >= 'A' && c <= 'F') {
        return c + 10 - 'A';
    } else {
        return 0;
    }
}

+ (NSData*)dataWithHexString:(NSString *)hexString {
    if(hexString.length & 1) {
        hexString = [@"0" stringByAppendingString:hexString];
    }
    unsigned char* inBuffer =
        (unsigned char*)[hexString dataUsingEncoding:NSASCIIStringEncoding].bytes;
    
    unsigned char* outBuffer = malloc(hexString.length / 2);
    
    for(NSInteger l=0; l<hexString.length; l+= 2) {
        outBuffer[l/2] =
            (parseHexDigit(inBuffer[l]) << 4) | parseHexDigit(inBuffer[l+1]);
    }
    return [NSData dataWithBytesNoCopy:outBuffer length:hexString.length/2];
}

+ (NSData*)secureRandomDataWithLength:(NSUInteger)length {
    unsigned char* random = malloc(length);
    RAND_bytes(random, length);
    return [NSData dataWithBytesNoCopy:random length:length];
}


- (BIGNUM*)newBignum {
    return BN_bin2bn(self.bytes, self.length, NULL);
}

- (NSString*)toHexString {
    NSMutableString* s = [[NSMutableString alloc] init];
    unsigned char* bytes = (unsigned char*)self.bytes;
    for(NSUInteger l=0; l<self.length; l++) {
        [s appendFormat:@"%02X", bytes[l]];
    }
    return s;
}

@end
