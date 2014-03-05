//
//  WatchingViewController.m
//  WeTrade
//
//  Created by Jason Wells on 3/4/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "WatchingViewController.h"
#import "StockViewController.h"
#import "Constants.h"
#import "PortfolioService.h"
#import "FollowingService.h"
#import "ParseClient.h"
#import "FinanceClient.h"
#import "Quote.h"
#import "Security.h"
#import "SecurityCell.h"

@interface WatchingViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

@property (strong, nonatomic) NSArray *watching;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSDictionary *quotes;

- (IBAction)onDoneButton:(id)sender;

- (void)refreshViews;

@end

@implementation WatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor lightGrayColor]];
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.searchDisplayController.navigationItem.rightBarButtonItem = self.doneBarButton;

    UINib *securityCell = [UINib nibWithNibName:@"SecurityCell" bundle:nil];
    [self.tableView registerNib:securityCell forCellReuseIdentifier:@"SecurityCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:securityCell forCellReuseIdentifier:@"SecurityCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:FollowingChangedNotification object:nil];
    [self refreshViews];
}

- (void)refreshViews {
    _watching = [[FollowingService instance] watching];
    [self loadQuotes];
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
    cell.nameLabel.text = quote.name;
    cell.priceLabel.text = [NSString stringWithFormat:@"%0.2f", quote.price];
    cell.changeLabel.text= [NSString stringWithFormat:@"%+0.2f (%+0.2f%%)", quote.priceChange, quote.percentChange];
    cell.changeLabel.textColor = [PortfolioService colorForChange:quote.percentChange];
    [cell.followButton setupForSecurity:security];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowStockSegue" sender:self];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.doneBarButton.title = @"Cancel";
}

- (void)loadQuotes {
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

- (IBAction)onDoneButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowStockSegue"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        Security *security = [self.watching objectAtIndex:indexPath.row];
        StockViewController *stockViewController = segue.destinationViewController;
        stockViewController.symbol = security.symbol;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end