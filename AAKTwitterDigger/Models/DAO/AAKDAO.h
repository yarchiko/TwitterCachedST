//
//  AAKDAO.h
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AAKTweetAsyncProvider.h"

extern NSString* const AAKDataFromDB;

@protocol AAKFinishedLoadingUrlProtocol <NSObject>

- (void)finishedLoadingUrlString:(NSString *)urlString withData:(NSData *)data andNotification:(NSString *)notification;

@end

@interface AAKDAO : NSObject <AAKTweetAsyncProvider, AAKFinishedLoadingUrlProtocol>

+ (instancetype)sharedDAO;

- (NSString *)dbPath;
- (BOOL)dbCreateAndCheck;

@end
