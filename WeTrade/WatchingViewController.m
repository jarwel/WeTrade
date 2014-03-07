//
//  WatchingViewController.m
//  WeTrade
//
//  Created by Jason Wells on 3/4/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "WatchingViewController.h"
#import "SecurityViewController.h"
#import "Constants.h"
#import "QuoteService.h"
#import "PortfolioService.h"
#import "FavoriteService.h"
#import "ParseClient.h"
#import "FinanceClient.h"
#import "Quote.h"
#import "Security.h"
#import "SecurityCell.h"

@interface WatchingViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

@property (strong, nonatomic) NSMutableArray *watching;
@property (strong, nonatomic) NSArray *searchResults;

- (IBAction)onReorderButton:(id)sender;
- (IBAction)onDoneButton:(id)sender;

- (void)refreshViews;

@end

@implementation WatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *searchField = [self.searchDisplayController.searchBar valueForKey:@"_searchField"];
    [searchField setTextColor:[UIColor blackColor]];
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.searchDisplayController.navigationItem.title = @"Watch List";
    self.searchDisplayController.navigationItem.rightBarButtonItem = self.doneBarButton;
    self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
    self.searchDisplayController.searchResultsTableView.separatorColor = self.tableView.separatorColor;
    self.searchDisplayController.searchResultsTableView.separatorInset =  self.tableView.separatorInset;
    self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;

    UINib *securityCell = [UINib nibWithNibName:@"SecurityCell" bundle:nil];
    [self.tableView registerNib:securityCell forCellReuseIdentifier:@"SecurityCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:securityCell forCellReuseIdentifier:@"SecurityCell"];
    
    [self refreshViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:QuotesUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:FavoritesChangedNotification object:nil];
}

- (void)refreshViews {
    NSLog(@"refreshing WatchingViewContoller");
    
    _watching = [[[FavoriteService instance] favoriteSecurities] mutableCopy];
    [self.tableView reloadData];
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
                                NSDictionary *quotes = [Quote mapFromData:data];
                                
                                Quote *searchQuote = [quotes objectForKey:searchSymbol];
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
    Quote *quote = [[QuoteService instance] quoteForSymbol:security.symbol];
    
    cell.symbolLabel.text = security.symbol;
    cell.nameLabel.text = quote.name;
    cell.priceLabel.text = [NSString stringWithFormat:@"%0.2f", quote.price];
    cell.changeLabel.text= [NSString stringWithFormat:@"%+0.2f (%+0.2f%%)", quote.priceChange, quote.percentChange];
    cell.changeLabel.textColor = [PortfolioService colorForChange:quote.percentChange];
    [cell.favoriteButton setupForSecurity:security];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSString *item = [self.watching objectAtIndex:fromIndexPath.row];
    [self.watching removeObjectAtIndex:fromIndexPath.row];
    [self.watching insertObject:item atIndex:toIndexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowSecuritySegue" sender:self];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchDisplayController.navigationItem.rightBarButtonItem setTitle:@"Cancel"];
}

- (IBAction)onReorderButton:(id)sender {
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    [sender setSelected:self.tableView.isEditing];
    [self.doneBarButton setEnabled:!self.tableView.isEditing];
}

- (IBAction)onDoneButton:(id)sender {
    if (self.searchDisplayController.isActive) {
        [self.searchDisplayController setActive:NO];
        [self.doneBarButton setTitle:@"Done"];
    }
    else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowSecuritySegue"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        
        Security *security;
        if (self.searchDisplayController.isActive) {
            security = [self.searchResults objectAtIndex:indexPath.row];
        }
        else {
            security = [self.watching objectAtIndex:indexPath.row];
        }
        
        SecurityViewController *securityViewController = segue.destinationViewController;
        securityViewController.symbol = security.symbol;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
