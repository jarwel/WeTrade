//
//  HistoricalQuote.m
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "HistoricalQuote.h"

@implementation HistoricalQuote

- (NSString *)symbol {
    return [self objectForKey:@"Symbol"];
}

- (NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter dateFromString:[self objectForKey:@"Date"]];
}

- (float)close {
    return [[self objectForKey:@"Close"] floatValue];
}

@end
