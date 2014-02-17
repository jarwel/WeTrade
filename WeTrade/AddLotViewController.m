//
//  AddLotViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "AddLotViewController.h"
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
}

- (IBAction)onSubmitButton:(id)sender {
    NSString *symbol = [_symbolTextField.text uppercaseString];
    float price = [_priceTextField.text floatValue];
    int shares = [_sharesTextField.text intValue];
    float costBasis = price * shares;
    
    [[ParseClient instance] addLotWithSymbol:symbol price:price shares:shares costBasis:costBasis];
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
