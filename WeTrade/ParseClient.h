//
//  ParseClient.h
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ParseClient : NSObject

+ (ParseClient *)instance;
- (void)fetchLots:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchLotsForUserId:(NSString *)userId callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchUserForUserId:(NSString *)userId callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchUsersForSearch:(NSString *)search callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)addLotWithSymbol:(NSString *)symbol price:(float) price shares:(int)shares costBasis:(float)costBasis;
- (void)followUserId:(NSString *)userId;

@end
