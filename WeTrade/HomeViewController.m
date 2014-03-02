//
//  HomeViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "HomeViewController.h"
#import "StockViewController.h"
#import "Constants.h"
#import "ParseClient.h"
#import "FinanceClient.h"
#import "PortfolioService.h"
#import "FollowButton.h"
#import "FollowBarButton.h"
#import "PositionCell.h"
#import "Position.h"
#import "Quote.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet FollowBarButton *followBarButton;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (weak, nonatomic) IBOutlet UILabel *changeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;

@property (nonatomic, strong) NSArray *positions;
@property (nonatomic, strong) NSDictionary *quotes;
@property (nonatomic, strong) NSTimer *quoteTimer;
@property (nonatomic, assign) float totalValue;

- (IBAction)onChangeButton:(id)sender;
- (IBAction)onDoneButton:(id)sender;

- (void)initTable;
- (void)initChart;
- (void)loadPositions;
- (void)loadQuotes;
- (void)refreshViews;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor grayColor] CGColor], (id)[[UIColor lightGrayColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    if (self.forUser) {
        [self setTitle:[NSString stringWithFormat:@"%@'s Portfolio", self.forUser.username]];
        [self.followBarButton setUser:self.forUser];
    }
    else {
        _forUser = [PFUser currentUser];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self initTable];
    [self initChart];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPositions) name:FollowingChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadPositions];
    _quoteTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadQuotes) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.quoteTimer) {
        [self.quoteTimer invalidate];
        _quoteTimer = nil;
    }
}

- (void)initTable {
    UINib *lotCell = [UINib nibWithNibName:@"PositionCell" bundle:nil];
    [self.tableView registerNib:lotCell forCellReuseIdentifier:@"PositionCell"];
}

- (void)initChart {
    self.chartView.allowPinchScaling = NO;
    [self.chartView setBackgroundColor:[UIColor clearColor]];
    [self configureGraph];
    [self configureChart];
}

-(void)configureGraph {
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.chartView.bounds];
    self.chartView.hostedGraph = graph;
    graph.paddingLeft = 0.0f;
    graph.paddingTop = 0.0f;
    graph.paddingRight = 0.0f;
    graph.paddingBottom = 5.0f;
    graph.axisSet = nil;
}

-(void)configureChart {
    CPTGraph *graph = self.chartView.hostedGraph;
    
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.delegate = self;
    pieChart.pieRadius = (self.chartView.bounds.size.height * 0.75) / 2;
    pieChart.identifier = graph.title;
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionCounterClockwise;
    
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.9];
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.4] atPosition:1.0];
    pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
    
    [graph addPlot:pieChart];
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.positions.count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (CPTPieChartFieldSliceWidth == fieldEnum) {
        Position *position = [self.positions objectAtIndex:index];
        Quote *quote = [self.quotes objectForKey:position.symbol];
        return [NSNumber numberWithFloat:[position valueForQuote:quote]];
    }
    return [NSDecimalNumber zero];
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style = [[CPTMutableTextStyle alloc] init];
        style.color = [CPTColor darkGrayColor];
        style.fontSize = 11.0f;
    }
    
    Position *position = [self.positions objectAtIndex:index];
    return [[CPTTextLayer alloc] initWithText:position.symbol style:style];
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    float alpha = ((float)self.positions.count - index) / self.positions.count;
    return [CPTFill fillWithColor:[[CPTColor blueColor] colorWithAlphaComponent:alpha]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.positions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PositionCell";
    PositionCell *positionCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Position *position = [self.positions objectAtIndex:indexPath.row];
    Quote *quote = [self.quotes valueForKey:position.symbol];
    
    NSNumber *percentChange;
    if (self.changeButton.selected) {
        if (position.costBasis > 0) {
            float totalChange = ([position valueForQuote:quote] - position.costBasis) / position.costBasis;
            percentChange = [NSNumber numberWithFloat:totalChange * 100];
        }
    }
    else {
        if (quote) {
            percentChange = [NSNumber numberWithFloat:quote.percentChange];
        }
    }
    
    positionCell.userInteractionEnabled = YES;
    positionCell.symbolLabel.text = position.symbol;
    positionCell.priceLabel.text = [NSString stringWithFormat:@"%0.2f", quote.price];
    positionCell.percentChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", [percentChange floatValue]];
    positionCell.percentChangeLabel.textColor = [PortfolioService getColorForChange:[percentChange floatValue]];
    positionCell.allocationLable.text = [NSString stringWithFormat:@"%+0.1f%%", [position valueForQuote:quote] / self.totalValue * 100];
    
    if ([CashSymbol isEqualToString:position.symbol]) {
        positionCell.priceLabel.text = nil;
        positionCell.percentChangeLabel.text = nil;
        positionCell.userInteractionEnabled = NO;
    }
    
    return positionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowStockSegue" sender:self];
}

- (void)refreshViews {
    
    float totalValue = 0;
    for (Position *position in self.positions ) {
        totalValue += [position valueForQuote:[self.quotes objectForKey:position.symbol]];
    }
    self.totalValue = totalValue;
    
    NSNumber *percentChange;
    if (self.changeButton.selected) {
        percentChange = [PortfolioService getTotalChangeForPositions:self.positions quotes:self.quotes];
    }
    else {
        percentChange = [PortfolioService getDayChangeForPositions:self.positions quotes:self.quotes];
    }
    
    self.changeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", [percentChange floatValue]];
    self.changeLabel.textColor = [PortfolioService getColorForChange:[percentChange floatValue]];
    
    [self.tableView reloadData];
    [self.chartView.hostedGraph reloadData];
}

- (void)loadPositions {
    [[ParseClient instance] fetchLotsForUserId:self.forUser.objectId callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            _positions = [Position fromObjects:objects];
            [[FinanceClient instance] fetchQuotesForPositions:self.positions callback:^(NSURLResponse *response, NSData *data, NSError *error) {
                if (!error) {
                    _quotes = [Quote fromData:data];
                    _positions = [self.positions sortedArrayUsingComparator:^NSComparisonResult(id first, id second) {
                            
                        Position *firstPosition = (Position*)first;
                        Quote *firstQuote = [self.quotes objectForKey:firstPosition.symbol];
                        float firstValue = [firstPosition valueForQuote:firstQuote];
                            
                        Position *secondPosition = (Position*)second;
                        Quote *secondQuote = [self.quotes objectForKey:secondPosition.symbol];
                        float secondValue = [secondPosition valueForQuote:secondQuote];
                            
                        return firstValue < secondValue;
                    }];
                    [self refreshViews];
                } else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];

            [self refreshViews];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)loadQuotes {
    [[FinanceClient instance] fetchQuotesForPositions:self.positions callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            _quotes = [Quote fromData:data];
            [self refreshViews];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (IBAction)onChangeButton:(id)sender {
    [self.changeButton setSelected:!self.changeButton.selected];
    [self refreshViews];
}

- (IBAction)onDoneButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowStockSegue"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        Position *position = [self.positions objectAtIndex:indexPath.row];
        Quote *quote = [self.quotes objectForKey:position.symbol];
        
        StockViewController *stockViewController = segue.destinationViewController;
        stockViewController.forPosition = position;
        stockViewController.quote = quote;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
