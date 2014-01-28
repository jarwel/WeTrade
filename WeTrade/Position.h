//
//  Position.h
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Quote.h"

@interface Position : NSObject

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects;

@property (nonatomic, strong, readonly) NSString *symbol;
@property (nonatomic, assign, readonly) int shares;
@property (nonatomic, assign, readonly) float costBasis;
- (float)valueForQuote:(Quote *)quote;

@end
