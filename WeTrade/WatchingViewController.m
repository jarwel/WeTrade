//
//  WatchingViewController.m
//  WeTrade
//
//  Created by Jason Wells on 3/4/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "WatchingViewController.h"
#import "Constants.h"
#import "FollowingService.h"
#import "ParseClient.h"
#import "FinanceClient.h"
#import "Quote.h"
#import "Security.h"
#import "SecurityCell.h"

@interface WatchingViewController ()

@property (strong, nonatomic) NSArray *watching;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSDictionary *quotes;

- (IBAction)onDoneButton:(id)sender;

- (void)refreshViews;

@end

@implementation WatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *securityCell = [UINib nibWithNibName:@"SecurityCell" bundle:nil];
    [self.tableView registerNib:securityCell forCellReuseIdentifier:@"SecurityCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:securityCell forCellReuseIdentifier:@"SecurityCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:FollowingChangedNotification object:nil];
    [self refreshViews];
}

- (void)refreshViews {
    _watching = [[FollowingService instance] watching];
    [[FinanceClient instance] fetchQuotesForSecurities:self.watching callback:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error) {
                NSDictionary *quotes = [Quote fromData:data];
                if (quotes.count > 0) {
                    _quotes = [Quote fromData:data];
                }
                [self.tableView reloadData];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length > 0) {
        NSString *searchSymbol = [searchText uppercaseString];
        [[ParseClient instance] fetchSecuritiesForSearch:searchSymbol callback:^(NSArray *objects, NSError *error) {
            if (!error) {
                if ([searchText isEqualToString:searchBar.text]) {
                    NSArray *securities = [Security fromParseObjects:objects];
                    BOOL isSecurityForSearch = NO;
 
                    NSMutableSet *symbols = [[NSMutableSet alloc] init];
                    for (Security *security in securities) {
                        if ([security.symbol isEqualToString:searchSymbol]) {
                            isSecurityForSearch = YES;
                        }
                        [symbols addObject:security.symbol];
                    }
                    [symbols addObject:searchSymbol];

                    [[FinanceClient instance] fetchQuotesForSymbols:symbols callback:^(NSURLResponse *response, NSData *data, NSError *error) {
                        if (!error) {
                            if ([searchText isEqualToString:searchBar.text]) {
                                _quotes = [Quote fromData:data];
                                
                                Quote *searchQuote = [self.quotes objectForKey:searchSymbol];
                                if (!isSecurityForSearch && searchQuote && searchQuote.isValid) {
                                    NSMutableArray *securitiesWithSearchText = [securities mutableCopy];
                                    [securitiesWithSearchText insertObject:[[Security alloc] initWithSymbol:searchSymbol] atIndex:0];
                                    _searchResults = securitiesWithSearchText;
                                }
                                else {
                                    _searchResults = securities;
                                }
                               [self.searchDisplayController.searchResultsTableView reloadData];
                            }
                        }
                        else {
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                }
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"count: %ld", self.searchResults.count);
        return self.searchResults.count;
    }
    return self.watching.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SecurityCell";
    SecurityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Security *security;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        security = [self.searchResults objectAtIndex:indexPath.row];
    }
    else {
        security = [self.watching objectAtIndex:indexPath.row];
    }
    Quote *quote = [self.quotes valueForKey:security.symbol];
    
    cell.symbolLabel.text = security.symbol;
    cell.companyLabel.text = quote.name;
    [cell.followButton setupForSecurity:security];
    
    return cell;
}

- (IBAction)onDoneButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
