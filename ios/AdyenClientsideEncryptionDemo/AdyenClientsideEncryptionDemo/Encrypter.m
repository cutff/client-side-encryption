//
//  Encrypter.m
//  AdyenClientsideEncryption
//
//  Created by Jeroen Koops on 8/7/13.
//  Copyright (c) 2013 Adyen. All rights reserved.
//

#import "Logging.h"
#import "Encrypter.h"
#import "NSData+Util.h"
#import "NSData+Base64.h"
#import "NSString+Util.h"
#include "DataCCM.h"
#include "OpenSSLUtil.h"

#import <openssl/bn.h>
#import <openssl/rsa.h>
#import <openssl/err.h>
#import <openssl/evp.h>

#include <string.h>

@interface Encrypter ()
@property (nonatomic, strong) EncryptionParameters* parameters;
@property (nonatomic, strong) NSData* publicKeyExponent;
@property (nonatomic, strong) NSData* publicKeyModulus;
@property (nonatomic, strong) NSData* associatedData;
@end

@implementation Encrypter

+ (void)initialize {
    ERR_load_crypto_strings();
    OpenSSL_add_all_algorithms();
}

- (id)initWithVersion:(EncryptionParametersVersion)version
            publicKey:(NSString *)publicKey {
    return [self initWithVersion:version publicKey:publicKey associatedData:nil];
}

- (id)initWithVersion:(EncryptionParametersVersion)version
            publicKey:(NSString *)publicKey
       associatedData:(NSData *)associatedData {
    
    self = [super init];
    if(self) {
        NSArray* tokens = [publicKey componentsSeparatedByString:@"|"];
        if(tokens.count != 2 ||
           ![tokens[0] isHexString] ||
           ![tokens[1] isHexString]) {
            return nil;
        }
        self.parameters = [[EncryptionParameters alloc] initWithVersion:version];
        self.publicKeyExponent = [NSData dataWithHexString:tokens[0]];
        self.publicKeyModulus = [NSData dataWithHexString:tokens[1]];
        self.associatedData = associatedData ? associatedData : self.parameters.defaultAssociatedData;
    }
    return self;
}

- (NSString*)encrypt:(NSData*)plainText error:(NSError**)error {
    LOG(@"CCM mode encryption started");

    // step 1: generate a unique AES key
    // and (later) encrypt it with the public RSA key of the merchant
    NSData* sessionKey = [NSData secureRandomDataWithLength:self.parameters.AESKeyLength];
    
    // step 2: generate a nonce
    NSData* nonce = [NSData secureRandomDataWithLength:self.parameters.AESNonceLength];
    // step 3: perform the encryption operation
    DataCCM* dataCCM =
        [self aesEncrypt:plainText
                 withKey:sessionKey
                   nonce:nonce
                   error:error];
    
    // check if we got an enciphered text and an authentication tag,
    // if not, stop the show
    if (!dataCCM ||
        !dataCCM.cipherText ||
        !dataCCM.tag) {
        return nil; 
    }

    // step 4: compose and return the full message,
    // as it can be sent to the Adyen back end
    //
    // two message formats are supported:
    // version 0_1_1
    //   - key length  : 32
    //   - nonce length: 12
    //   - tag length  :  8
    //   - associated data : no
    // version 0_1_2
    //   - key length  : 32
    //   - nonce length: 12
    //   - tag length  : 16
    //   - associated data : yes
    //
    
    // format of the fully composed message:
    // - an Adyen identifying prefix ("adyenan") concatenated with a version number (0_1_2)
    // - a "$" separator
    // - RSA encrypted AES key, base64 encoded
    // - a "$" separator
    // - the plain text nonce, base64 encoded
    // - the AES encrypted message, base64 encoded
    // - the tag, base64 encoded
    LOG(@"message prefix        : %@", self.parameters.messagePrefix);
    LOG(@"message version       : %@", self.parameters.versionString);
    NSMutableData* payload = [NSMutableData data];
    [payload appendData:dataCCM.nonce];
    [payload appendData:dataCCM.cipherText];
    [payload appendData:dataCCM.tag];
    
    NSData* encryptedKey = [self rsaEncrypt:dataCCM.key
                                      error:error];
    NSString* result = nil;
    if(encryptedKey) {
        result = [NSString stringWithFormat:@"%@%@$%@$%@",
                            self.parameters.messagePrefix,
                            self.parameters.versionString,
                            [encryptedKey base64EncodedString],
                            [payload base64EncodedString]];
        LOG(@"fully composed encrypted message: %@", result);
    }
    
    // done
    LOG(@"CCM mode encryption completed");
    return result;
}

