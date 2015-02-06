//
//  UPKTwitCell.h
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 06.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPKTwitCell : UITableViewCell

- (void)prepareViewWithUserScreenName:(NSString *)screenName andText:(NSString *)text andImgData:(NSData *)imgData;

@end
