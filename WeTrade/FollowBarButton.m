//
//  FollowBarButton.m
//  WeTrade
//
//  Created by Jason Wells on 2/21/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FollowBarButton.h"
#import "FollowingService.h"

@interface FollowBarButton ()

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) BOOL isFollowing;
- (IBAction)didTouchButton:(id)sender;

@end

@implementation FollowBarButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setImage:[UIImage imageNamed:@"follow.png"]];
    [self setTarget:self];
    [self setAction:@selector(didTouchButton:)];
}

- (void)setUser:(PFUser *)user {
    _user = user;
    _isFollowing = [[FollowingService instance] contains:user.objectId];
    [self updateTintColor];
}

- (IBAction)didTouchButton:(id)sender {
    if (self.isFollowing) {
        [[FollowingService instance] unfollowUser:self.user];
    }
    else {
        [[FollowingService instance] followUser:self.user];
    }
    _isFollowing = !self.isFollowing;
    [self updateTintColor];
}

- (void)updateTintColor {
    if (_isFollowing) {
        [self setTintColor:[UIColor colorWithRed:0.25 green:0.6 blue:1.0 alpha:1.0]];
    }
    else {
        [self setTintColor:[UIColor lightGrayColor]];
    }
}

@end
