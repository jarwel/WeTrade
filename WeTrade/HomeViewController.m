//
//  HomeViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "HomeViewController.h"
#import "SecurityViewController.h"
#import "PortfolioService.h"
#import "QuoteService.h"
#import "Constants.h"
#import "ParseClient.h"
#import "FinanceClient.h"
#import "FavoriteBarButton.h"
#import "PositionCell.h"
#import "Position.h"
#import "Quote.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (weak, nonatomic) IBOutlet UILabel *changeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;
@property (weak, nonatomic) IBOutlet FavoriteBarButton *favoriteBarButton;

@property (strong, nonatomic) NSArray *positions;
@property (assign, nonatomic) float totalValue;

- (IBAction)onChangeButton:(id)sender;
- (IBAction)onDoneButton:(id)sender;

- (void)initTable;
- (void)initChart;
- (void)reloadTotals;
- (void)refreshQuotes;
- (void)refreshPositions;
- (void)orientationChanged;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor grayColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    if (self.user) {
        [self.favoriteBarButton setupForUser:self.user];
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self initTable];
    [self initChart];
    [self refreshPositions];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.viewDeckController) {
        [self.viewDeckController setEnabled:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshQuotes) name:QuotesUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPositions) name:PortfolioChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QuotesUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PortfolioChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)refreshQuotes {
    NSLog(@"HomeViewController refreshQuotes");
    
    [self reloadTotals];
    [self.tableView reloadData];
    [self.chartView.hostedGraph reloadData];
}

- (void)refreshPositions {
    NSLog(@"HomeViewController refreshPositions");
    
    if (self.user) {
        [[ParseClient instance] fetchLotsForUserId:self.user.objectId callback:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSArray *positions = [Position fromObjects:objects];
                [self sortPositions:positions];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    else {
        NSArray *positions =  [[PortfolioService instance] positions];
        [self sortPositions:positions];
    }
}

- (void)sortPositions:(NSArray *)positions {
    NSSet *symbols = [PortfolioService symbolsForPositions:positions];
    [[FinanceClient instance] fetchQuotesForSymbols:symbols callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSDictionary *quotes = [Quote mapFromData:data];
            _positions = [positions sortedArrayUsingComparator:^NSComparisonResult(id first, id second) {
                
                Position *firstPosition = (Position*)first;
                Quote *firstQuote = [quotes objectForKey:firstPosition.symbol];
                float firstValue = [firstPosition valueForQuote:firstQuote];
                
                Position *secondPosition = (Position*)second;
                Quote *secondQuote = [quotes objectForKey:secondPosition.symbol];
                float secondValue = [secondPosition valueForQuote:secondQuote];
                
                return firstValue < secondValue;
            }];
            [self reloadTotals];
            [self.tableView reloadData];
            [self.chartView.hostedGraph reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)orientationChanged {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (self.viewDeckController) {
        [self.viewDeckController setEnabled:(orientation == UIDeviceOrientationPortrait)];
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
        Quote *quote = [[QuoteService instance] quoteForSymbol:position.symbol];
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
    positionCell.symbolLabel.text = position.symbol;
    
    if ([position.symbol isEqualToString:CashSymbol]) {
        positionCell.priceLabel.text = nil;
        positionCell.percentChangeLabel.text = nil;
        positionCell.userInteractionEnabled = NO;
        positionCell.allocationLable.text = [NSString stringWithFormat:@"%+0.1f%%", position.shares / self.totalValue * 100];
    }
    else {
        Quote *quote = [[QuoteService instance] quoteForSymbol:position.symbol];
        
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
        positionCell.percentChangeLabel.textColor = [PortfolioService colorForChange:[percentChange floatValue]];
        positionCell.allocationLable.text = [NSString stringWithFormat:@"%+0.1f%%", [position valueForQuote:quote] / self.totalValue * 100];
    }
    
    return positionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowSecuritySegue" sender:self];
}

- (void)reloadTotals {
    NSSet *symbols = [PortfolioService symbolsForPositions:self.positions];
    NSDictionary *quotes = [[QuoteService instance] quotesForSymbols:symbols];

    self.totalValue = [[PortfolioService totalValueForQuotes:quotes positions:self.positions] floatValue];
    
    NSNumber *percentChange;
    if (self.changeButton.selected) {
        percentChange = [PortfolioService totalChangeForQuotes:quotes positions:self.positions];
    }
    else {
        percentChange = [PortfolioService dayChangeForQuotes:quotes positions:self.positions];
    }
    
    self.changeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", [percentChange floatValue]];
    self.changeLabel.textColor = [PortfolioService colorForChange:[percentChange floatValue]];
}

- (IBAction)onChangeButton:(id)sender {
    [self.changeButton setSelected:!self.changeButton.selected];
    [self reloadTotals];
    [self.tableView reloadData];
}

- (IBAction)onDoneButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowSecuritySegue"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        Position *position = [self.positions objectAtIndex:indexPath.row];
        SecurityViewController *securityViewController = segue.destinationViewController;
        securityViewController.symbol = position.symbol;
    }
    
    if (self.viewDeckController) {
        [self.viewDeckController setEnabled:NO];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
