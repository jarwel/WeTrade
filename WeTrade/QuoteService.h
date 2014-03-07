//
//  QuoteService.h
//  WeTrade
//
//  Created by Jason Wells on 3/6/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Quote.h"

@interface QuoteService : NSObject

+ (QuoteService *)instance;
- (Quote *)quoteForSymbol:(NSString *)symbol;
- (NSDictionary *)quotesForSymbols:(NSSet *)symbols;

@end
