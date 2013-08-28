//
//  EncryptionParameters.h
//  AdyenClientsideEncryption
//
//  Created by Jeroen Koops on 8/21/13.
//  Copyright (c) 2013 Adyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/evp.h>

typedef enum {
    EncryptionParametersVersion1 = 0,
    EncryptionParametersVersion2 = 1
} EncryptionParametersVersion;

@interface EncryptionParameters : NSObject

@property (readonly) EncryptionParametersVersion version;
@property (readonly) NSString* versionString;
@property (readonly) NSUInteger AESKeyLength;
@property (readonly) NSUInteger AESNonceLength;
@property (readonly) NSUInteger AESTagLength;
@property (readonly) NSData* defaultAssociatedData;
@property (readonly) BOOL useAssociatedData;
@property (readonly) const EVP_CIPHER* evpCipher;
@property (readonly) NSString* messagePrefix;

- (id)initWithVersion:(EncryptionParametersVersion)version;
@end
