//
//  VanguardScraper.h
//  WeTrade
//
//  Created by Jason Wells on 3/13/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "WebScraper.h"

@interface VanguardScraper : WebScraper

+ (VanguardScraper *)instance;
- (NSMutableArray* )parseWebView:(UIWebView *)webView;

@end
