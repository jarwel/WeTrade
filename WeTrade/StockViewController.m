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
#import "HistoricalQuote.h"

@interface StockViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stockNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSArray *historicalQuotes;

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
    [[FinanceClient instance] fetchPlotsForSymbol:self.forPosition.symbol callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSMutableArray *historicalQuotes = [[NSMutableArray alloc] init];
            
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSDictionary *results = [[dictionary objectForKey:@"query"] objectForKey:@"results"];
            
            NSArray *array = [results objectForKey:@"quote"];
            float smallest = 100;
            float largest = 0;
            for (NSDictionary *data in array) {
                HistoricalQuote *historicalQuote = [[HistoricalQuote alloc] initWithData:data];
                if(historicalQuote.close < smallest) {
                    smallest = historicalQuote.close;
                }
                if(historicalQuote.close > largest) {
                    largest = historicalQuote.close;
                }
                [historicalQuotes addObject:historicalQuote];
            }

            float xMax = historicalQuotes.count;
            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.chartView.hostedGraph.defaultPlotSpace;
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(xMax)];
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(smallest) length:CPTDecimalFromFloat(largest)];
            
            _historicalQuotes = [[historicalQuotes reverseObjectEnumerator] allObjects];
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
    CPTXYAxis *y = [(CPTXYAxisSet *)graph.axisSet yAxis];
    y.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(24.0)];
    y.majorIntervalLength = CPTDecimalFromInt(2);
    graph.axisSet.axes = @[y];
    NSNumberFormatter *noDecimalFormatter = [[NSNumberFormatter alloc] init];
    [noDecimalFormatter setNumberStyle:NSNumberFormatterNoStyle];
    y.labelFormatter = noDecimalFormatter;
    y.majorIntervalLength = CPTDecimalFromInt(2);
}

-(void)configureChart {
    CPTGraph *graph = self.chartView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    CPTScatterPlot *pricePlot = [[CPTScatterPlot alloc] init];
    pricePlot.dataSource = self;
    pricePlot.delegate = self;
    
    [graph addPlot:pricePlot toPlotSpace:plotSpace];
}


- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.historicalQuotes.count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    int count = self.historicalQuotes.count;
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < count) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
        case CPTScatterPlotFieldY: {
            HistoricalQuote *historicalQuote = [self.historicalQuotes objectAtIndex:index];
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
    commentCell.textLabel.text = comment.text;
    return commentCell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
