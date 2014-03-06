//
//  SecurityViewController.m
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "SecurityViewController.h"
#import "Constants.h"
#import "PortfolioService.h"
#import "ParseClient.h"
#import "FinanceClient.h"
#import "CommentCell.h"
#import "Comment.h"
#import "FullQuote.h"
#import "HistoricalQuote.h"
#import "History.h"

@interface SecurityViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousCloseLabel;
@property (weak, nonatomic) IBOutlet UILabel *highLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowLabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *oneYearTargetLabel;
@property (weak, nonatomic) IBOutlet UILabel *marketCapitalizationLabel;
@property (weak, nonatomic) IBOutlet UILabel *ebitdaLabel;
@property (weak, nonatomic) IBOutlet UILabel *pricePerEarnings;
@property (weak, nonatomic) IBOutlet UILabel *earningsPerShareLabel;
@property (weak, nonatomic) IBOutlet UILabel *dividendLabel;
@property (weak, nonatomic) IBOutlet UILabel *yieldLabel;
@property (weak, nonatomic) IBOutlet UILabel *exDividendDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dividendDateLabel;

@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;
@property (weak, nonatomic) IBOutlet UIButton *oneYearButton;
@property (weak, nonatomic) IBOutlet UIButton *sixMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *threeMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *oneMonthButton;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *dataView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;

@property (nonatomic, strong) CPTXYPlotSpace *plotSpace;
@property (nonatomic, strong) CPTScatterPlot *pricePlot;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) FullQuote *fullQuote;
@property (nonatomic, strong) History *history;

- (IBAction)onViewButton:(id)sender;
- (IBAction)onOneMonthButton:(id)sender;
- (IBAction)onThreeMonthButton:(id)sender;
- (IBAction)onSixMonthButton:(id)sender;
- (IBAction)onOneYearButton:(id)sender;
- (IBAction)onCommentButton:(id)sender;
- (IBAction)onAddCommentButton:(id)sender;
- (IBAction)onEditingChanged:(id)sender;
- (IBAction)onTap:(id)sender;

- (void)fetchHistoryForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (void)refreshChart;
- (void)refreshTable;
- (void)refreshView;
- (void)orientationChanged;
@end

@implementation SecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.height);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor grayColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self setTitle:self.symbol];
    [[FinanceClient instance] fetchFullQuoteForSymbol:self.symbol callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            _fullQuote = [FullQuote fromData:data];
            [self refreshView];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    [[ParseClient instance] fetchCommentsForSymbol:self.symbol callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            _comments = [Comment fromParseObjects:objects];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    [self onOneMonthButton:nil];
    
    [self initChart];
    [self initTable];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:FollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    BOOL isPortrait = orientation == UIDeviceOrientationPortrait;
    if (isPortrait) {
        [self onOneMonthButton:nil];
    }
    
    [self.timeView setHidden:isPortrait];
    [self.viewButton setHidden:!isPortrait];
    [self.tableView setHidden:!isPortrait];
    [self.commentView setHidden:!isPortrait];
    [self.navigationController setNavigationBarHidden:!isPortrait];
    [self.dataView setHidden:YES];
    [self.chartView setHidden:NO];
}

- (void)initTable {
    UINib *commentCell = [UINib nibWithNibName:@"CommentCell" bundle:nil];
    [self.tableView registerNib:commentCell forCellReuseIdentifier:@"CommentCell"];
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
    graph.paddingBottom = 30.0f;
    graph.plotAreaFrame.masksToBorder = NO;
}

-(void)configureChart {
    _plotSpace  = (CPTXYPlotSpace *) self.chartView.hostedGraph.defaultPlotSpace;
    _pricePlot = [[CPTScatterPlot alloc] init];
    self.pricePlot.dataSource = self;
    self.pricePlot.delegate = self;
    [self.chartView.hostedGraph addPlot:self.pricePlot toPlotSpace:self.plotSpace];
}

-(void)configureVerticalAxis {
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style = [[CPTMutableTextStyle alloc] init];
        style.color = [CPTColor darkGrayColor];
        style.fontSize = 11.0f;
    }
    
    long adjustedCoordinate = self.history.quotes.count > 0 ? self.history.quotes.count - 1 : 0;
    CPTXYAxis *y = [(CPTXYAxisSet *)self.chartView.hostedGraph.axisSet yAxis];
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(adjustedCoordinate);
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    NSMutableArray *customTickLocations = [[NSMutableArray alloc] init];
    NSMutableArray *customLabels = [[NSMutableArray alloc] init];

    float low = self.history.lowPrice;
    float high = self.history.highPrice;
    for (int i = 0; i < 4; i++) {
        float price = (high - low) / 4 * (i + 1) + low;
        [customTickLocations addObject:[NSNumber numberWithFloat:price]];
        
        NSNumber *tickLocation = [customTickLocations objectAtIndex:i];
        NSString* formattedNumber = [NSString stringWithFormat:@"%.2f", [tickLocation floatValue]];
        
        CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithText:formattedNumber textStyle:style];
        axisLabel.tickLocation = [tickLocation decimalValue];
        axisLabel.offset = y.labelOffset + y.majorTickLength;
        [customLabels addObject:axisLabel];
    }
    y.axisLabels =  [NSSet setWithArray:customLabels];
    y.majorTickLocations =  [NSSet setWithArray:customTickLocations];
}

