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

@property (weak, nonatomic) IBOutlet UILabel *percentChangeLabel;
@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UITableView *positionsTableView;

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) NSArray *positions;
@property (nonatomic, strong) NSDictionary *quotes;
@property (nonatomic, strong) NSTimer *quoteTimer;

- (void)initTable;
- (void)initChart;
- (void)loadPositions;
- (void)loadQuotes;
- (void)refreshViews;


- (void)configureGraph;
- (void)configureChart;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [self.positionsTableView registerNib:lotCell forCellReuseIdentifier:@"PositionCell"];
    self.positionsTableView.delegate = self;
    self.positionsTableView.dataSource = self;
}

- (void)initChart {
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:_chartView.bounds];
    self.hostView.allowPinchScaling = NO;
    [self.chartView addSubview:self.hostView];
    
    [self configureGraph];
    [self configureChart];
}

-(void)configureGraph {
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    graph.paddingLeft = 0.0f;
    graph.paddingTop = 0.0f;
    graph.paddingRight = 0.0f;
    graph.paddingBottom = 0.0f;
    graph.axisSet = nil;
    
    // 2 - Set up text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 14.0f;
}

-(void)configureChart {
    CPTGraph *graph = self.hostView.hostedGraph;
    
    // 2 - Create chart
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.delegate = self;
    pieChart.pieRadius = (self.hostView.bounds.size.height * 0.7) / 2;
    pieChart.identifier = graph.title;
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionClockwise;
    
    // 3 - Create gradient
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.9];
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.4] atPosition:1.0];
    pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
    
    // 4 - Add chart to graph
    [graph addPlot:pieChart];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _positions.count;
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

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.positions.count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (CPTPieChartFieldSliceWidth == fieldEnum) {
        Position *position = [self.positions objectAtIndex:index];
        Quote *quote = [self.quotes objectForKey:position.symbol];
        return [NSNumber numberWithFloat: [position valueForQuote:quote]];
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
    
    float portfolioValue = 0;
    for (Position *position in self.positions) {
        portfolioValue += [position valueForQuote:[self.quotes objectForKey:position.symbol]];
    }
    
    Position *position = [self.positions objectAtIndex:index];
    float positionValue = [position valueForQuote:[self.quotes objectForKey:position.symbol]];
    
    NSString *text = [NSString stringWithFormat:@"%@ - %0.2f%%", position.symbol, positionValue / portfolioValue * 100];
    return [[CPTTextLayer alloc] initWithText:text style:style];
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
}

- (void)refreshViews {
    if (((Quote *)[[self.quotes allValues] firstObject]).price == 0) {
        NSLog(@"Error: zero value quotes!!!");
    }
    else {
        float currentValue = 0;
        float costBasis = 0;
        for (Position *position in self.positions) {
            Quote *quote = [self.quotes objectForKey:position.symbol];
            currentValue += [position valueForQuote:quote];
            costBasis += position.costBasis;
        }
        float percentChange = costBasis > 0 ? (currentValue - costBasis) / costBasis * 100 : 0;
        self.percentChangeLabel.text = [NSString stringWithFormat:@"%+0.2f%%", percentChange];
        self.percentChangeLabel.textColor = [self getChangeColor:percentChange];
    
        [self.positionsTableView reloadData];
        [self.hostView.hostedGraph reloadData];
    }
}

- (void)loadPositions {
    [[ParseClient instance] fetchLots:^(NSArray *objects, NSError *error) {
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
        [[FinanceClient instance] fetchQuotesForSymbols:[symbols componentsJoinedByString:@","] callback:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error) {
                NSMutableDictionary *quotes = [[NSMutableDictionary alloc] init];
                data = [self fixGoogleApiData:data];
                NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for( NSDictionary *data in array) {
                    Quote *quote = [[Quote alloc] initWithData:data];
                    
                    if (quote.price == 0) {
                        NSLog(@"Error: price for %@ is empty", quote.symbol);
                        return;
                    }
                    
                    [quotes setObject:quote forKey:quote.symbol];
                }
                _quotes = quotes;
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

// Hack to deal with Google Finance API data weirdness
- (NSData *)fixGoogleApiData:(NSData *)data {
    NSString *content =[NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
    NSRange range1 = [content rangeOfString:@"["];
    NSRange range2 = [content rangeOfString:@"]"];
    NSRange range3;
    range3.location = range1.location+1;
    range3.length = (range2.location - range1.location)-1;
    NSString *contentFixed = [NSString stringWithFormat:@"[%@]", [content substringWithRange:range3]];
    NSData *dataFixed = [contentFixed dataUsingEncoding:NSUTF8StringEncoding];
    return dataFixed;
}

@end
