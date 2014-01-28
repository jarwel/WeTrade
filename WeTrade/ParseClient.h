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
- (void)fetchLotsForUser:(NSString *)user callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)createLotWithSymbol:(NSString *)symbol price:(float) price shares:(int)shares costBasis:(float)costBasis;

@end
