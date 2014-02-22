//
//  FollowingViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/30/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FollowingViewController.h"
#import "HomeViewController.h"
#import "Constants.h"
#import "ParseClient.h"
#import "Following.h"
#import "UserCell.h"

@interface FollowingViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *search;
@property (nonatomic, assign) BOOL searchMode;

- (void)refreshViews;
- (NSArray *)current;

@end

@implementation FollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *userCell = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [self.tableView registerNib:userCell forCellReuseIdentifier:@"UserCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:FollowingChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.current.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    UserCell *userCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.current objectAtIndex:indexPath.row];
    userCell.tag = indexPath.row;
    userCell.usernameLabel.text = user.username;
    
    [userCell.followButton initForUser:user];
    return userCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowPortfolio" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowPortfolio"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        PFUser *user = [self.current objectAtIndex:indexPath.row];
        
        UINavigationController *navigationViewController = segue.destinationViewController;
        navigationViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        HomeViewController *homeViewController = [[navigationViewController viewControllers] lastObject];
        homeViewController.forUser = user;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchMode = YES;
    if (searchText.length > 0) {
        [[ParseClient instance] fetchUsersForSearch:searchText callback:^(NSArray *objects, NSError *error) {
            if (!error) {
                if ([searchText isEqualToString:searchText]) {
                    _search = objects;
                    [self.tableView reloadData];
                }
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    else {
        _search = nil;
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchMode = NO;
    searchBar.text = nil;
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.view endEditing:YES];
    [self.tableView reloadData];
}

- (void)refreshViews {
    [self.tableView reloadData];
}

- (NSArray *)current {
    if (self.searchMode) {
        return self.search;
    }
    return [[Following instance] asArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
