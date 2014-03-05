//
//  SecurityCell.h
//  WeTrade
//
//  Created by Jason Wells on 3/4/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowButton.h"

@interface SecurityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet FollowButton *followButton;

@end
