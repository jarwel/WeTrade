//
//  StockViewController.m
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "StockViewController.h"
#import "ParseClient.h"
#import "FinanceClient.h"
#import "CommentCell.h"
#import "Comment.h"
#import "History.h"
#import "HistoricalQuote.h"

@interface StockViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stockNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) History *history;

- (IBAction)onAddComment:(id)sender;

@end

@implementation StockViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:self.forPosition.symbol];
    [self initChart];
    [self initTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [[ParseClient instance] fetchCommentsForSymbol:self.forPosition.symbol callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            _comments = [Comment fromPFObjectArray:objects];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    NSDateComponents *addComponents = [[NSDateComponents alloc] init];
    addComponents.year = - 1;
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] dateByAddingComponents:addComponents toDate:endDate options:0];
    
    [[FinanceClient instance] fetchHistoryForSymbol:self.forPosition.symbol startDate:startDate endDate:endDate callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            _history = [History fromJSONDictionary:dictionary];

            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.chartView.hostedGraph.defaultPlotSpace;
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(self.history.quotes.count)];
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.history.priceLow) length:CPTDecimalFromFloat(self.history.priceHigh - self.history.priceLow)];
    
            [self.chartView.hostedGraph reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)initTable {
    UINib *commentCell = [UINib nibWithNibName:@"CommentCell" bundle:nil];
    [self.tableView registerNib:commentCell forCellReuseIdentifier:@"CommentCell"];
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
    //CPTXYAxis *y = [(CPTXYAxisSet *)graph.axisSet yAxis];
    //y.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(24.0)];
    //y.majorIntervalLength = CPTDecimalFromInt(2);
    //graph.axisSet.axes = @[y];
    //NSNumberFormatter *noDecimalFormatter = [[NSNumberFormatter alloc] init];
    //[noDecimalFormatter setNumberStyle:NSNumberFormatterNoStyle];
    //y.labelFormatter = noDecimalFormatter;
    //y.majorIntervalLength = CPTDecimalFromInt(2);
}

-(void)configureChart {
    CPTXYPlotSpace *plotSpace  = (CPTXYPlotSpace *) self.chartView.hostedGraph.defaultPlotSpace;
    
    CPTScatterPlot *pricePlot = [[CPTScatterPlot alloc] init];
    pricePlot.dataSource = self;
    pricePlot.delegate = self;
    
    [self.chartView.hostedGraph addPlot:pricePlot toPlotSpace:plotSpace];
}


- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.history.quotes.count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    int count = self.history.quotes.count;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CommentCell";
    CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    commentCell.usernameLabel.text = comment.username;
    commentCell.textLabel.text = comment.text;
    
    int hours = [[NSDate date] timeIntervalSinceDate:comment.createdAt] / 3600;
    commentCell.timeLabel.text = [NSString stringWithFormat:@"%d hours ago", hours];
    
    [commentCell.followButton initForUser:comment.user following:NO];
    
    return commentCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *cellText = [self.comments objectAtIndex:indexPath.row];
    //UIFont *cellFont = [UIFont fontWithName:@"Arial" size:15];
    //CGSize constraintSize = CGSizeMake(320.0f, MAXFLOAT);
    //CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return 95;
}

- (IBAction)onAddComment:(id)sender {
    NSString *commentText = self.commentTextField.text;
    if (commentText) {
        [[ParseClient instance] addCommentWithSymbol:self.forPosition.symbol text:commentText];
        Comment *comment = [[Comment alloc] init];
        comment.username = [PFUser currentUser].username;
        comment.text = commentText;
        comment.createdAt = [NSDate date];
        [self.comments insertObject:comment atIndex:0];
        [self.tableView reloadData];
    }
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
