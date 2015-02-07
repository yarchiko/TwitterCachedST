//
//  UPKTwit.m
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 02.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import "UPKTwit.h"
#import "UPKUser.h"

@implementation UPKTwit

+ (NSArray *)twitAndUserAfterProcessingObject:(NSDictionary *)obj {
    NSString *idString = [obj objectForKey:@"id_str"];
    NSString *text= [obj objectForKey:@"text"];
    NSString *dateString = [obj objectForKey:@"created_at"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale localeWithLocaleIdentifier:@"en"]];
    //Wed Dec 01 17:08:03 +0000 2010
    [df setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    NSDate *date = [df dateFromString:dateString];
    [df setDateFormat:@"dd.MM.yyyy HH:mm"];
    dateString = [df stringFromDate:date];
    
    NSDictionary *user = [obj objectForKey:@"user"];
    NSString *userIdString = [user objectForKey:@"id_str"];
    NSString *userScreenName = [user objectForKey:@"screen_name"];
    NSString *userProfileImgUrl = [user objectForKey:@"profile_image_url"];
    if (idString && userIdString) {
        UPKTwit *twit = [self new];
        twit.idString = idString;
        twit.text = text;
        twit.userIdString = userIdString;
        twit.dateString = dateString;
        UPKUser *user = [UPKUser new];
        user.idString = userIdString;
        user.screenName = userScreenName;
        user.profileImgUrl = userProfileImgUrl;
        if (twit && user) {
            return @[twit, user];
        }
    }
    return nil;
}

@end
