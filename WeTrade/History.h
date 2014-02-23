//
//  History.h
//  WeTrade
//
//  Created by Jason Wells on 2/11/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface History : NSObject

@property (nonatomic, strong) NSArray *quotes;
@property (nonatomic, assign) float lowPrice;
@property (nonatomic, assign) float highPrice;

@property (nonatomic, assign, readonly) NSDate *startDate;
@property (nonatomic, assign, readonly) NSDate *endDate;
@property (nonatomic, assign, readonly) float startPrice;
@property (nonatomic, assign, readonly) float endPrice;

+ (History *)fromData:(NSData *)data;

@end
