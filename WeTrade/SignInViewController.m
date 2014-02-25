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

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor darkGrayColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    NSString *title = @"WeTrade";
    UIFont *font = [UIFont systemFontOfSize:29];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:font}];
    CGRect frame = CGRectMake(5, 85, size.width, size.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = font;
    label.text = title;
    label.textColor = [UIColor lightGrayColor];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    [logo addSubview:label];

    [self.logInView setLogo:logo];
    [self.logInView.dismissButton setHidden:YES];
    [self.logInView.usernameField setBackgroundColor:[UIColor darkGrayColor]];
    [self.logInView.usernameField setBorderStyle:UITextBorderStyleBezel];
    [self.logInView.passwordField setBackgroundColor:[UIColor darkGrayColor]];
    [self.logInView.passwordField setBorderStyle:UITextBorderStyleBezel];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.logInButton setBackgroundColor:[UIColor darkGrayColor]];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setBackgroundColor:[UIColor blueColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    self.logInView.usernameField.text = nil;
    self.logInView.passwordField.text = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
