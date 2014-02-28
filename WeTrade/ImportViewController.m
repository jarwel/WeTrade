//
//  ImportViewController.m
//  WeTrade
//
//  Created by Jason Wells on 2/27/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "ImportViewController.h"
#import "ParseClient.h"
#import "Lot.h"

@interface ImportViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)onImportButton:(id)sender;
- (IBAction)onCancelButton:(id)sender;

@end

@implementation ImportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://fidelity.com"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)onImportButton:(id)sender {
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
        
        Lot *lot = [[Lot alloc] init];
        lot.symbol = symbol;
        lot.shares = [shares floatValue];
        lot.costBasis = [costBasis floatValue];
        [lots addObject:lot];
        
        NSLog(@"Symbol: %@ Shares: %0.3f Cost Basis: %0.3f", lot.symbol, lot.shares, lot.costBasis);
    }
     [[ParseClient instance] updateLots:lots fromSource:@"fidelity"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
