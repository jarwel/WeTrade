//
//  EtradeScraper.m
//  WeTrade
//
//  Created by Jason Wells on 3/1/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "EtradeScraper.h"
#import "Lot.h"

@implementation EtradeScraper

+ (EtradeScraper *)instance {
    static EtradeScraper *instance;
    if (!instance) {
        instance = [[EtradeScraper alloc] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.source = @"etrade";
        self.url = [NSURL URLWithString:@"https://us.etrade.com/e/t/stockplan/olportfolioview?ploc=c-SubNav"];
        self.image = [UIImage imageNamed:@"etrade.jpeg"];
    }
    return self;
}

- (NSMutableArray* )parseWebView:(UIWebView *)webView {
    NSMutableArray *lots = [[NSMutableArray alloc] init];
    
    NSString *string = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('centerTable')[1].outerHTML"];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSRegularExpression *rowsRegex = [NSRegularExpression regularExpressionWithPattern:@"<tr class=\"(even|odd)\" key=\"\\d+\" rn=\"\\d+\">.*?</tr>" options:0 error:nil];
    NSArray *rows = [rowsRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    for (NSTextCheckingResult *rowMatch in rows) {
        NSString *row = [string substringWithRange:rowMatch.range];
        NSLog(@"%@", row);

        NSString *symbol = @"YHOO";
        NSNumber *price = [super extractCurrencyFrom:row withPattern:@"<td style=\"height: 28px;\" fldnm=\"plan_price\" cn=\"\\d+\" class=\"\">.*?</td>"];
        NSNumber *shares = [super extractDecimalFrom:row withPattern:@"<td style=\"height: 28px;\" fldnm=\"plan_sellable\" cn=\"\\d+\" class=\"\">.*?</td>"];
        float costBasis = (float)[price floatValue] * [shares floatValue];
        
        [lots addObject:[[Lot alloc] initWithSymbol:symbol shares:[shares floatValue] costBasis:costBasis source:self.source]];
        NSLog(@"Symbol: %@ Shares: %0.3f Price: %0.3f", symbol, [shares floatValue], [price floatValue]);
    }
    return lots;
}

@end
