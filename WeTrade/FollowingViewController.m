//
//  FollowingViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/30/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FollowingViewController.h"
#import "PortfolioViewController.h"
#import "Constants.h"
#import "ParseClient.h"
#import "QuoteService.h"
#import "FavoriteService.h"
#import "PortfolioService.h"
#import "UserCell.h"
#import "Position.h"
#import "Quote.h"

@interface FollowingViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableDictionary *portfolios;
@property (strong, nonatomic) NSMutableSet *timers;
@property (strong, nonatomic) NSArray *search;
@property (assign, nonatomic) BOOL searchMode;

- (NSArray *)current;
- (void)fetchPortfolioForUser:(PFUser *)user indexPath:(NSIndexPath *)indexPath;
- (void)expireChangeForTimer:(NSTimer *)timer;
- (void)reloadQuotes;
- (void)reloadFavorites;

@end

@implementation FollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    [searchField setTextColor:[UIColor whiteColor]];
    
    UINib *userCell = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [self.tableView registerNib:userCell forCellReuseIdentifier:@"UserCell"];

    _portfolios = [[NSMutableDictionary alloc] init];
    _timers = [[NSMutableSet alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadQuotes) name:QuotesUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFavorites) name:FavoritesChangedNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QuotesUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PortfolioChangedNotification object:nil];
}

- (void)reloadQuotes {
    NSLog(@"FollowingViewController reloadQuotes");
    [self.tableView reloadData];
}

- (void)reloadFavorites {
    NSLog(@"FollowingViewController reloadFavorites");
    [self.tableView reloadData];
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
    [userCell.favoriteButton setupForUser:user];
    
    NSArray *positions = [self.portfolios objectForKey:user.objectId];
    if (positions) {
        NSSet *symbols = [PortfolioService symbolsForPositions:positions];
        NSDictionary *quotes = [[QuoteService instance] quotesForSymbols:symbols];
        NSNumber *percentChange = [PortfolioService dayChangeForQuotes:quotes positions:positions];
        
        userCell.totalChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", [percentChange floatValue]];
        userCell.totalChangeLabel.textColor = [PortfolioService colorForChange:[percentChange floatValue]];
    }
    else {
        userCell.totalChangeLabel.text = @"--";
        userCell.totalChangeLabel.textColor = [UIColor lightGrayColor];
        [self fetchPortfolioForUser:user indexPath:indexPath];
    }
    
    return userCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowPortfolioSegue" sender:self];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchMode = YES;
    if (searchText.length > 0) {
        [[ParseClient instance] fetchUsersForSearch:searchText callback:^(NSArray *objects, NSError *error) {
            if (!error) {
                if ([searchText isEqualToString:searchBar.text]) {
                    _search = objects;
                    [self.tableView setAlpha:1.0f];
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
    [self.tableView setAlpha:0.5f];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.tableView setAlpha:1.0f];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.view endEditing:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchMode = NO;
    searchBar.text = nil;
    [self.tableView setAlpha:1.0f];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.view endEditing:YES];
    [self.tableView reloadData];
}

- (NSArray *)current {
    if (self.searchMode) {
        return self.search;
    }
    return [[FavoriteService instance] favoriteUsers];
}

- (void)fetchPortfolioForUser:(PFUser *)user indexPath:(NSIndexPath *)indexPath {
    [[ParseClient instance] fetchLotsForUserId:user.objectId callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *positions = [Position fromObjects:objects];
            
            UserCell *userCell = (UserCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            if (userCell) {
                NSSet *symbols = [PortfolioService symbolsForPositions:positions];
                NSDictionary *quotes = [[QuoteService instance] quotesForSymbols:symbols];
                NSNumber *percentChange = [PortfolioService dayChangeForQuotes:quotes positions:positions];
                
                userCell.totalChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", [percentChange floatValue]];
                userCell.totalChangeLabel.textColor = [PortfolioService colorForChange:[percentChange floatValue]];
            }
            
            [self.portfolios setObject:positions forKey:user.objectId];
            
            if (![self.timers containsObject:user.objectId]) {
                [self.timers addObject:user.objectId];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:user.objectId, @"userId", nil];
                [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(expireChangeForTimer:) userInfo:userInfo repeats:NO];
            }
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)expireChangeForTimer:(NSTimer *)timer {
    NSString *userId = [[timer userInfo] objectForKey:@"userId"];
    [self.portfolios removeObjectForKey:userId];
    [self.timers removeObject:userId];
    NSLog(@"Expired change for userId: %@", userId);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowPortfolioSegue"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        PFUser *user = [self.current objectAtIndex:indexPath.row];
        
        UINavigationController *navigationViewController = segue.destinationViewController;
        navigationViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

        PortfolioViewController *portfolioViewController = [[navigationViewController viewControllers] lastObject];
        portfolioViewController.user = user;
        portfolioViewController.title = [NSString stringWithFormat:@"%@'s Portfolio", user.username];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
