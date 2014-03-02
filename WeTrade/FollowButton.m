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

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) BOOL isFollowing;
- (IBAction)didTouchButton:(id)sender;

@end

@implementation FollowButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"follow_selected.png"] forState:UIControlStateSelected];
    [self addTarget:self action:@selector(didTouchButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUser:(PFUser *)user {
    if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        [self setEnabled:NO];
        [self setHidden:YES];
    }
    _user = user;
    _isFollowing = [[FollowingService instance] contains:user.objectId];
    [self setSelected:self.isFollowing];
}

- (IBAction)didTouchButton:(id)sender {
    if (self.isFollowing) {
        [[FollowingService instance] unfollowUser:self.user];
    } else {
        [[FollowingService instance] followUser:self.user];
    }
    _isFollowing = !self.isFollowing;
    [self setSelected:self.isFollowing];
}

@end
