//
//  Comment.h
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseObject.h"

@interface Comment : ParseObject

@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSDate *postDate;

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects;

@end