- (void)configureHorizontalAxis {
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style = [[CPTMutableTextStyle alloc] init];
        style.color = [CPTColor darkGrayColor];
        style.fontSize = 11.0f;
    }
    
    CPTXYAxis *x = [(CPTXYAxisSet *)self.chartView.hostedGraph.axisSet xAxis];
    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat(self.history.lowPrice * 0.99f);
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    NSMutableArray *customTickLocations = [[NSMutableArray alloc] init];
    NSMutableArray *customLabels = [[NSMutableArray alloc] init];
    
    NSInteger lastMonth = -1;
    for (int i = 0; i < self.history.quotes.count; i++) {
        [customTickLocations addObject:[NSNumber numberWithInt:i + 1]];
        
        HistoricalQuote *quote = [self.history.quotes objectAtIndex:i];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:(NSMonthCalendarUnit) fromDate:quote.date];
        
        if (components.month != lastMonth) {
            if (lastMonth != -1) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMM"];
    
                CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithText:[dateFormatter stringFromDate:quote.date] textStyle:style];
                axisLabel.tickLocation = [[NSNumber numberWithInt:i + 1] decimalValue];
                axisLabel.offset = x.labelOffset + x.majorTickLength;
                axisLabel.rotation = M_PI / 4;
                [customLabels addObject:axisLabel];
            }
            lastMonth = components.month;
        }
    }
    x.axisLabels =  [NSSet setWithArray:customLabels];
    NSLog(@"LastValue %ld", [customTickLocations.lastObject integerValue]);
    NSLog(@"Count %ld", customTickLocations.count);
    x.majorTickLocations =  [NSSet setWithArray:customTickLocations];
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.history.quotes.count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    long count = self.history.quotes.count;
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < count) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
        case CPTScatterPlotFieldY: {
            HistoricalQuote *historicalQuote = [self.history.quotes objectAtIndex:index];
            return [NSNumber numberWithFloat:historicalQuote.close];
        }
    }
    return [NSDecimalNumber zero];
}

- (void)refreshChart {
    float low = self.history.lowPrice;
    float high = self.history.highPrice;
    float start = self.history.startPrice;
    float end = self.history.endPrice;
    
    [self configureVerticalAxis];
    [self configureHorizontalAxis];
    
    long adjustedLength = self.history.quotes.count > 0 ? self.history.quotes.count - 1 : 0;
    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(adjustedLength)];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(low * 0.99f) length:CPTDecimalFromFloat(high - low * 0.99f)];
    
    CPTColor *plotColor = [CPTColor colorWithCGColor:[PortfolioService colorForChange:(end - start)].CGColor];
    CPTMutableLineStyle *lineStyle = [[CPTMutableLineStyle alloc] init];
    lineStyle.lineColor = plotColor;
    self.pricePlot.dataLineStyle = lineStyle;
    
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:plotColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    self.pricePlot.areaFill = [CPTFill fillWithGradient:areaGradient];
    self.pricePlot.areaBaseValue = CPTDecimalFromInteger(low *0.99f);
    
    [self.chartView.hostedGraph reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CommentCell";
    CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    commentCell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    commentCell.usernameLabel.text = comment.username;
    commentCell.timeLabel.text = comment.timeElapsedText;
    commentCell.textLabel.text = comment.text;
    commentCell.textLabel.numberOfLines = 0;
    commentCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [commentCell.favoriteButton setupForUser:comment.user];

    return commentCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:13];
    CGSize size = {self.tableView.frame.size.width , 1000};
    CGFloat height = [comment.text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping].height;
    return 60 + height;

}

- (void)refreshTable {
    [self.tableView reloadData];
}

