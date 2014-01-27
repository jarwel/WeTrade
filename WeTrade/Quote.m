//
//  Quotes.m
//  WeTrade
//
//  Created by Jason Wells on 1/27/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Quote.h"

@interface Quote ()

@property (nonatomic, strong) NSDictionary *data;

@end

@implementation Quote

- (id)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

- (NSString *)symbol {
    return [_data objectForKey:@"t"];
}

- (float)price {
    return [[_data objectForKey:@"l_fix"] floatValue];
}

- (float)percentChange {
    return [[_data objectForKey:@"cp_fix"] floatValue];
}

@end
