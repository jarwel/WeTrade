//
//  FollowingViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/30/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FollowingViewController.h"
#import "FollowUser.h"
#import "FollowUserCell.h"

@interface FollowingViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *following;
- (IBAction)onTap:(id)sender;

@end

@implementation FollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *lotCell = [UINib nibWithNibName:@"UserFavorite" bundle:nil];
    [self.tableView registerNib:lotCell forCellReuseIdentifier:@"UserFavorite"];
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
    
    return followUserCell;

}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
