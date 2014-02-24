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

    NSString *title = @"WeTrade";
    UIFont *font = [UIFont systemFontOfSize:36];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:font}];
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = font;
    label.text = title;
    label.textColor = [UIColor whiteColor];
    UIImageView *logo = [[UIImageView alloc] initWithFrame:label.frame];
    [logo addSubview:label];

    [self.logInView setLogo:logo];
    [self.logInView setBackgroundColor:[UIColor darkGrayColor]];
    [self.logInView.dismissButton setHidden:YES];
    [self.logInView.usernameField setBackgroundColor:[UIColor darkGrayColor]];
    [self.logInView.usernameField setBorderStyle:UITextBorderStyleBezel];
    [self.logInView.passwordField setBackgroundColor:[UIColor darkGrayColor]];
    [self.logInView.passwordField setBorderStyle:UITextBorderStyleBezel];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.logInButton setBackgroundColor:[UIColor blueColor]];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    self.logInView.usernameField.text = nil;
    self.logInView.passwordField.text = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
