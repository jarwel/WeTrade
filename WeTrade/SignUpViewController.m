//
//  SignUpViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/28/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.signUpView setBackgroundColor:[UIColor darkGrayColor]];
    [self.signUpView.usernameField setBackgroundColor:[UIColor blackColor]];
    [self.signUpView.usernameField setBorderStyle:UITextBorderStyleBezel];
    [self.signUpView.passwordField setBackgroundColor:[UIColor blackColor]];
    [self.signUpView.passwordField setBorderStyle:UITextBorderStyleBezel];
    [self.signUpView.emailField setBackgroundColor:[UIColor blackColor]];
    [self.signUpView.emailField setBorderStyle:UITextBorderStyleBezel];
}

- (void)viewWillAppear:(BOOL)animated {
    self.signUpView.usernameField.text = nil;
    self.signUpView.passwordField.text = nil;
    self.signUpView.emailField.text = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