- (void)refreshView{
    self.nameLabel.text = self.fullQuote.name;
    self.openLabel.text = [NSString stringWithFormat:@"%0.2f", self.fullQuote.open];
    self.previousCloseLabel.text = [NSString stringWithFormat:@"%0.2f", self.fullQuote.previousClose];
    self.highLabel.text = [NSString stringWithFormat:@"%0.2f", self.fullQuote.high];
    self.lowLabel.text = [NSString stringWithFormat:@"%0.2f", self.fullQuote.low];
    self.volumeLabel.text = self.fullQuote.volumeText;
    self.oneYearTargetLabel.text = [NSString stringWithFormat:@"%0.2f", self.fullQuote.oneYearTarget];
    self.marketCapitalizationLabel.text = self.fullQuote.marketCapitalization;
    self.ebitdaLabel.text = self.fullQuote.ebitda;
    self.pricePerEarnings.text = [NSString stringWithFormat:@"%0.2f", self.fullQuote.pricePerEarnings];
    self.earningsPerShareLabel.text = [NSString stringWithFormat:@"%0.2f", self.fullQuote.earningsPerShare];
    if (self.fullQuote.dividend > 0) {
        self.dividendLabel.text = [NSString stringWithFormat:@"%0.2f", self.fullQuote.dividend];
        self.yieldLabel.text = [NSString stringWithFormat:@"%0.2f%%", self.fullQuote.yield];
        self.exDividendDateLabel.text = self.fullQuote.exDividendDate;
        self.dividendDateLabel.text = self.fullQuote.dividendDate;
    }
}

- (IBAction)onViewButton:(id)sender {
    [self.viewButton setSelected:!self.viewButton.selected];
    [self.chartView setHidden:!self.chartView.hidden];
    [self.dataView setHidden:!self.chartView.hidden];
}

- (IBAction)onOneMonthButton:(id)sender {
    self.oneYearButton.selected = NO;
    self.sixMonthButton.selected = NO;
    self.threeMonthButton.selected = NO;
    self.oneMonthButton.selected = YES;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -1;
    NSDate *endDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *startDate = [calendar dateByAddingComponents:components toDate:endDate options:0];
    [self fetchHistoryForStartDate:startDate endDate:endDate];
}

- (IBAction)onThreeMonthButton:(id)sender {
    self.oneYearButton.selected = NO;
    self.sixMonthButton.selected = NO;
    self.threeMonthButton.selected = YES;
    self.oneMonthButton.selected = NO;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -3;
    NSDate *endDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *startDate = [calendar dateByAddingComponents:components toDate:endDate options:0];
    [self fetchHistoryForStartDate:startDate endDate:endDate];
}

- (IBAction)onSixMonthButton:(id)sender {
    self.oneYearButton.selected = NO;
    self.sixMonthButton.selected = YES;
    self.threeMonthButton.selected = NO;
    self.oneMonthButton.selected = NO;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -6;
    NSDate *endDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *startDate = [calendar dateByAddingComponents:components toDate:endDate options:0];
    [self fetchHistoryForStartDate:startDate endDate:endDate];
}

- (IBAction)onOneYearButton:(id)sender {
    self.oneYearButton.selected = YES;
    self.sixMonthButton.selected = NO;
    self.threeMonthButton.selected = NO;
    self.oneMonthButton.selected = NO;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = -1;
    NSDate *endDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *startDate = [calendar dateByAddingComponents:components toDate:endDate options:0];
    [self fetchHistoryForStartDate:startDate endDate:endDate];
}

- (void)fetchHistoryForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [[FinanceClient instance] fetchHistoryForSymbol:self.symbol startDate:startDate endDate:endDate callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            _history = [History fromData:data];
            [self refreshChart];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)onCommentButton:(id)sender {
    [self.commentButton setHidden:YES];
    [self.addButton setHidden:NO];
    [self.addButton setEnabled:NO];
    [self.commentTextField setHidden:NO];
    [self.commentTextField setTextColor:[UIColor blackColor]];
    [self.commentTextField becomeFirstResponder];
}

- (IBAction)onAddCommentButton:(id)sender {
    [self.commentTextField setHidden:YES];
    [self.addButton setHidden:YES];
    [self.commentButton setHidden:NO];
    NSString *commentText = self.commentTextField.text;
    if (commentText) {
        [[ParseClient instance] createCommentWithSymbol:self.symbol text:commentText];
        Comment *comment = [[Comment alloc] init];
        comment.user = [PFUser currentUser];
        comment.text = commentText;
        comment.createdAt = [NSDate date];
        [self.comments insertObject:comment atIndex:0];
        [self.tableView reloadData];
    }
    [self.view endEditing:YES];
    self.commentTextField.text = nil;
}

- (IBAction)onEditingChanged:(id)sender {
    [self.addButton setEnabled:self.commentTextField.text.length > 0];
}

- (IBAction)onTap:(id)sender {
    [self.commentTextField setHidden:YES];
    [self.addButton setHidden:YES];
    [self.commentButton setHidden:NO];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
