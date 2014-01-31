//
//  FollowingViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/30/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FollowingViewController.h"
#import "ParseClient.h"
#import "FollowUser.h"
#import "FollowUserCell.h"

@interface FollowingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *following;

- (IBAction)onEditingChanged:(id)sender;
- (IBAction)onTap:(id)sender;

@end

@implementation FollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *lotCell = [UINib nibWithNibName:@"FollowUserCell" bundle:nil];
    [self.tableView registerNib:lotCell forCellReuseIdentifier:@"FollowUserCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.following.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FollowUserCell";
    FollowUserCell *followUserCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    FollowUser *followUser = [self.following objectAtIndex:indexPath.row];
    followUserCell.usernameLabel.text = followUser.username;
    return followUserCell;

}

- (IBAction)onEditingChanged:(id)sender {
    NSString *search = self.searchTextField.text;
    if (search.length > 2) {
        [[ParseClient instance] fetchUsersForSearch:search callback:^(NSArray *objects, NSError *error) {
            if (!error) {
                if ([search isEqualToString:self.searchTextField.text]) {
                    _following = [FollowUser fromPFObjectArray:objects];
                    [self.tableView reloadData];
                }
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    else {
        _following = nil;
        [self.tableView reloadData];
    }
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
