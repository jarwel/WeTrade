//
//  FidelityScraper.m
//  WeTrade
//
//  Created by Jason Wells on 3/1/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FidelityScraper.h"

@implementation FidelityScraper

+ (FidelityScraper *)instance {
    static FidelityScraper *instance;
    if (!instance) {
        instance = [[FidelityScraper alloc] init];
    }
    return instance;
}

- (NSString *)source {
    return @"fidelity";
}

- (NSURL *)url {
    return [NSURL URLWithString:@"https://oltx.fidelity.com/ftgw/fbc/ofpositions/portfolioPositions"];
}

- (NSMutableArray* )scrapeWebView:(UIWebView *)webView {
    NSMutableArray *lots = [[NSMutableArray alloc] init];
    
    NSString *string = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('positionsTable').outerHTML"];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSRegularExpression *rowsRegex = [NSRegularExpression regularExpressionWithPattern:@"<tr class=\"\" style=\"\">.*?</tr>" options:0 error:nil];
    NSArray *rows = [rowsRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    for (NSTextCheckingResult *rowMatch in rows) {
        NSString *row = [string substringWithRange:rowMatch.range];
        
        NSString *symbol = [self extractStringFrom:row withPattern:@"<strong>.*?</strong>"];
        NSNumber *shares = [self extractDecimalFrom:row withPattern:@"<td class=\"right\" nowrap=\"nowrap\">.*?</td>"];
        NSNumber *costBasis = [self extractCurrencyFrom:row withPattern:@"<td nowrap=\"nowrap\"><span class=\"right-float right.*?</span><span class=\"layout-clear-both\"></span></td>"];
        
        [lots addObject:[[Lot alloc] initWithSymbol:symbol shares:[shares floatValue] costBasis:[costBasis floatValue]]];
        NSLog(@"Symbol: %@ Shares: %0.3f Cost Basis: %0.3f", symbol, [shares floatValue], [costBasis floatValue]);
    }
    return lots;
}


@end
