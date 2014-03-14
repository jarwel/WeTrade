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
#import "FavoriteBarButton.h"
#import "PositionCell.h"
#import "Position.h"
#import "Quote.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (weak, nonatomic) IBOutlet UILabel *changeLabel;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;
@property (weak, nonatomic) IBOutlet FavoriteBarButton *favoriteBarButton;

@property (assign, nonatomic) BOOL isLandscape;
@property (assign, nonatomic) BOOL showSectors;
@property (assign, nonatomic) float totalValue;
@property (strong, nonatomic) NSArray *positions;
@property (strong, nonatomic) NSArray *sectors;

- (IBAction)onChangeButton:(id)sender;
- (IBAction)onDoneButton:(id)sender;

- (void)initTable;
- (void)initChart;
- (void)reloadQuotes;
- (void)reloadPositions;
- (void)reloadTotals;
- (void)refreshViews;
- (void)sortPositions:(NSArray *)positions;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.height);
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadPositions];
    [self refreshViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPositions) name:PortfolioChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadQuotes) name:QuotesUpdatedNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.viewDeckController setEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PortfolioChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QuotesUpdatedNotification object:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self refreshViews];
}

- (void)refreshViews {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    _isLandscape = UIDeviceOrientationIsLandscape(orientation) || orientation == UIDeviceOrientationPortraitUpsideDown;
    
    if (self.isLandscape) {
        [self.viewDeckController closeOpenView];
    }
    [self.chartView setHidden:self.isLandscape];
    [self.tableHeaderView setHidden:self.isLandscape];
    [self.viewDeckController setEnabled:!self.isLandscape];
    [self.tableView reloadData];
}

- (void)reloadQuotes {
    NSLog(@"HomeViewController reloadQuotes");
    [self reloadTotals];
    [self.chartView.hostedGraph reloadData];
    [self.tableView reloadData];
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


- (void)reloadPositions {
    NSLog(@"HomeViewController reloadPositions");
    
    if (self.user) {
        [PortfolioService positionsForUserId:self.user.objectId callback:^(NSArray *positions) {
            [self sortPositions:positions];
        }];
    }
    else {
        NSArray *positions = [[PortfolioService instance] positions];
        [self sortPositions:positions];
    }
}

- (void)sortPositions:(NSArray *)positions {
    NSSet *symbols = [PortfolioService symbolsForPositions:positions];
    NSSet *sectors = [PortfolioService sectorsForPositions:positions];
    NSDictionary *quotes = [[QuoteService instance] quotesForSymbols:symbols];
        
    _positions = [positions sortedArrayUsingComparator:^NSComparisonResult(id first, id second) {
        Position *firstPosition = (Position*)first;
        Quote *firstQuote = [quotes objectForKey:firstPosition.symbol];
        float firstValue = [firstPosition valueForQuote:firstQuote];
            
        Position *secondPosition = (Position*)second;
        Quote *secondQuote = [quotes objectForKey:secondPosition.symbol];
        float secondValue = [secondPosition valueForQuote:secondQuote];
            
        return firstValue < secondValue;
    }];
    
    _sectors = [[sectors allObjects] sortedArrayUsingComparator:^NSComparisonResult(id first, id second) {
        NSString *firstSector = (NSString *)first;
        float firstValue = 0.0f;
        
        NSString *secondSector = (NSString *)second;
        float secondValue = 0.0f;
        
        for (Position *position in positions) {
            Quote *quote = [quotes objectForKey:position.symbol];
            if ([position.sector isEqualToString:firstSector]) {
                firstValue += [position valueForQuote:quote];
            }
            if ([position.sector isEqualToString:secondSector]) {
                secondValue += [position valueForQuote:quote];
            }
        }
        return firstValue < secondValue;
    }];

    [self reloadTotals];
    [self.tableView reloadData];
    [self.chartView.hostedGraph reloadData];
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
    pieChart.pieRadius = self.chartView.bounds.size.height * 0.7 / 2;
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
    return self.showSectors ? self.sectors.count : self.positions.count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (CPTPieChartFieldSliceWidth == fieldEnum) {
        if (self.showSectors) {
            float value = 0.0f;
            NSString *sector = [self.sectors objectAtIndex:index];
            for (Position *position in self.positions) {
                if ([position.sector isEqualToString:sector]) {
                    Quote *quote = [[QuoteService instance] quoteForSymbol:position.symbol];
                    value += [position valueForQuote:quote];
                }
            }
            return [NSNumber numberWithFloat:value];
        }
        else {
            Position *position = [self.positions objectAtIndex:index];
            Quote *quote = [[QuoteService instance] quoteForSymbol:position.symbol];
            return [NSNumber numberWithFloat:[position valueForQuote:quote]];
        }
    }
    return [NSDecimalNumber zero];
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style = [[CPTMutableTextStyle alloc] init];
        style.color = [CPTColor darkGrayColor];
        style.fontSize = 10.5f;
    }

    if (self.showSectors) {
        return [[CPTTextLayer alloc] initWithText:[self.sectors objectAtIndex:index] style:style];
    }

    Position *position = [self.positions objectAtIndex:index];
    return [[CPTTextLayer alloc] initWithText:position.symbol style:style];
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    CPTColor *color = self.showSectors ? [CPTColor greenColor] : [CPTColor blueColor];
    float count = self.showSectors ? self.sectors.count : self.positions.count;
    return [CPTFill fillWithColor:[color colorWithAlphaComponent:(count - index) / count]];
}

-(void)pieChart:(CPTPieChart *)pieChart sliceWasSelectedAtRecordIndex:(NSUInteger)index {
    _showSectors = !self.showSectors;
    [self.chartView.hostedGraph reloadData];
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
        positionCell.sectorLabel.text = nil;
        positionCell.userInteractionEnabled = NO;
        positionCell.allocationLable.text = [NSString stringWithFormat:@"%0.1f%%", position.shares / self.totalValue * 100];
    }
    else {
        Quote *quote = [[QuoteService instance] quoteForSymbol:position.symbol];
        
        if (self.changeButton.selected && position.costBasis > 0) {
            float totalChange = ([position valueForQuote:quote] - position.costBasis) / position.costBasis * 100;
            positionCell.percentChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", totalChange];
            positionCell.percentChangeLabel.textColor = [PortfolioService colorForChange:totalChange];
        }
        else {
            if (quote) {
                positionCell.percentChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", quote.percentChange];
                positionCell.percentChangeLabel.textColor = [PortfolioService colorForChange:quote.priceChange];
            }
        }
    
        positionCell.userInteractionEnabled = YES;
        positionCell.symbolLabel.text = position.symbol;
        positionCell.priceLabel.text = [NSString stringWithFormat:@"%0.2f", quote.price];
        positionCell.allocationLable.text = [NSString stringWithFormat:@"%0.1f%%", [position valueForQuote:quote] / self.totalValue * 100];
        
        if (self.isLandscape) {
            positionCell.sectorLabel.text = position.sector;
            positionCell.percentChangeLabel.text = [NSString stringWithFormat:@"%+0.2f (%+0.2f%%)", quote.priceChange, quote.percentChange];
        }
        else {
            positionCell.sectorLabel.text = nil;
        }
    }
    
    return positionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowSecuritySegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowSecuritySegue"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        Position *position = [self.positions objectAtIndex:indexPath.row];
        SecurityViewController *securityViewController = segue.destinationViewController;
        securityViewController.symbol = position.symbol;
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)onChangeButton:(id)sender {
    [self.changeButton setSelected:!self.changeButton.selected];
    [self reloadTotals];
    [self.tableView reloadData];
}

- (IBAction)onDoneButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
