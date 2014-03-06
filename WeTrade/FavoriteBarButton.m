//
//  FavoriteBarButton.m
//  WeTrade
//
//  Created by Jason Wells on 2/21/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FavoriteBarButton.h"
#import "FavoriteService.h"

@interface FavoriteBarButton ()

@property (assign, nonatomic) BOOL isFavorite;
@property (strong, nonatomic) PFUser *user;

- (IBAction)didTouchButton:(id)sender;

@end

@implementation FavoriteBarButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setImage:[UIImage imageNamed:@"follow.png"]];
    [self setTarget:self];
    [self setAction:@selector(didTouchButton:)];
}

- (void)setupForUser:(PFUser *)user {
    _user = user;
    _isFavorite = [[FavoriteService instance] isFavorite:user.objectId];
    [self updateTintColor];
}

- (IBAction)didTouchButton:(id)sender {
    if (self.isFavorite) {
        [[FavoriteService instance] unfollowUser:self.user];
    }
    else {
        [[FavoriteService instance] followUser:self.user];
    }
    _isFavorite = !self.isFavorite;
    [self updateTintColor];
}

- (void)updateTintColor {
    if (self.isFavorite) {
        [self setTintColor:[UIColor colorWithRed:0.25 green:0.6 blue:1.0 alpha:1.0]];
    }
    else {
        [self setTintColor:[UIColor lightGrayColor]];
    }
}

@end
