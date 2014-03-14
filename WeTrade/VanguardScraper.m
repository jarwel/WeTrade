//
//  VanguardScraper.m
//  WeTrade
//
//  Created by Jason Wells on 3/13/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "VanguardScraper.h"

@implementation VanguardScraper

+ (VanguardScraper *)instance {
    static VanguardScraper *instance;
    if (!instance) {
        instance = [[VanguardScraper alloc] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.source = @"vanguard";
        self.url = [NSURL URLWithString:@"https://investor.vanguard.com/my-portfolio"];
        self.image = [UIImage imageNamed:@"vanguard.jpeg"];
    }
    return self;
}

- (NSMutableArray* )parseWebView:(UIWebView *)webView {
    return [[NSMutableArray alloc] init];
}

@end
