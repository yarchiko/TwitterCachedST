//
//  AAKClient.h
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AAKTweetAsyncProvider.h"

extern NSString* const AAKRequestUrlString;

@interface AAKClient : NSObject <AAKTweetAsyncProvider>

+ (instancetype)sharedClient;

@end
