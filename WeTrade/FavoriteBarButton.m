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
@property (strong, nonatomic) Security *security;

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
    _security = nil;
    _isFavorite = [[FavoriteService instance] isFavorite:user.objectId];
    [self updateTintColor];
}

- (void)setupForSecurity:(Security *)security {
    _user = nil;
    _security = security;
    _isFavorite = [[FavoriteService instance] isFavorite:security.objectId];
    [self updateTintColor];
}

- (IBAction)didTouchButton:(id)sender {
    if (self.user) {
        self.isFavorite ? [[FavoriteService instance] unfollowUser:self.user] : [[FavoriteService instance] followUser:self.user];
    }
    if (self.security) {
        self.isFavorite ? [[FavoriteService instance] unfollowSecurity:self.security] : [[FavoriteService instance] followSecurity:self.security];
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
