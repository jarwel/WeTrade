//
//  HistoricalQuote.m
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "HistoricalQuote.h"

@implementation HistoricalQuote

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _symbol = [dictionary objectForKey:@"symbol"];
        _close = [[dictionary objectForKey:@"Close"] floatValue];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        _date = [formatter dateFromString:[dictionary objectForKey:@"Date"]];
    }
    return self;
}

@end
