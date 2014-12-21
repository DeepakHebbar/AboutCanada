//
//  ACCityInfoTableViewCell.h
//  AboutCanada
//
//  Created by Deepak Kumar on 21/12/14.
//  Copyright (c) 2014 Deepak Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACCityInfoTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
@property (retain, nonatomic) IBOutlet UIImageView *rowImageView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingIndicator;
@end
