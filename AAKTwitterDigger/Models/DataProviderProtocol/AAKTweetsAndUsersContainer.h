//
//  AAKTwitsAndUsersContainer.h
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAKTweetsAndUsersContainer : NSObject

@property (nonatomic, strong, readonly) NSDictionary *users;
@property (nonatomic, strong, readonly) NSArray *twits;

- (instancetype)containerMergedWithContainer:(AAKTweetsAndUsersContainer *)container;
- (instancetype)containerMergedWithContainer:(AAKTweetsAndUsersContainer *)container keepJustOneUserWithIdString:(NSString *)userIdString;
- (instancetype)initWithRemoteObjectsArray:(NSArray *)objects;
- (instancetype)initWithObjectsArray:(NSArray *)objects;
- (instancetype)copy;

@end
