//
//  EditLotsViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "EditLotsViewController.h"
#import "ParseClient.h"
#import "LotCell.h"
#import "Lot.h"

@interface EditLotsViewController ()

@property (nonatomic, strong) NSArray *lots;

- (IBAction)onDoneButton:(id)sender;

@end

@implementation EditLotsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *lotCell = [UINib nibWithNibName:@"LotCell" bundle:nil];
    [self.tableView registerNib:lotCell forCellReuseIdentifier:@"LotCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [[ParseClient instance] fetchLots:^(NSArray *objects, NSError *error) {
        if (!error) {
            _lots = [Lot fromObjects:objects];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _lots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LotCell";
    LotCell *lotCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Lot *lot = [self.lots objectAtIndex:indexPath.row];
    lotCell.symbolLabel.text = lot.symbol;
    lotCell.priceLabel.text = [NSString stringWithFormat:@"%0.2f", lot.price];
    lotCell.sharesLabel.text = [NSString stringWithFormat:@"%d", lot.shares];
    lotCell.costBasisLabel.text = [NSString stringWithFormat:@"%0.2f", lot.costBasis];
    
    return lotCell;
}

- (IBAction)onDoneButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
