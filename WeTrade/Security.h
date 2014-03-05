//
//  Security.h
//  WeTrade
//
//  Created by Jason Wells on 3/4/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseObject.h"

@interface Security : ParseObject

@property (strong, nonatomic, readonly) NSString *objectId;
@property (strong, nonatomic) NSString *symbol;

- (id)initWithSymbol:(NSString *)symbol;
+ (NSMutableArray *)fromParseObjects:(NSArray *)parseObjects;

@end
