//
//  SignInViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/28/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.logInView setBackgroundColor:[UIColor darkGrayColor]];
    [self.logInView.dismissButton setHidden:YES];
    [self.logInView.usernameField setBackgroundColor:[UIColor blackColor]];
    [self.logInView.usernameField setBorderStyle:UITextBorderStyleBezel];
    [self.logInView.passwordField setBackgroundColor:[UIColor blackColor]];
    [self.logInView.passwordField setBorderStyle:UITextBorderStyleBezel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
