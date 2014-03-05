//
//  FollowButton.h
//  WeTrade
//
//  Created by Jason Wells on 2/11/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Security.h"

@interface FollowButton : UIButton

- (void)setupForUser:(PFUser *)user;
- (void)setupForSecurity:(Security *)security;

@end
