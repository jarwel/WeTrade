//
//  WebScraper.m
//  WeTrade
//
//  Created by Jason Wells on 3/1/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "WebScraper.h"

@implementation WebScraper

- (NSMutableArray* )parseWebView:(UIWebView *)webView {
    [NSException raise:@"Method not implemented" format:@"extractFromWebView is not implemented for Scraper"];
    return nil;
}

- (NSString *)extractStringFrom:(NSString *)from withPattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:from options:0 range:NSMakeRange(0, [from length])];
    NSString *value = [from substringWithRange:match.range];
    return [self stripHTML:value];
}

- (NSNumber *)extractDecimalFrom:(NSString *)from withPattern:(NSString *)pattern {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *string = [self extractStringFrom:from withPattern:pattern];
    return [formatter numberFromString:[string stringByReplacingOccurrencesOfString:@"t" withString:@""]];
}

- (NSNumber *)extractCurrencyFrom:(NSString *)from withPattern:(NSString *)pattern {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *string = [self extractStringFrom:from withPattern:pattern];
    return [formatter numberFromString:[string stringByReplacingOccurrencesOfString:@"t" withString:@""]];
}

- (NSString *)stripHTML:(NSString *)string {
    NSRange range;
    while ((range = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        string = [string stringByReplacingCharactersInRange:range withString:@""];
    return string;
}

@end
