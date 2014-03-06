//
//  FavoriteButton.m
//  WeTrade
//
//  Created by Jason Wells on 2/11/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FavoriteButton.h"
#import "FavoriteService.h"

@interface FavoriteButton ()

@property (assign, nonatomic, assign) BOOL isFavorite;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) Security *security;

- (IBAction)didTouchButton:(id)sender;

@end

@implementation FavoriteButton

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
    _isFavorite = [[FavoriteService instance] isFavorite:user.objectId];
    _user = user;
    _security = nil;
    [self setSelected:self.isFavorite];
}

- (void)setupForSecurity:(Security *)security {
    _isFavorite = [[FavoriteService instance] isFavorite:security.objectId];
    _user = nil;
    _security = security;
    [self setSelected:self.isFavorite];
}

- (IBAction)didTouchButton:(id)sender {
    if (self.user) {
        self.isFavorite ? [[FavoriteService instance] unfollowUser:self.user] : [[FavoriteService instance] followUser:self.user];
    }
    if (self.security) {
        self.isFavorite ? [[FavoriteService instance] unfollowSecurity:self.security] : [[FavoriteService instance] followSecurity:self.security];
    }
    
    _isFavorite = !self.isFavorite;
    [self setSelected:self.isFavorite];
}

@end
