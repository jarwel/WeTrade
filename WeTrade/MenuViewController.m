//
//  MenuViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "MenuViewController.h"
#import "Constants.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *user = [PFUser currentUser];
    self.usernameLabel.text = user.username;
    self.emailLabel.text = user.email;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0 :
            return [tableView dequeueReusableCellWithIdentifier:@"BuySharesCell" forIndexPath:indexPath];
        case 1 :
            return [tableView dequeueReusableCellWithIdentifier:@"SellSharesCell" forIndexPath:indexPath];
        case 2 :
            return [tableView dequeueReusableCellWithIdentifier:@"SignOutCell" forIndexPath:indexPath];
    }
    return [tableView dequeueReusableCellWithIdentifier:@"EmptyCell" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LogoutNotification object:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