#pragma mark - Private utility methods

/**
 * The encryption requires AES encryption in CCM mode
 *
 * the nonce
 */
- (DataCCM*)aesEncrypt:(NSData*)plainText
               withKey:(NSData*)key
                 nonce:(NSData*)nonce
                 error:(NSError**)error {
#define FAIL(X) [OpenSSLUtil setOpenSSLError:error cause:X]; goto cleanup
    
    LOG(@"plain text            : %@", [plainText toHexString]);
    LOG(@"key                   : %@", [key       toHexString]);
    LOG(@"nonce                 : %@", [nonce     toHexString]);
    
    // create our output object
    DataCCM* dataCCM    = [[DataCCM alloc] init];
    NSMutableData* cipherText = ([[NSMutableData alloc] init]);
    NSMutableData* tag  = ([[NSMutableData alloc] init]);
    unsigned char* outbuf = NULL;
    
    // create and initialise the cipher context
    EVP_CIPHER_CTX* cipherCtx = NULL;
    cipherCtx = EVP_CIPHER_CTX_new();
    if(!cipherCtx) {
        FAIL(@"EVP_CIPHER_CTX_new");
    }
    EVP_CIPHER_CTX_init(cipherCtx);

    
    // set cipher type and mode
    if(EVP_EncryptInit_ex(cipherCtx, self.parameters.evpCipher, NULL, NULL, NULL) <= 0) {
        FAIL(@"EVP_EncryptInit_ex failed");
    }
    
    // create the buffer to hold the encrypted data,
    // add AES blocksize of 16 to allow for rounding
    int outlen=plainText.length+EVP_CIPHER_CTX_block_size(cipherCtx);
    
    // Since outbuf is used first to store the ciphertext, and later
    // to store the tag, allocate enough memory for the largest of the two
    outbuf = malloc(MAX(outlen, self.parameters.AESTagLength));
    if(!outbuf) {
        FAIL(@"malloc");
    }
    
    // set nonce length
    if (EVP_CIPHER_CTX_ctrl(cipherCtx, EVP_CTRL_CCM_SET_IVLEN, nonce.length, NULL) <=0) {
        FAIL(@"EVP_CIPHER_CTX_ctrl[EVP_CTRL_CCM_SET_IVLEN] failed");
    };
    
    // set tag length
    if (EVP_CIPHER_CTX_ctrl(cipherCtx, EVP_CTRL_CCM_SET_TAG, self.parameters.AESTagLength, NULL) <= 0) {
        FAIL(@"EVP_CIPHER_CTX_ctr[EVP_CTRL_CCM_SET_TAG] failed");
    };
    
    // initialise key and nonce
    if (EVP_EncryptInit_ex(cipherCtx, NULL, NULL, key.bytes, nonce.bytes) <= 0) {
        FAIL(@"EVP_CIPHER_CTX_ctrl[EVP_CTRL_CCM_SET_TAG] failed");
    };

    if (self.parameters.useAssociatedData) {
        // set plaintext length
        if (EVP_EncryptUpdate(cipherCtx, NULL, &outlen, NULL, plainText.length) <= 0) {
            FAIL(@"EVP_EncryptUpdate failed");
        };
    
        // add adata
        if (EVP_EncryptUpdate(cipherCtx, NULL, &outlen,
                              self.associatedData.bytes, self.associatedData.length) <= 0) {
            FAIL(@"EVP_EncryptUpdate failed");
        };
        LOG(@"adata                 : %@", [self.associatedData toHexString]);
    }
    
    // encrypt plaintext (can only be called once!)
    if (EVP_EncryptUpdate(cipherCtx, outbuf, &outlen, plainText.bytes, plainText.length) <= 0) {
        FAIL(@"EVP_EncryptUpdate failed");
    };
    
    // create output
    [cipherText appendBytes:outbuf length:outlen];
    LOG(@"encrypted text        : %@", [cipherText toHexString]);
    
    // finalise the encryption process
    if (EVP_EncryptFinal_ex(cipherCtx, outbuf, &outlen) <=0) {
        FAIL(@"EVP_EncryptFinal_ex failed");
    };
    
    // get the authentication tag
    if (EVP_CIPHER_CTX_ctrl(cipherCtx, EVP_CTRL_CCM_GET_TAG,
                            self.parameters.AESTagLength, outbuf) <=0) {
        FAIL(@"EVP_CIPHER_CTX_ctrl failed");    }
    [tag appendBytes:outbuf length:self.parameters.AESTagLength];
    LOG(@"tag                   : %@", [tag toHexString]);
    
    // populate the result
    dataCCM.tag        = tag;
    dataCCM.key        = key;
    dataCCM.nonce      = nonce;
    dataCCM.cipherText = cipherText;
    
cleanup:
    if(cipherCtx) {
        EVP_CIPHER_CTX_free(cipherCtx);
    }
    
    if(outbuf) {
        free(outbuf);
    }
    
    if(dataCCM && dataCCM.cipherText && dataCCM.tag) {
        return dataCCM;
    } else {
        return nil;
    }
    
#undef FAIL
}

