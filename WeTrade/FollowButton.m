//
//  FollowButton.m
//  WeTrade
//
//  Created by Jason Wells on 2/11/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FollowButton.h"
#import "Following.h"

@interface FollowButton ()

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) BOOL isFollowing;
- (void)didTouchButton;

@end

@implementation FollowButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"follow_selected.png"] forState:UIControlStateSelected];
    [self addTarget:self action:@selector(didTouchButton) forControlEvents:UIControlEventTouchDown];
}

- (void)initForUser:(PFUser *)user {
    if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        [self setEnabled:NO];
        [self setHidden:YES];
    }
    _user = user;
    _isFollowing = [[Following instance] contains:user.objectId];
    [self setSelected:self.isFollowing];
}

- (void)didTouchButton {
    self.isFollowing ? [[Following instance] unfollowUser:self.user] : [[Following instance] followUser:self.user];
    _isFollowing = !self.isFollowing;
    [self setSelected:self.isFollowing];
}

@end
