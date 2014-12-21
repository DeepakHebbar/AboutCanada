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
                if (currObject.imageData == nil) {
                    cell.rowImageView.image = nil;
                    cell.rowImageView.hidden = YES;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:currObject.imageHref]];
                        if (imageData) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                ACCityInfoTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
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
    
    NSDictionary *titleFontDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:TITLE_FONT,NSFontAttributeName, nil];
    NSDictionary *descFontDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:DESCRIPTION_FONT,NSFontAttributeName, nil];
    
    CGFloat titleHeight = [currObject.title boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, tableView.bounds.size.height) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:titleFontDictionary context:nil].size.height;
    [titleFontDictionary release];
    if (currObject.imageHref.length>0) {
        CGFloat descHeight = [currObject.rowsDescription boundingRectWithSize:CGSizeMake(190.f, tableView.bounds.size.height) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:descFontDictionary context:nil].size.height;
        [descFontDictionary release];
        CGFloat cellHeight = (titleHeight+descHeight)>70.f?(titleHeight+descHeight):(descHeight+CELL_PADDING);
        return cellHeight;
    }else{
        CGFloat descHeight = [currObject.rowsDescription boundingRectWithSize:CGSizeMake(tableView.bounds.size.width-33.f, tableView.bounds.size.height) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:descFontDictionary context:nil].size.height;
        [descFontDictionary release];
        CGFloat cellHeight = (titleHeight+descHeight)>60.f?(titleHeight+descHeight):(descHeight+CELL_PADDING+10.f);
        return cellHeight;
    }
}

- (void)dealloc {
    [_dataArray release];
    [_cityInfoTableView release];
    [super dealloc];
}
@end
