//
//  ACDetailsTableViewController.m
//  AboutCanada
//
//  Created by Deepak Kumar on 21/12/14.
//  Copyright (c) 2014 Deepak Kumar. All rights reserved.
//

#import "ACDetailsTableViewController.h"
#import "ACApiManager.h"
#import "ACCityInfoTableViewCell.h"
#import "ACCityInfo.h"

#define TITLE_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f]
#define DESCRIPTION_FONT [UIFont fontWithName:@"HelveticaNeue" size:14.0f]
#define MESSAGE_LABEL_FONT [UIFont fontWithName:@"Palatino-Italic" size:20]
#define CELL_PADDING 40.f

@interface ACDetailsTableViewController ()
@property (retain, nonatomic) NSArray *dataArray;
@property (retain, nonatomic) IBOutlet UITableView *cityInfoTableView;
@end

@implementation ACDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Welcome";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataArray.count>0) {
        return 1;
    }else{
        //Display message to ask user to pull down and refresh data
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = MESSAGE_LABEL_FONT;
        [messageLabel sizeToFit];
        self.cityInfoTableView.backgroundView = messageLabel;
        self.cityInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [messageLabel release];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}
- (IBAction)refreshData:(UIRefreshControl *)sender {
    [[ACApiManager sharedInstance] loadApiDataAndUpdateTheTableViewWithCompletionHandler:^(BOOL finished, NSArray *rowsArray, NSString *pageTitle, NSError *error) {
        self.title = pageTitle;
        self.dataArray = rowsArray;
        [self.cityInfoTableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self currentCell:tableView cellForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)currentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ACCityInfo *currObject = _dataArray[indexPath.row];
    self.cityInfoTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (currObject.imageHref.length>0) {
        ACCityInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infoCellImage"];
        if (cell==nil) {
            cell = [[[ACCityInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"infoCellImage"] autorelease];
        }
        if (currObject) {
            if (currObject.title) {
                cell.titleLabel.text = currObject.title;
                cell.descLabel.text = currObject.rowsDescription;
                cell.imageLoadingIndicator.hidden = YES;
                if (currObject.imageData == nil) {
                    cell.rowImageView.image = nil;
                    cell.rowImageView.hidden = YES;
                    cell.imageLoadingIndicator.hidden = NO;
                    [cell.imageLoadingIndicator startAnimating];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:currObject.imageHref]];
                        if (imageData) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                ACCityInfoTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [cell.imageLoadingIndicator stopAnimating];
                                    cell.imageLoadingIndicator.hidden = YES;
                                    currObject.imageData = imageData;
                                    cell.rowImageView.hidden = NO;
                                    cell.rowImageView.image = [UIImage imageWithData:currObject.imageData];
                                }
                            });
                        }else{
                            currObject.imageData = nil;
                            cell.rowImageView.image = nil;
                            cell.rowImageView.hidden = YES;
                        }
                    });
                }else{
                    [cell.imageLoadingIndicator stopAnimating];
                    cell.imageLoadingIndicator.hidden = YES;
                    cell.rowImageView.hidden = NO;
                    cell.rowImageView.image = [UIImage imageWithData:currObject.imageData];
                }
            }
        }
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infoCellNoImage"];
        if (!cell) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"infoCellNoImage"] autorelease];
        }
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:10];
        titleLabel.text = currObject.title;
        
        UILabel *descLabel = (UILabel *)[cell viewWithTag:11];
        descLabel.text = currObject.rowsDescription;
        return cell;
    }
    return nil;
}

#pragma mark - Table view data delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ACCityInfo *currObject = _dataArray[indexPath.row];
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setFont:DESCRIPTION_FONT];
    [calculationView setTextAlignment:NSTextAlignmentLeft];
    [calculationView setText:currObject.rowsDescription];
    CGSize size;
    if (currObject.imageHref.length>0) {
        size = [calculationView sizeThatFits:CGSizeMake(tableView.bounds.size.width-43.f-87.f, FLT_MAX)];//43 for accessory view plus 10x,87 is of imageview width
        if (size.height<50.f) {//to prioritize imageview height
            size.height = 55.f;
        }
    }else{
        size = [calculationView sizeThatFits:CGSizeMake(tableView.bounds.size.width-43.f, FLT_MAX)];//43 for accessoryview plus 10x
    }
    [calculationView release];
    return size.height+25.f;//25 is height for title label
}

- (void)dealloc {
    [_dataArray release];
    [_cityInfoTableView release];
    [super dealloc];
}
@end
