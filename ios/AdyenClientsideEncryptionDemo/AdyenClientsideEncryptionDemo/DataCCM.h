//
//  DataCCM.h
//  AdyenClientsideEncryption
//
//  Created by Willem Lobbezoo on 13-08-13.
//  Copyright (c) 2013 Adyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCCM : NSObject

@property (nonatomic, strong) NSData* nonce;
@property (nonatomic, strong) NSData* key;
@property (nonatomic, strong) NSData* cipherText;
@property (nonatomic, strong) NSData* tag;

@end
