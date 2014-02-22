//
//  StockViewController.h
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "Position.h"

@interface StockViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CPTPlotDataSource>

@property (nonatomic, strong) Position *forPosition;
@property (nonatomic, strong) Quote *quote;

@end
