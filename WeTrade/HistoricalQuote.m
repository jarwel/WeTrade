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
    return [self.data objectForKey:@"Symbol"];
}

- (float)close {
    return [[self.data objectForKey:@"Close"] floatValue];
}

@end
