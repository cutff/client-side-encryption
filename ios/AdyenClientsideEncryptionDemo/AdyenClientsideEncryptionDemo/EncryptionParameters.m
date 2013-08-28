//
//  EncryptionParameters.m
//  AdyenClientsideEncryption
//
//  Created by Jeroen Koops on 8/21/13.
//  Copyright (c) 2013 Adyen. All rights reserved.
//

#import "EncryptionParameters.h"

@interface EncryptionParameters ()
@property (nonatomic, assign) EncryptionParametersVersion version;
@end

@implementation EncryptionParameters

- (id)initWithVersion:(EncryptionParametersVersion)version {
    self = [super init];
    if(self) {
        self.version = version;
    }
    return self;
}

- (NSString*)versionString {
    switch(self.version) {
        case EncryptionParametersVersion1: return @"0_1_1";
        case EncryptionParametersVersion2: return @"0_1_2";
    }
}

- (NSData*)defaultAssociatedData {
    static dispatch_once_t once;
    static NSData* instance;
    dispatch_once(&once, ^{
        instance = [@"TBD" dataUsingEncoding:NSUTF8StringEncoding];
    });
    return instance;
}

- (NSUInteger)AESKeyLength {
    switch(self.version) {
        case EncryptionParametersVersion1: return 32;
        case EncryptionParametersVersion2: return 32;
    }
}

- (NSUInteger)AESNonceLength {
    switch(self.version) {
        case EncryptionParametersVersion1: return 12;
        case EncryptionParametersVersion2: return 12;
    }
}

- (NSUInteger)AESTagLength {
    switch(self.version) {
        case EncryptionParametersVersion1: return 8;
        case EncryptionParametersVersion2: return 16;
    }
}

- (BOOL)useAssociatedData {
    switch(self.version) {
        case EncryptionParametersVersion1: return NO;
        case EncryptionParametersVersion2: return YES;
    }
}

- (const EVP_CIPHER*)evpCipher {
    return EVP_aes_256_ccm();
}

- (NSString*)messagePrefix {
    return @"adyenio";
}
@end
