//
//  Quotes.h
//  WeTrade
//
//  Created by Jason Wells on 1/27/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestObject.h"

@interface Quote : RestObject

@property (nonatomic, strong, readonly) NSString *symbol;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) float price;
@property (nonatomic, assign, readonly) float priceChange;
@property (nonatomic, assign, readonly) float percentChange;
@property (nonatomic, assign, readonly) float open;
@property (nonatomic, assign, readonly) float previousClose;
@property (nonatomic, assign, readonly) BOOL isValid;

@end
