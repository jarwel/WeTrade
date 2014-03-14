//
//  FidelityScraper.m
//  WeTrade
//
//  Created by Jason Wells on 3/1/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FidelityScraper.h"
#import "Lot.h"

@implementation FidelityScraper

+ (FidelityScraper *)instance {
    static FidelityScraper *instance;
    if (!instance) {
        instance = [[FidelityScraper alloc] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.source = @"fidelity";
        self.url = [NSURL URLWithString:@"https://oltx.fidelity.com/ftgw/fbc/ofpositions/portfolioPositions"];
        self.image = [UIImage imageNamed:@"fidelity.jpeg"];
    }
    return self;
}

- (NSMutableArray* )parseWebView:(UIWebView *)webView {
    NSMutableArray *lots = [[NSMutableArray alloc] init];
    
    NSString *string = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('positionsTable').outerHTML"];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSRegularExpression *rowsRegex = [NSRegularExpression regularExpressionWithPattern:@"<tr class=\"[A-Za-z ]*\" style=\"\">.*?</tr>" options:0 error:nil];
    NSArray *rows = [rowsRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    for (NSTextCheckingResult *rowMatch in rows) {
        NSString *row = [string substringWithRange:rowMatch.range];
        
        NSString *symbol = [super extractStringFrom:row withPattern:@"<strong>.*?</strong>"];
        NSNumber *shares = [super extractDecimalFrom:row withPattern:@"<td class=\"right\" nowrap=\"nowrap\">.*?</td>"];
        NSNumber *costBasis = [super extractCurrencyFrom:row withPattern:@"<td nowrap=\"nowrap\"><span class=\"right-float right.*?</span><span class=\"layout-clear-both\"></span></td>"];
        
        [lots addObject:[[Lot alloc] initWithSymbol:symbol shares:[shares floatValue] costBasis:[costBasis floatValue]]];
        NSLog(@"Symbol: %@ Shares: %0.3f Cost Basis: %0.3f", symbol, [shares floatValue], [costBasis floatValue]);
    }
    return lots;
}

@end
