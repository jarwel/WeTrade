//
//  AccountViewController.m
//  WeTrade
//
//  Created by Jason Wells on 3/12/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "AccountViewController.h"
#import "ImportViewController.h"
#import "FidelityScraper.h"
#import "EtradeScraper.h"
#import "VanguardScraper.h"

@interface AccountViewController ()

@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *webScrapers;

- (IBAction)onCancelButton:(id)sender;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webScrapers = [[NSMutableArray alloc] init];
    [self.webScrapers addObject:[FidelityScraper instance]];
    [self.webScrapers addObject:[EtradeScraper instance]];
    [self.webScrapers addObject:[VanguardScraper instance]];
    
    _images = [[NSMutableArray alloc] init];
    for (WebScraper *webScraper in self.webScrapers) {
        UIImage *image = [self sizeImage:webScraper.image];
        [self.images addObject:image];
    }
}

- (UIImage *)sizeImage:(UIImage *)image {
    CGSize size = CGSizeMake(self.tableView.frame.size.width, self.tableView.rowHeight);
    CGFloat width = (size.height - 20) / image.size.height * image.size.width;
    CGFloat height = size.height - 20;
    CGFloat x = (size.width - width) / 2;
    CGFloat y = (size.height - height) / 2;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(x, y, width, height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImage *image = [self.images objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor colorWithPatternImage:image];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ImportAccountSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ImportAccountSegue"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        ImportViewController *importViewController = segue.destinationViewController;
        importViewController.webScraper = [self.webScrapers objectAtIndex:indexPath.row];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)onCancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
