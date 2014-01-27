//
//  Position.h
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Position : NSObject

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects;

@property (nonatomic, strong) NSMutableArray *lots;
@property (nonatomic, strong, readonly) NSString *symbol;
@property (nonatomic, strong, readonly) NSNumber *shares;
@property (nonatomic, strong, readonly) NSNumber *costBasis;

@end
