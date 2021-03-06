//
//  EditLotsViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "EditLotsViewController.h"
#import "PortfolioService.h"
#import "ParseClient.h"
#import "LotCell.h"
#import "Lot.h"

@interface EditLotsViewController ()

- (IBAction)onImportButton:(id)sender;
- (IBAction)onDoneButton:(id)sender;
- (IBAction)onCashButton:(UIButton *)sender;

@end

@implementation EditLotsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *lotCell = [UINib nibWithNibName:@"LotCell" bundle:nil];
    [self.tableView registerNib:lotCell forCellReuseIdentifier:@"LotCell"];
    
    if (self.lots.count == 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    
    if (!self.lots) {
        [[ParseClient instance] fetchLots:^(NSArray *lots) {
            _lots = [lots sortedArrayUsingComparator:^NSComparisonResult(id first, id second) {
                NSString *firstSymbol = ((Lot*)first).symbol;
                NSString *secondSymbol= ((Lot*)second).symbol;
                return [firstSymbol compare:secondSymbol];
            }];
            [self.tableView reloadData];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _lots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LotCell";
    LotCell *lotCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Lot *lot = [self.lots objectAtIndex:indexPath.row];
    lotCell.symbolLabel.text = lot.symbol;
    lotCell.sharesLabel.text = [NSString stringWithFormat:@"%0.2f", lot.shares];
    lotCell.costBasisLabel.text = [NSString stringWithFormat:@"%0.2f", lot.costBasis];
    
    lotCell.cashButton.tag = indexPath.row;
    [lotCell.cashButton setSelected:[lot.cash boolValue]];
    [lotCell.cashButton setHidden:!lot.mightBeCash];
    [lotCell.cashButton addTarget:self action:@selector(onCashButton:) forControlEvents:UIControlEventTouchUpInside];
    [lotCell.cashButton  setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
 
    return lotCell;
}

- (IBAction)onCashButton:(UIButton *)sender {
    Lot *lot = [self.lots objectAtIndex:sender.tag];
    
    if (sender.selected) {
        lot.cash = @"NO";
        [[PortfolioService instance] unmarkCashSymbol:lot.symbol];
    }
    else {
        lot.cash = @"YES";
        [[PortfolioService instance] markCashSymbol:lot.symbol];
    }

    [self.tableView reloadData];
}

- (IBAction)onImportButton:(id)sender {
    [[PortfolioService instance] addLots:self.lots fromSource:self.source];
    self.navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDoneButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
