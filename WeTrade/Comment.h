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

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *text;

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects;

@end
