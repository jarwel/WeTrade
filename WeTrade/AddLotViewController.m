//
//  AddLotViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "AddLotViewController.h"
#import "Constants.h"
#import "ParseClient.h"

@interface AddLotViewController ()

@property (weak, nonatomic) IBOutlet UITextField *symbolTextField;
@property (weak, nonatomic) IBOutlet UITextField *sharesTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;

- (IBAction)onSubmitButton:(id)sender;
- (IBAction)onCancelButton:(id)sender;
- (IBAction)onTap:(id)sender;

@end

@implementation AddLotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor darkGrayColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (IBAction)onSubmitButton:(id)sender {
    NSString *symbol = [_symbolTextField.text uppercaseString];
    float price = [_priceTextField.text floatValue];
    int shares = [_sharesTextField.text intValue];
    float costBasis = price * shares;
    
    if (symbol && price > 0 && shares > 0) {
        [[ParseClient instance] addLotWithSymbol:symbol price:price shares:shares costBasis:costBasis];
        [[NSNotificationCenter defaultCenter] postNotificationName:LotsChangedNotification object:nil];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
