//
//  StockViewController.m
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "StockViewController.h"
#import "Constants.h"
#import "ParseClient.h"
#import "FinanceClient.h"
#import "CommentCell.h"
#import "Comment.h"
#import "History.h"
#import "HistoricalQuote.h"

@interface StockViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *oneYearButton;
@property (weak, nonatomic) IBOutlet UIButton *sixMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *threeMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;

@property (nonatomic, strong) CPTXYPlotSpace *plotSpace;
@property (nonatomic, strong) CPTScatterPlot *pricePlot;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) History *history;

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
- (void)onOrientationChange;
@end

@implementation StockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.height);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor grayColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self setTitle:self.quote.symbol];
    self.nameLabel.text = self.quote.name;
    [self initChart];
    [self initTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:FollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [[ParseClient instance] fetchCommentsForSymbol:self.quote.symbol callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            _comments = [Comment fromPFObjectArray:objects];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [self onOneYearButton:self];
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
    
    CPTXYAxis *y = [(CPTXYAxisSet *)self.chartView.hostedGraph.axisSet yAxis];
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(self.history.quotes.count);
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
    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat(self.history.lowPrice);
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    NSMutableArray *customTickLocations = [[NSMutableArray alloc] initWithCapacity:self.history.quotes.count];
    NSMutableArray *customLabels = [[NSMutableArray alloc] initWithCapacity: customTickLocations.count];
    
    NSInteger lastMonth = -1;
    for (int i = 0; i < self.history.quotes.count; i++) {
        [customTickLocations addObject:[NSNumber numberWithInt:i]];
        
        HistoricalQuote *quote = [self.history.quotes objectAtIndex:i];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:(NSMonthCalendarUnit) fromDate:quote.date];
        
        if (components.month != lastMonth) {
            if (lastMonth != -1) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMM"];
    
                CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithText:[dateFormatter stringFromDate:quote.date] textStyle:style];
                axisLabel.tickLocation = [[NSNumber numberWithInt:i] decimalValue];
                axisLabel.offset = x.labelOffset + x.majorTickLength;
                axisLabel.rotation = M_PI / 4;
                [customLabels addObject:axisLabel];
            }
            lastMonth = components.month;
        }
        x.axisLabels =  [NSSet setWithArray:customLabels];
        x.majorTickLocations =  [NSSet setWithArray:customTickLocations];
    }
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
    
    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(self.history.quotes.count)];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(low) length:CPTDecimalFromFloat(high - low)];
    
    CPTColor *plotColor = start > end ? [CPTColor redColor] : [CPTColor greenColor];
    CPTMutableLineStyle *lineStyle = [[CPTMutableLineStyle alloc] init];
    lineStyle.lineColor = plotColor;
    self.pricePlot.dataLineStyle = lineStyle;
    
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:plotColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    self.pricePlot.areaFill = [CPTFill fillWithGradient:areaGradient];
    self.pricePlot.areaBaseValue = CPTDecimalFromInteger(low);
    
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
    commentCell.timeLabel.text = [self getTimeSince:comment.createdAt];
    commentCell.textLabel.text = comment.text;
    commentCell.textLabel.numberOfLines = 0;
    commentCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [commentCell.followButton setUser:comment.user];

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

- (void)onOrientationChange {
    UIDevice *device = [UIDevice currentDevice];
    [self.navigationController setNavigationBarHidden:!(device.orientation == UIDeviceOrientationPortrait)];
    [self.tableView setHidden:!(device.orientation == UIDeviceOrientationPortrait)];
    [self.commentView setHidden:!(device.orientation == UIDeviceOrientationPortrait)];
}

- (IBAction)onThreeMonthButton:(id)sender {
    self.oneYearButton.selected = NO;
    self.sixMonthButton.selected = NO;
    self.threeMonthButton.selected = YES;
    
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
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = -1;
    NSDate *endDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *startDate = [calendar dateByAddingComponents:components toDate:endDate options:0];
    [self fetchHistoryForStartDate:startDate endDate:endDate];
}

- (void)fetchHistoryForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [[FinanceClient instance] fetchHistoryForSymbol:self.quote.symbol startDate:startDate endDate:endDate callback:^(NSURLResponse *response, NSData *data, NSError *error) {
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
        [[ParseClient instance] addCommentWithSymbol:self.quote.symbol text:commentText];
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

- (NSString *)getTimeSince:(NSDate *)date {
    int seconds = [[NSDate date] timeIntervalSinceDate:date];
    if (seconds > 60) {
        int minutes = seconds / 60;
        if (minutes > 60) {
            int hours = minutes / 60;
            if (hours > 24) {
                int days = hours / 24;
                return [NSString stringWithFormat:@"%d day%@ ago", days, days == 1 ? @"" : @"s" ];
            }
            return [NSString stringWithFormat:@"%d hour%@ ago", hours, hours == 1 ? @"" : @"s"];
        }
        return [NSString stringWithFormat:@"%d minute%@ ago", minutes, minutes == 1 ? @"" : @"s"];
    }
    return [NSString stringWithFormat:@"%d second%@ ago", seconds, seconds == 1 ? @"" : @"s"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
