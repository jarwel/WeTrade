//
//  FollowButton.m
//  WeTrade
//
//  Created by Jason Wells on 2/11/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FollowButton.h"
#import "FollowingService.h"

@interface FollowButton ()

@property (assign, nonatomic, assign) BOOL isFollowing;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) Security *security;

- (IBAction)didTouchButton:(id)sender;

@end

@implementation FollowButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"follow_selected.png"] forState:UIControlStateSelected];
    [self addTarget:self action:@selector(didTouchButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupForUser:(PFUser *)user {
    if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        [self setHidden:YES];
    }
    _isFollowing = [[FollowingService instance] isFollowingObjectId:user.objectId];
    _user = user;
    _security = nil;
    [self setSelected:self.isFollowing];
}

- (void)setupForSecurity:(Security *)security {
    _isFollowing = [[FollowingService instance] isFollowingObjectId:security.objectId];
    _user = nil;
    _security = security;
    [self setSelected:self.isFollowing];
}

- (IBAction)didTouchButton:(id)sender {
    if (self.user) {
        self.isFollowing ? [[FollowingService instance] unfollowUser:self.user] : [[FollowingService instance] followUser:self.user];
    }
    if (self.security) {
        self.isFollowing ? [[FollowingService instance] unfollowSecurity:self.security] : [[FollowingService instance] followSecurity:self.security];
    }
    
    _isFollowing = !self.isFollowing;
    [self setSelected:self.isFollowing];
}

@end
