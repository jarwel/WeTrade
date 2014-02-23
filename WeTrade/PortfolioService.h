//
//  PortfolioService.h
//  WeTrade
//
//  Created by Jason Wells on 2/22/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PortfolioService : NSObject

+ (NSNumber *)getTotalChangeForPositions:(NSArray *)positions quotes:(NSDictionary *)quotes;
+ (UIColor *)getColorForChange:(float)change;

@end
