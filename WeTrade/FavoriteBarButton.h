//
//  FavoriteBarButton.h
//  WeTrade
//
//  Created by Jason Wells on 2/21/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FavoriteBarButton : UIBarButtonItem

- (void)setupForUser:(PFUser *)user;

@end