//
//  Encrypter.h
//  AdyenClientsideEncryption
//
//  Created by Jeroen Koops on 8/7/13.
//  Copyright (c) 2013 Adyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncryptionParameters.h"

@interface Encrypter : NSObject

/**
 * Create a new `Encrypter`.
 * @param version the protocol version to be used. Generally, you will want to
 * use `EncryptionParametersVersion1`, declared in `EncryptionParameters.h`.
 * @param publicKey public key to be used for encryption. This comes in the
 * form of a very long string.
 */
- (id)initWithVersion:(EncryptionParametersVersion)version
            publicKey:(NSString*)publicKey;

/**
 * Same as `initWithVersion:publicKey:`, but adds the option to 
 * pass in additional data. If in doubt which initializer to use,
 * use `initWithVersion:publicKey:`.
 */
- (id)initWithVersion:(EncryptionParametersVersion)version
            publicKey:(NSString*)publicKey
       associatedData:(NSString*)adata;

/**
 * Encrypt the given plaintext.
 * @param plainText Plaintext to be encrypted
 * @param error optional pointer to an `NSError` pointer. If set,
 * and something goes wrong, the pointer will be set to point to
 * an `NSError` object containing error-details.
 * @return the encrypted plaintext, as a string, or `nil` if an error
 * occurred.
 */
- (NSString*)encrypt:(NSData*)plainText error:(NSError**)error;

@end
