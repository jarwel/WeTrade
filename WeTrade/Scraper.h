//
//  Scraper.h
//  WeTrade
//
//  Created by Jason Wells on 3/1/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lot.h"

@interface Scraper : NSObject

@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSURL *url;

- (NSMutableArray* )scrapeWebView:(UIWebView *)webView;
- (NSString *)extractStringFrom:(NSString *)from withPattern:(NSString *)pattern;
- (NSNumber *)extractDecimalFrom:(NSString *)from withPattern:(NSString *)pattern;
- (NSNumber *)extractCurrencyFrom:(NSString *)from withPattern:(NSString *)pattern;

@end
