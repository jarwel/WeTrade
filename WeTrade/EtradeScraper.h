//
//  EtradeScraper.h
//  WeTrade
//
//  Created by Jason Wells on 3/1/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "WebScraper.h"

@interface EtradeScraper : WebScraper

+ (EtradeScraper *)instance;
- (NSMutableArray* )parseWebView:(UIWebView *)webView;

@end
