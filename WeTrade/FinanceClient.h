//
//  FinanceClient.h
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"

@interface FinanceClient : NSObject

+ (FinanceClient *)instance;
- (void)fetchQuotesForPositions:(NSArray *)position callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback;
- (void)fetchFullQuoteForSymbol:(NSString *)symbol callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback;
- (void)fetchHistoryForSymbol:(NSString *)string startDate:(NSDate *)startDate endDate:(NSDate *)endDate callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback;

@end
