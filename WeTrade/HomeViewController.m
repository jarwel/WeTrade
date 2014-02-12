//
//  HomeViewController.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "HomeViewController.h"
#import "StockViewController.h"
#import "ParseClient.h"
#import "FinanceClient.h"
#import "PositionCell.h"
#import "Position.h"
#import "Quote.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *followButton;

@property (weak, nonatomic) IBOutlet UILabel *percentChangeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;
@property (nonatomic, strong) NSArray *positions;
@property (nonatomic, strong) NSDictionary *quotes;
@property (nonatomic, strong) NSTimer *quoteTimer;

- (IBAction)onBackButton:(id)sender;
- (IBAction)onFollowButton:(id)sender;
- (IBAction)onUnfollowButton:(id)sender;

- (void)initTable;
- (void)initChart;
- (void)loadPositions;
- (void)loadQuotes;
- (void)refreshViews;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.forUser) {
        [self setTitle:self.forUser.username];
    }
    else {
        _forUser = [PFUser currentUser];
        [self.backButton setEnabled:NO];
        [self.followButton setEnabled:NO];
    }
    
    [self initTable];
    [self initChart];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadPositions];
    _quoteTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadQuotes) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    if(self.quoteTimer) {
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
    [self configureGraph];
    [self configureChart];
}

-(void)configureGraph {
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.chartView.bounds];
    self.chartView.hostedGraph = graph;
    graph.paddingLeft = 0.0f;
    graph.paddingTop = 0.0f;
    graph.paddingRight = 0.0f;
    graph.paddingBottom = 0.0f;
    graph.axisSet = nil;
}

-(void)configureChart {
    CPTGraph *graph = self.chartView.hostedGraph;
    
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.delegate = self;
    pieChart.pieRadius = (self.chartView.bounds.size.height * 0.7) / 2;
    pieChart.identifier = graph.title;
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionClockwise;
    
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
        style= [[CPTMutableTextStyle alloc] init];
        style.color = [CPTColor grayColor];
        style.fontSize = 10.0f;
    }
    
    Position *position = [self.positions objectAtIndex:index];
    return [[CPTTextLayer alloc] initWithText:position.symbol style:style];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.positions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PositionCell";
    PositionCell *positionCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Position *position = [self.positions objectAtIndex:indexPath.row];
    Quote *quote = [self.quotes valueForKey:position.symbol];
    
    positionCell.symbolLabel.text = position.symbol;
    positionCell.priceLabel.text = [NSString stringWithFormat:@"%0.2f", quote.price];
    
    if (quote) {
        positionCell.percentChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", quote.percentChange];
        positionCell.percentChangeLabel.textColor = [self getChangeColor:quote.percentChange];
        
        float currentValue = [position valueForQuote:quote];
        float percentChangeTotal = (currentValue - position.costBasis) / position.costBasis * 100;
        positionCell.percentChangeTotalLabel.text = [NSString stringWithFormat:@"%+0.2f%%", percentChangeTotal];
        positionCell.percentChangeTotalLabel.textColor = [self getChangeColor:percentChangeTotal];
    }
    
    return positionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowStock" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowStock"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        Position *position = [self.positions objectAtIndex:indexPath.row];
        
        StockViewController *stockViewController = segue.destinationViewController;
        stockViewController.forPosition = position;
    }
}

- (void)refreshViews {
    float currentValue = 0;
    float costBasis = 0;
    for (Position *position in self.positions) {
        Quote *quote = [self.quotes objectForKey:position.symbol];
        currentValue += [position valueForQuote:quote];
        costBasis += position.costBasis;
    }
    if (costBasis > 0) {
        float percentChange = costBasis > 0 ? (currentValue - costBasis) / costBasis * 100 : 0;
        self.percentChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", percentChange];
        self.percentChangeLabel.textColor = [self getChangeColor:percentChange];
    }
    
    [self.tableView reloadData];
    [self.chartView.hostedGraph reloadData];
}

- (void)loadPositions {
    [[ParseClient instance] fetchLotsForUserId:self.forUser.objectId callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            _positions = [Position fromPFObjectArray:objects];
            [self refreshViews];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)loadQuotes {
    NSMutableArray * symbols = [[NSMutableArray alloc] init];
    for (Position *position in self.positions) {
        [symbols addObject:position.symbol];
    }
    if (symbols.count > 0) {
        [[FinanceClient instance] fetchQuotesForSymbols:symbols callback:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error) {
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                _quotes = [Quote fromJSONDictionary:dictionary];
                [self refreshViews];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
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

- (IBAction)onBackButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onFollowButton:(id)sender {
    [[ParseClient instance] followUser:self.forUser];
}

- (IBAction)onUnfollowButton:(id)sender {
    [[ParseClient instance] unfollowUser:self.forUser];
}

@end
