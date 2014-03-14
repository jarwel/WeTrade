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

- (IBAction)onCancelButton:(id)sender;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _images = [[NSMutableArray alloc] initWithCapacity:3];
    CGSize size = CGSizeMake(self.tableView.frame.size.width, self.tableView.rowHeight);
    [self.images addObject:[self processImage:[UIImage imageNamed:@"fidelity.jpeg"] forSize:size]];
    [self.images addObject:[self processImage:[UIImage imageNamed:@"etrade.jpeg"] forSize:size]];
    [self.images addObject:[self processImage:[UIImage imageNamed:@"vanguard.jpeg"] forSize:size]];
}

- (UIImage *)processImage:(UIImage *)image forSize:(CGSize)size {
    float width = size.height / image.size.height * image.size.width;
    float height = size.height;
    float x = (size.width - width) / 2;
    float y = (size.height - height) / 2;
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
        switch (indexPath.row) {
            case 0 :
                importViewController.webScraper = [[FidelityScraper alloc] init];
                break;
            case 1 :
                importViewController.webScraper = [[EtradeScraper alloc] init];
                break;
            case 2 :
                importViewController.webScraper = [[VanguardScraper alloc] init];
                break;
        }
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
