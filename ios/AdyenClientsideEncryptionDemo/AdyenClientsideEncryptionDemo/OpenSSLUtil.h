//
//  OpenSSLUtil.h
//  AdyenClientsideEncryption
//
//  Created by Willem Lobbezoo on 15-08-13.
//  Copyright (c) 2013 Adyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenSSLUtil : NSObject

+ (void)setOpenSSLError:(NSError**)error cause:(NSString*)cause;
+ (NSError*)openSSLError:(NSString*)cause;

@end
