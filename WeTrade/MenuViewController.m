//
//  MenuViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "MenuViewController.h"
#import "EditLotsViewController.h"
#import "Constants.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *user = [PFUser currentUser];
    self.usernameLabel.text = user.username;
    self.emailLabel.text = user.email;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0 :
            return [tableView dequeueReusableCellWithIdentifier:@"ImportCell" forIndexPath:indexPath];
        case 1 :
            return [tableView dequeueReusableCellWithIdentifier:@"ManageLotsCell" forIndexPath:indexPath];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EditLotsSegue"]) {
        UINavigationController *navigationViewController = segue.destinationViewController;
        EditLotsViewController *editLotsViewController = [[navigationViewController viewControllers] lastObject];
        editLotsViewController.navigationItem.leftBarButtonItem.title = @"Done";
        editLotsViewController.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
