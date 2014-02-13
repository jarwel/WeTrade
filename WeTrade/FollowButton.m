//
//  FollowButton.m
//  WeTrade
//
//  Created by Jason Wells on 2/11/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FollowButton.h"
#import "ParseClient.h"

@interface FollowButton ()

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) BOOL following;

@end

@implementation FollowButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setTitle:@"FO" forState:UIControlStateNormal];
    [self setTitle:@"UF" forState:UIControlStateSelected];
    [self addTarget:self action:@selector(didTouchButton) forControlEvents:UIControlEventTouchDown];
}

- (void)initForUser:(PFUser *)user following:(BOOL)following {
    if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        [self setEnabled:NO];
        [self setHidden:YES];
    }
    _user = user;
    _following = following;
    [self setSelected:self.following];
}

- (void)didTouchButton {
    self.following ? [[ParseClient instance] unfollowUser:self.user] : [[ParseClient instance] followUser:self.user];
    _following = !self.following;
    [self setSelected:self.following];
}

@end
