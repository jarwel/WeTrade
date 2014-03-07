//
//  HomeViewController.h
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "IIViewDeckController.h"
#import "CorePlot-CocoaTouch.h"

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CPTPlotDataSource>

@property (strong, nonatomic) IIViewDeckController *viewDeckController;
@property (strong, nonatomic) PFUser *user;

@end
