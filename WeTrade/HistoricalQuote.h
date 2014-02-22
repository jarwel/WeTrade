//
//  HistoricalQuote.h
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestObject.h"

@interface HistoricalQuote : RestObject

@property (nonatomic, strong, readonly) NSString *symbol;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, assign, readonly) float close;

@end
