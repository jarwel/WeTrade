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

@property (strong, nonatomic) NSMutableArray *lots;

- (IBAction)onCancelButton:(id)sender;

@end

@implementation ImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.webScraper.url]];
}

- (IBAction)onCancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EditLotsSegue"]) {
        NSMutableArray *lots = [self.webScraper parseWebView:self.webView];
        
        UINavigationController *navigationViewController = segue.destinationViewController;
        navigationViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        EditLotsViewController *editLotsViewController = [[navigationViewController viewControllers] lastObject];
        editLotsViewController.source = self.webScraper.source;
        editLotsViewController.lots  = lots;
        [editLotsViewController setTitle:@"Confirm Lots"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
