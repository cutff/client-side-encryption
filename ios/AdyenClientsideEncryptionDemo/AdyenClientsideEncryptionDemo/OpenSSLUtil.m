//
//  OpenSSLUtil.m
//  AdyenClientsideEncryption
//
//  Created by Willem Lobbezoo on 15-08-13.
//  Copyright (c) 2013 Adyen. All rights reserved.
//

#import "OpenSSLUtil.h"
#import "Logging.h"
#import <openssl/err.h>

@implementation OpenSSLUtil

+ (void)setOpenSSLError:(NSError**)error cause:(NSString*)cause {
    if(error) {
        *error = [self openSSLError:cause];
    }
}

+ (NSError*)openSSLError:(NSString*)cause {
    LOG(@"ERROR: %@", cause);
    char buf[120];
    unsigned long errorCode = ERR_get_error();
    ERR_error_string(errorCode, buf);
    
    NSString* localizedDescription =
    [[NSString alloc] initWithBytes:buf length:strlen(buf) encoding:NSUTF8StringEncoding];
    localizedDescription = [NSString stringWithFormat:@"%@: %@", cause, localizedDescription];
    return [[NSError alloc] initWithDomain:@"openssl"
                                      code:errorCode
                                  userInfo:@{ NSLocalizedDescriptionKey: localizedDescription }];
}

@end
