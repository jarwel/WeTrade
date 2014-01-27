//
//  Lot.h
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseObject.h"

@interface Lot : ParseObject

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects;

@property (nonatomic, strong, readonly) NSString *symbol;
@property (nonatomic, strong, readonly) NSNumber *shares;
@property (nonatomic, strong, readonly) NSNumber *price;
@property (nonatomic, strong, readonly) NSNumber *costBasis;
@property (nonatomic, strong, readonly) NSDate *purchased;

@end
