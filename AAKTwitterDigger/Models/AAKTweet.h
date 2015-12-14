//
//  AAKTweet.h
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAKTweet : NSObject

@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *userIdString;
@property (nonatomic, strong) NSString *text;

+ (NSArray *)twitAndUserAfterProcessingObject:(NSDictionary *)obj;

@end
