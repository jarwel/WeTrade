//
//  RestObject.h
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestObject : NSObject

@property (nonatomic, strong) NSDictionary *data;
- (id)initWithData:(NSDictionary *)data;

@end
