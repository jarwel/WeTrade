//
//  ImportViewController.m
//  WeTrade
//
//  Created by Jason Wells on 2/27/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "ImportViewController.h"
#import "EditLotsViewController.h"
#import "ParseClient.h"
#import "Lot.h"

@interface ImportViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSMutableArray *lots;

- (IBAction)onCancelButton:(id)sender;

@end

@implementation ImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _url = [NSURL URLWithString:@"https://oltx.fidelity.com/ftgw/fbc/ofpositions/portfolioPositions"];
    //_url = [NSURL URLWithString:@"https:www.etrade.com"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (NSMutableArray* )extractLots {
    NSMutableArray *lots = [[NSMutableArray alloc] init];
    NSString *string = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('positionsTable').outerHTML"];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSRegularExpression *positionRegex = [NSRegularExpression regularExpressionWithPattern:@"<tr class=\"\" style=\"\">.*?</tr>" options:0 error:nil];
    NSArray *positions = [positionRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    for (NSTextCheckingResult *positionMatch in positions) {
        NSString *position = [string substringWithRange:positionMatch.range];
        
        NSString *symbol = [self extractStringFrom:position withPattern:@"<strong>.*?</strong>"];
        NSNumber *shares = [self extractNumberFrom:position withPattern:@"<td class=\"right\" nowrap=\"nowrap\">.*?</td>" withStyle:NSNumberFormatterDecimalStyle];
        NSNumber *costBasis = [self extractNumberFrom:position withPattern:@"<td nowrap=\"nowrap\"><span class=\"right-float right.*?</span><span class=\"layout-clear-both\"></span></td>" withStyle:NSNumberFormatterCurrencyStyle];
        
        Lot *lot = [[Lot alloc] initWithSymbol:symbol shares:[shares floatValue] costBasis:[costBasis floatValue]];
        [lots addObject:lot];
        
        NSLog(@"Symbol: %@ Shares: %0.3f Cost Basis: %0.3f", lot.symbol, lot.shares, lot.costBasis);
    }
    return lots;
}

- (IBAction)onCancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSNumber *)extractNumberFrom:(NSString *)from withPattern:(NSString *)pattern withStyle:(NSNumberFormatterStyle)style {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:style];
    NSString *string = [self extractStringFrom:from withPattern:pattern];
    return [formatter numberFromString:[string stringByReplacingOccurrencesOfString:@"t" withString:@""]];
}

- (NSString *)extractStringFrom:(NSString *)from withPattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:from options:0 range:NSMakeRange(0, [from length])];
    NSString *value = [from substringWithRange:match.range];
    return [self stripHTML:value];
}

- (NSString *)stripHTML:(NSString *)string {
    NSRange range;
    while ((range = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        string = [string stringByReplacingCharactersInRange:range withString:@""];
    return string;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EditLotsSegue"]) {
        UINavigationController *navigationViewController = segue.destinationViewController;
        navigationViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        EditLotsViewController *editLotsViewController = [[navigationViewController viewControllers] lastObject];
        editLotsViewController.source = @"fidelity";
        editLotsViewController.lots  = [self extractLots];
        [editLotsViewController setTitle:@"Confirm Lots"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
