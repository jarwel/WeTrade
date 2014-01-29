//
//  UserFavorite.h
//  WeTrade
//
//  Created by Jason Wells on 1/28/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "ParseObject.h"

@interface UserFavorite : ParseObject

@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, assign, readonly) BOOL *favorite;

@end
