//
//  Metrics.h
//  WeTrade
//
//  Created by Jason Wells on 3/2/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Metrics : NSObject

@property (nonatomic, strong, readonly) NSString *symbol;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) float price;
@property (nonatomic, assign, readonly) float priceChange;
@property (nonatomic, assign, readonly) float percentChange;
@property (nonatomic, assign, readonly) float open;
@property (nonatomic, assign, readonly) float previousClose;
@property (nonatomic, assign, readonly) float low;
@property (nonatomic, assign, readonly) float high;
@property (nonatomic, assign, readonly) float oneYearTarget;
@property (nonatomic, assign, readonly) float volume;
@property (nonatomic, strong, readonly) NSString *marketCapitalization;
@property (nonatomic, strong, readonly) NSString *ebitda;
@property (nonatomic, assign, readonly) float pricePerEarnings;
@property (nonatomic, assign, readonly) float earningsPerShare;
@property (nonatomic, assign, readonly) float dividend;
@property (nonatomic, assign, readonly) float yield;
@property (nonatomic, strong, readonly) NSString *exDividendDate;
@property (nonatomic, strong, readonly) NSString *dividendDate;
@property (nonatomic, strong, readonly) NSString *volumeText;

+ (Metrics *)fromData:(NSData *)data;

@end
