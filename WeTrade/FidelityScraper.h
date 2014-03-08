//
//  FidelityScraper.h
//  WeTrade
//
//  Created by Jason Wells on 3/1/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebScraper.h"

@interface FidelityScraper : WebScraper

+ (FidelityScraper *)instance;
- (NSMutableArray* )parseWebView:(UIWebView *)webView;

@end
