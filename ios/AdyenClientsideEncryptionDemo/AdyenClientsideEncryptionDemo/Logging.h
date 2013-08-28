//
//  Logging.h
//  AdyenClientsideEncryption
//
//  Created by Jeroen Koops on 8/21/13.
//  Copyright (c) 2013 Adyen. All rights reserved.
//

#ifndef AdyenClientsideEncryption_Logging_h
#define AdyenClientsideEncryption_Logging_h

// Change to 0 in production code
#define ENABLE_LOG 1

#if ENABLE_LOG
#    define LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#    define LOG(fmt, ...)
#endif

#endif
