//
//  AAKSingleRequestCapsule.h
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const AAKSingleRequestCapsuleFinishedWorking;

@interface AAKSingleRequestCapsule : NSObject <NSURLConnectionDelegate> {
    NSMutableData *_responseData;
    NSURLConnection *_connection;
    NSError *_error;
    NSString *_notification;
}
@property (nonatomic, assign, readonly) BOOL finished;
@property (nonatomic, copy, readonly) NSString *notification;

- (instancetype)initWithUrlString:(NSString *)urlString timeoutInterval:(NSTimeInterval)timeoutInterval requestParams:(NSDictionary *)requestParams notifyOnResponse:(NSString *)notification;
- (void)cancel;
- (NSError *)error;
- (NSData *)responseData;
- (NSString *)urlString;

@end
