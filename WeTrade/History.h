//
//  History.h
//  WeTrade
//
//  Created by Jason Wells on 2/11/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface History : NSObject

@property (nonatomic, strong) NSArray *quotes;
@property (nonatomic, assign) float priceLow;
@property (nonatomic, assign) float priceHigh;

+ (History *)fromJSONDictionary:(NSDictionary *)dictionary;

@end
