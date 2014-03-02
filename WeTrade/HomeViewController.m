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
#import "FollowBarButton.h"
#import "PositionCell.h"
#import "Position.h"
#import "Quote.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (weak, nonatomic) IBOutlet UILabel *changeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;
@property (weak, nonatomic) IBOutlet FollowBarButton *followBarButton;

@property (nonatomic, strong) PortfolioService *porfolioService;
@property (nonatomic, strong) NSArray *positions;
@property (nonatomic, strong) NSDictionary *quotes;
@property (nonatomic, strong) NSTimer *quoteTimer;
@property (nonatomic, assign) float totalValue;

- (IBAction)onChangeButton:(id)sender;
- (IBAction)onDoneButton:(id)sender;

- (void)initTable;
- (void)initChart;
- (void)loadQuotes;
- (void)loadPositions;
- (void)refreshViews;
- (void)onOrientationChange;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor grayColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    if (self.user) {
        [self setTitle:[NSString stringWithFormat:@"%@'s Portfolio", self.user.username]];
        [self.followBarButton setUser:self.user];
    }
    else {
        _user = [PFUser currentUser];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    _porfolioService = [PortfolioService instance];
    [self loadPositions];
    
    [self initTable];
    [self initChart];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPositions) name:PortfolioChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    _quoteTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadQuotes) userInfo:nil repeats:YES];
    if (self.viewDeckController) {
        [self.viewDeckController setEnabled:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.quoteTimer) {
        [self.quoteTimer invalidate];
        _quoteTimer = nil;
    }
    if (self.viewDeckController) {
        [self.viewDeckController setEnabled:NO];
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
    return self.porfolioService.positions.count;
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
    positionCell.percentChangeLabel.textColor = [[PortfolioService instance] colorForChange:[percentChange floatValue]];
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
    self.totalValue = [[self.porfolioService totalValueForQuotes:self.quotes] floatValue];
    
    NSNumber *percentChange;
    if (self.changeButton.selected) {
        percentChange = [self.porfolioService totalChangeForQuotes:self.quotes];
    }
    else {
        percentChange = [self.porfolioService dayChangeForQuotes:self.quotes];
    }
    
    self.changeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", [percentChange floatValue]];
    self.changeLabel.textColor = [self.porfolioService colorForChange:[percentChange floatValue]];
    
    [self.tableView reloadData];
    [self.chartView.hostedGraph reloadData];
}

- (void)loadPositions {
    [[FinanceClient instance] fetchQuotesForPositions:self.porfolioService.positions callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            _quotes = [Quote fromData:data];
            _positions = [self.porfolioService.positions sortedArrayUsingComparator:^NSComparisonResult(id first, id second) {
                
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
}

- (void)loadQuotes {
    [[FinanceClient instance] fetchQuotesForPositions:self.porfolioService.positions callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            _quotes = [Quote fromData:data];
            [self refreshViews];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)onOrientationChange {
    UIDevice *device = [UIDevice currentDevice];
    [self.viewDeckController setEnabled:(device.orientation == UIDeviceOrientationPortrait)];
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
        Position *position = [self.porfolioService.positions objectAtIndex:indexPath.row];
        Quote *quote = [self.quotes objectForKey:position.symbol];
        
        StockViewController *stockViewController = segue.destinationViewController;
        stockViewController.symbol = quote.symbol;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
