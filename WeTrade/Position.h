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
#import "Lot.h"

@interface Position : NSObject

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, strong) NSString *sector;
@property (nonatomic, assign) int shares;
@property (nonatomic, assign) float costBasis;

- (void)addLot:(Lot *)lot;
- (float)valueForQuote:(Quote *)quote;
+ (NSMutableArray *)fromObjects:(NSArray *)objects;

@end
