//
//  HomeViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "HomeViewController.h"
#import "ParseClient.h"
#import "PositionCell.h"
#import "Position.h"


@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *positionsTableView;
@property (nonatomic, strong) NSArray *positions;


- (UIColor *)getChangeColor:(float)change;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *lotCell = [UINib nibWithNibName:@"PositionCell" bundle:nil];
    [self.positionsTableView registerNib:lotCell forCellReuseIdentifier:@"PositionCell"];
    self.positionsTableView.delegate = self;
    self.positionsTableView.dataSource = self;
    
    [self reload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _positions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PositionCell";
    PositionCell *positionCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Position *position = [self.positions objectAtIndex:indexPath.row];
    positionCell.symbolLabel.text = position.symbol;
    
    positionCell.priceLabel.text = [NSString stringWithFormat:@"%0.2f", 100.00];
    
    float percentChange = -3.47;
    positionCell.percentChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", percentChange];
    positionCell.percentChangeLabel.textColor = [self getChangeColor:percentChange];
    
    float percentChangeTotal = +10.15;
    positionCell.percentChangeTotalLabel.text = [NSString stringWithFormat:@"%+0.2f%%", percentChangeTotal];
    positionCell.percentChangeTotalLabel.textColor = [self getChangeColor:percentChangeTotal];
    
    return positionCell;
}

- (void) reload {
    [[ParseClient instance] fetchLotsForUser:@"" callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            _positions = [Position fromPFObjectArray:objects];
            [self.positionsTableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (UIColor *)getChangeColor:(float)change {
    if (change > 0) {
        return [UIColor greenColor];
    }
    if (change < 0) {
        return [UIColor redColor];
    }
    return [UIColor blueColor];
}

@end
