//
//  UserCell.h
//  WeTrade
//
//  Created by Jason Wells on 1/30/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalChangeLabel;

@end

