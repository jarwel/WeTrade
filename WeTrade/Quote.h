//
//  Quotes.h
//  WeTrade
//
//  Created by Jason Wells on 1/27/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quote : NSObject

@property (nonatomic, strong, readonly) NSString *symbol;
@property (nonatomic, assign, readonly) float price;
@property (nonatomic, assign, readonly) float percentChange;

- (id)initWithData:(NSDictionary *)data;

@end
