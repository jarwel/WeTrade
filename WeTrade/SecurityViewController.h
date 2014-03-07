//
//  SecurityViewController.h
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface SecurityViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CPTPlotDataSource>

@property (strong, nonatomic) NSString *symbol;

@end
