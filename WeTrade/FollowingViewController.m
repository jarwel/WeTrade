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
#import "FinanceClient.h"
#import "FollowingService.h"
#import "PortfolioService.h"
#import "UserCell.h"
#import "Position.h"
#import "Quote.h"

@interface FollowingViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *percentChanges;
@property (nonatomic, strong) NSArray *search;
@property (nonatomic, assign) BOOL searchMode;

- (NSArray *)current;
- (void)refreshViews;
- (void)loadChangeForUser:(PFUser *)user indexPath:(NSIndexPath *)indexPath;

@end

@implementation FollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    [searchField setTextColor:[UIColor whiteColor]];

    _percentChanges = [[NSMutableDictionary alloc] init];
    [[FollowingService instance] loadFromServer];
    UINib *userCell = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [self.tableView registerNib:userCell forCellReuseIdentifier:@"UserCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:FollowingChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
    
    NSNumber *percentChange = [self.percentChanges objectForKey:user.objectId];
    if (percentChange) {
        userCell.totalChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", [percentChange floatValue]];
        userCell.totalChangeLabel.textColor = [PortfolioService getColorForChange:[percentChange floatValue]];
    }
    else {
        [self loadChangeForUser:user indexPath:indexPath];
    }
    
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
    return [[FollowingService instance] asArray];
}

- (void)loadChangeForUser:(PFUser *)user indexPath:(NSIndexPath *)indexPath {
    [[ParseClient instance] fetchLotsForUserId:user.objectId callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *positions = [Position fromObjects:objects];
            NSMutableArray *symbols = [[NSMutableArray alloc] init];
            for (Position *position in positions) {
                [symbols addObject:position.symbol];
            }
            [[FinanceClient instance] fetchQuotesForSymbols:symbols callback:^(NSURLResponse *response, NSData *data, NSError *error) {
                if (!error) {
                    NSDictionary *quotes = [Quote fromData:data];
        
                    NSNumber *percentChange = [PortfolioService getTotalChangeForPositions:positions quotes:quotes];
                    if (percentChange) {
                        [self.percentChanges setObject:percentChange forKey:user.objectId];
                        UserCell *userCell = (UserCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                        if (userCell) {
                            userCell.totalChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", [percentChange floatValue]];
                            userCell.totalChangeLabel.textColor = [PortfolioService getColorForChange:[percentChange floatValue]];
                        }
                    }
                } else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
