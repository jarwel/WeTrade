//
//  PortfolioService.h
//  WeTrade
//
//  Created by Jason Wells on 2/22/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PortfolioService : NSObject

@property (strong, nonatomic) NSArray *positions;

+ (PortfolioService *)instance;
+ (NSSet *)symbolsForPositions:(NSArray *)positions;
+ (NSSet *)sectorsForPositions:(NSArray *)positions;
+ (NSNumber *)totalValueForQuotes:(NSDictionary *)quotes positions:(NSArray *)positions;;
+ (NSNumber *)totalChangeForQuotes:(NSDictionary *)quotes positions:(NSArray *)positions;
+ (NSNumber *)dayChangeForQuotes:(NSDictionary *)quotes positions:(NSArray *)positions;
+ (UIColor *)colorForChange:(float)change;
+ (void)positionsForUserId:(NSString *)userId callback:(void (^)(NSArray *positions))callback;
- (void)markCashSymbol:(NSString *)symbol;
- (void)unmarkCashSymbol:(NSString *)symbol;
- (void)addLots:(NSArray *)lots fromSource:(NSString *)source;

@end
