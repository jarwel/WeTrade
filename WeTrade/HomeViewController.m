//
//  HomeViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "HomeViewController.h"
#import "ParseClient.h"
#import "FinanceClient.h"
#import "PositionCell.h"
#import "Position.h"
#import "Quote.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *positionsTableView;
@property (nonatomic, strong) NSArray *positions;
@property (nonatomic, strong) NSMutableDictionary *quotes;

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
    Quote *quote = [_quotes valueForKey:position.symbol];
    
    positionCell.symbolLabel.text = position.symbol;
    positionCell.priceLabel.text = [NSString stringWithFormat:@"%0.2f", quote.price];
    
    if (quote) {
        positionCell.percentChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", quote.percentChange];
        positionCell.percentChangeLabel.textColor = [self getChangeColor:quote.percentChange];
        
        float currentValue = position.shares * quote.price;
        float percentChangeTotal = (currentValue - position.costBasis) / position.costBasis * 100;
        positionCell.percentChangeTotalLabel.text = [NSString stringWithFormat:@"%+0.2f%%", percentChangeTotal];
        positionCell.percentChangeTotalLabel.textColor = [self getChangeColor:percentChangeTotal];
    }
    
    return positionCell;
}

- (void) reload {
    [[FinanceClient instance] fetchQuoteForSymbols:@"F,BA,FB,YHOO,GM" callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            _quotes = [[NSMutableDictionary alloc] init];
            
            // Hack to deal with Google Finance API weirdness
            NSString *content =[NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
            NSRange range1 = [content rangeOfString:@"["];
            NSRange range2 = [content rangeOfString:@"]"];
            NSRange range3;
            range3.location = range1.location+1;
            range3.length = (range2.location - range1.location)-1;
            NSString *contentFixed = [NSString stringWithFormat:@"[%@]", [content substringWithRange:range3]];
            NSData *jsonData = [contentFixed dataUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            for(NSDictionary *data in array) {
                Quote *quote = [[Quote alloc] initWithData:data];
                [_quotes setObject:quote forKey:quote.symbol];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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
