//
//  WebScraper.h
//  WeTrade
//
//  Created by Jason Wells on 3/1/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebScraper : NSObject

@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) UIImage *image;

- (NSMutableArray* )parseWebView:(UIWebView *)webView;
- (NSString *)extractStringFrom:(NSString *)from withPattern:(NSString *)pattern;
- (NSNumber *)extractDecimalFrom:(NSString *)from withPattern:(NSString *)pattern;
- (NSNumber *)extractCurrencyFrom:(NSString *)from withPattern:(NSString *)pattern;

@end
