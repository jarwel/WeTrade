//
//  LotCell.h
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LotCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *sharesLabel;
@property (weak, nonatomic) IBOutlet UILabel *costBasisLabel;
@property (weak, nonatomic) IBOutlet UIButton *cashButton;

@end
