//
//  Lot.h
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseObject.h"

@interface Lot : ParseObject

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, assign) float shares;
@property (nonatomic, assign) float costBasis;
@property (nonatomic, assign) NSString *source;
@property (nonatomic, assign) NSString *cash;

- (id)initWithSymbol:(NSString *)symbol shares:(float)shares costBasis:(float)costBasis;
- (BOOL)mightBeCash;

@end
