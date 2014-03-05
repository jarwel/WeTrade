//
//  ImportViewController.m
//  WeTrade
//
//  Created by Jason Wells on 2/27/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "ImportViewController.h"
#import "EditLotsViewController.h"
#import "Scraper.h"
#import "ParseClient.h"
#import "Lot.h"
#import "FidelityScraper.h"
#import "EtradeScraper.h"

@interface ImportViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) Scraper *scraper;
@property (nonatomic, strong) NSMutableArray *lots;

- (IBAction)onCancelButton:(id)sender;

@end

@implementation ImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scraper = [FidelityScraper instance];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.scraper.url]];
}

- (IBAction)onCancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EditLotsSegue"]) {
        NSMutableArray *lots = [self.scraper scrapeWebView:self.webView];
        
        UINavigationController *navigationViewController = segue.destinationViewController;
        navigationViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        EditLotsViewController *editLotsViewController = [[navigationViewController viewControllers] lastObject];
        editLotsViewController.source = self.scraper.source;
        editLotsViewController.lots  = lots;
        [editLotsViewController setTitle:@"Confirm Lots"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