- (NSData*)rsaEncrypt:(NSData*)plainText error:(NSError**)error {
    
#define FAIL(X) [OpenSSLUtil setOpenSSLError:error cause:X]; goto cleanup
    
    RSA* rsa = NULL;
    EVP_PKEY* pkey = NULL;
    EVP_PKEY_CTX* pkeyCtx = NULL;
    unsigned char* cipherText = NULL;
    size_t cipherTextLength = 0;
    
    rsa = RSA_new();
    if(!rsa) {
        FAIL(@"RSA_new");
    }
    
    rsa->n = [self.publicKeyModulus newBignum];
    rsa->e = [self.publicKeyExponent newBignum];
    
    pkey = EVP_PKEY_new();
    if(!pkey) {
        FAIL(@"EVP_PKEY_new");
    }
    
    if(EVP_PKEY_set1_RSA(pkey, rsa) <= 0) {
        FAIL(@"EVP_PKEY_set1_RSA");
    }
    
    pkeyCtx = EVP_PKEY_CTX_new(pkey, NULL);
    if(!pkeyCtx) {
        FAIL(@"EVP_PKEY_CTX_new");
    }
    
    if(EVP_PKEY_encrypt_init(pkeyCtx) <= 0) {
        FAIL(@"EVP_PKEY_encrypt_init");
    }
    
    if(EVP_PKEY_CTX_set_rsa_padding(pkeyCtx, RSA_PKCS1_PADDING) <= 0) {
        FAIL(@"EVP_PKEY_CTX_set_rsa_padding");
    }
    
    if(EVP_PKEY_encrypt(pkeyCtx, NULL, &cipherTextLength,
                        plainText.bytes, plainText.length) <= 0) {
        FAIL(@"EVP_PKEY_encrypt");
    }
    
    cipherText = malloc(cipherTextLength);
    if(EVP_PKEY_encrypt(pkeyCtx, cipherText, &cipherTextLength,
                        plainText.bytes, plainText.length) <= 0) {
        free(cipherText);
        cipherText = NULL;
        FAIL(@"EVP_PKEY_encrypt");
    }
    
cleanup:
    if(pkeyCtx) {
        EVP_PKEY_CTX_free(pkeyCtx);
    }
    if(pkey) {
        EVP_PKEY_free(pkey);
    }
    if(rsa) {
        RSA_free(rsa);
    }
    
    if(cipherText) {
        return [NSData dataWithBytesNoCopy:cipherText length:cipherTextLength];
    } else {
        return nil;
    }
    
#undef FAIL
}

@end
