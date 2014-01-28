//
//  FinanceClient.h
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FinanceClient : NSObject

+ (FinanceClient *)instance;
- (void)fetchQuotesForSymbols:(NSString* )symbols callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback;

@end
