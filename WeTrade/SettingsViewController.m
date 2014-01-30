//
//  SettingsViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    }
    if (indexPath.row == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"SignOutCell" forIndexPath:indexPath];
    }
    if (indexPath.row == 1) {
        return [tableView dequeueReusableCellWithIdentifier:@"ManageCell" forIndexPath:indexPath];
    }
    return [tableView dequeueReusableCellWithIdentifier:@"EmptyCell" forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 65;
    }
    return 50;
    //UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //return cell.bounds.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LogoutNotification object:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
