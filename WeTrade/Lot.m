//[
//  Lot.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Lot.h"

@implementation Lot

- (NSString *)symbol {
    return [self.data objectForKey:@"symbol"];
}

- (float)price {
    return [[self.data objectForKey:@"price"] floatValue];
}

- (int)shares {
    return [[self.data objectForKey:@"shares"] intValue];
}

- (float)costBasis {
    return [[self.data objectForKey:@"costBasis"] floatValue];
}

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects {
    NSMutableArray *lots = [[NSMutableArray alloc] initWithCapacity:objects.count];
    for (PFObject *object in objects) {
        [lots addObject:[[Lot alloc] initWithObject:object]];
    }
    return lots;
}

@end
