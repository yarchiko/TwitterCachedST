//
//  AAKTweet.m
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import "AAKTweet.h"
#import "AAKUser.h"

@implementation AAKTweet

+ (NSArray *)twitAndUserAfterProcessingObject:(NSDictionary *)obj
{
    NSString *idString = [obj objectForKey:@"id_str"];
    NSString *text= [obj objectForKey:@"text"];

    NSDictionary *user = [obj objectForKey:@"user"];
    NSString *userIdString = [user objectForKey:@"id_str"];
    NSString *userScreenName = [user objectForKey:@"screen_name"];
    NSString *userProfileImgUrl = [user objectForKey:@"profile_image_url"];
    if (idString && userIdString) {
        AAKTweet *tweet = [self new];
        tweet.idString = idString;
        tweet.text = text;
        tweet.userIdString = userIdString;
        AAKUser *user = [AAKUser new];
        user.idString = userIdString;
        user.screenName = userScreenName;
        user.profileImgUrl = userProfileImgUrl;
        if (tweet && user) {
            return @[tweet, user];
        }
    }
    return nil;
}

@end
