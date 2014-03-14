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
#import "FavoriteBarButton.h"
#import "CommentCell.h"
#import "Comment.h"
#import "FullQuote.h"
#import "Security.h"
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
@property (weak, nonatomic) IBOutlet UIButton *metricsButton;
@property (weak, nonatomic) IBOutlet UIButton *chartButton;
@property (weak, nonatomic) IBOutlet UIButton *oneYearButton;
@property (weak, nonatomic) IBOutlet UIButton *sixMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *threeMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *oneMonthButton;
@property (weak, nonatomic) IBOutlet UIView *dataPickerView;
@property (weak, nonatomic) IBOutlet UIView *chartPickerView;
@property (weak, nonatomic) IBOutlet UIView *metricsView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartViewHeightConstraint;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;
@property (weak, nonatomic) IBOutlet FavoriteBarButton *favoriteBarButton;

@property (assign, nonatomic) BOOL isLandscape;
@property (strong, nonatomic) CPTXYPlotSpace *plotSpace;
@property (strong, nonatomic) CPTScatterPlot *pricePlot;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) FullQuote *fullQuote;
@property (strong, nonatomic) History *history;

- (IBAction)onMetricsButton:(id)sender;
- (IBAction)onChartButton:(id)sender;
- (IBAction)onOneMonthButton:(id)sender;
- (IBAction)onThreeMonthButton:(id)sender;
- (IBAction)onSixMonthButton:(id)sender;
- (IBAction)onOneYearButton:(id)sender;
- (IBAction)onCommentButton:(id)sender;
- (IBAction)onAddCommentButton:(id)sender;
- (IBAction)onEditingChanged:(id)sender;
- (IBAction)onTap:(id)sender;

- (void)fetchHistoryForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (void)reloadMetrics;
- (void)refreshViews;

@end

@implementation SecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.height);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor grayColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self setTitle:self.symbol];
    [self.favoriteBarButton setupForSecurity:[[Security alloc] initWithSymbol:self.symbol]];
    [self initChart];
    [self initTable];
    
    [[ParseClient instance] fetchSecurityForSymbol:self.symbol callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            Security *security = [Security fromParseObjects:objects].firstObject;
            
            if (!security) {
                security = [[Security alloc] initWithSymbol:self.symbol];
            }
            [self.favoriteBarButton setupForSecurity:security];
            
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
    [[FinanceClient instance] fetchMetricsForSymbol:self.symbol callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            _fullQuote = [FullQuote fromData:data];
            [self reloadMetrics];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:FavoritesChangedNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FavoritesChangedNotification object:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self refreshViews];
}

- (void)refreshViews {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    _isLandscape = UIDeviceOrientationIsLandscape(orientation) || orientation == UIDeviceOrientationPortraitUpsideDown;
    
    [self.chartViewHeightConstraint setConstant: self.isLandscape ? 230.0f : 190.0f];
    [self.commentView setHidden:self.isLandscape];
    [self.tableView setHidden:self.isLandscape];
    [self.dataPickerView setHidden:self.isLandscape];
    [self.chartPickerView setHidden:!self.isLandscape];
    [self.chartButton setSelected:YES];
    [self.chartView setHidden:NO];
    [self.metricsButton setSelected:NO];
    [self.metricsView setHidden:YES];
    
    if (!self.history || !self.isLandscape) {
        [self onOneMonthButton:self];
    }
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
    graph.paddingBottom = 40.0f;
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
    CGSize size = {self.tableView.frame.size.width , 99999};
    CGFloat height = [comment.text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping].height;
    return 60 + height;

}

- (void)reloadMetrics {
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

- (IBAction)onMetricsButton:(id)sender {
    [self.chartButton setSelected:NO];
    [self.metricsButton setSelected:YES];
    [self.chartView setHidden:YES];
    [self.metricsView setHidden:NO];
}

- (IBAction)onChartButton:(id)sender {
    [self.chartButton setSelected:YES];
    [self.metricsButton setSelected:NO];
    [self.chartView setHidden:NO];
    [self.metricsView setHidden:YES];
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
