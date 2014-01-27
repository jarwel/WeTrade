//
//  ParseObject.h
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ParseObject : NSObject

@property (nonatomic, strong) PFObject *data;

- (id)initWithObject:(PFObject *)data;

@end
