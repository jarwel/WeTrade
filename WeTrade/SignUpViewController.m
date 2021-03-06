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
    
    [self.signUpView setLogo:logo];
    [self.signUpView.usernameField setBackgroundColor:[UIColor darkGrayColor]];
    [self.signUpView.usernameField setBorderStyle:UITextBorderStyleBezel];
    [self.signUpView.passwordField setBackgroundColor:[UIColor darkGrayColor]];
    [self.signUpView.passwordField setBorderStyle:UITextBorderStyleBezel];
    [self.signUpView.emailField setBackgroundColor:[UIColor darkGrayColor]];
    [self.signUpView.emailField setBorderStyle:UITextBorderStyleBezel];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setBackgroundColor:[UIColor blueColor]];
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
