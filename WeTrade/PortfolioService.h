//
//  PortfolioService.h
//  WeTrade
//
//  Created by Jason Wells on 2/22/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PortfolioService : NSObject

@property (nonatomic, strong) NSArray *positions;

+ (PortfolioService *)instance;
- (NSNumber *)totalValueForQuotes:(NSDictionary *)quotes;
- (NSNumber *)totalChangeForQuotes:(NSDictionary *)quotes;
- (NSNumber *)totalChangeForQuotes:(NSDictionary *)quotes positions:(NSArray *)positions;
- (NSNumber *)dayChangeForQuotes:(NSDictionary *)quotes;
- (NSNumber *)dayChangeForQuotes:(NSDictionary *)quotes positions:(NSArray *)positions;
- (UIColor *)colorForChange:(float)change;
- (void)synchronize;

@end
