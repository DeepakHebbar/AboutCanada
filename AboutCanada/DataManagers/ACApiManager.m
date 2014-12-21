//
//  ACApiManager.m
//  AboutCanada
//
//  Created by Deepak Kumar on 21/12/14.
//  Copyright (c) 2014 Deepak Kumar. All rights reserved.
//

#import "ACApiManager.h"
#import "ACCityInfo.h"

#define API_URL @"https://dl.dropboxusercontent.com/u/746330/facts.json"

@interface ACApiManager()
@property (nonatomic, retain) __block NSMutableArray *dataRowsArray;
@end

@implementation ACApiManager

+ (ACApiManager *)sharedInstance{
    __strong static ACApiManager *_sharedObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)loadApiDataAndUpdateTheTableViewWithCompletionHandler:(ACApiResponseHandler)completion{
    _dataRowsArray = [NSMutableArray new];
   
    NSURL *apiURL = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:apiURL];
    NSURLResponse *urlResponse;
    NSError *error;
    NSData *apiData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
    [urlRequest release];
    NSString *responseDataStr = [[NSString alloc] initWithData:apiData encoding:NSASCIIStringEncoding];
    NSData *jsonData = [responseDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [responseDataStr release];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    NSArray *dataRows = json[@"rows"];
    [dataRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!([obj[@"title"] isEqual:[NSNull null]] &&  [obj[@"description"] isEqual:[NSNull null]] && [obj[@"imageHref"] isEqual:[NSNull null]])) {
            ACCityInfo *rowsObj = [[ACCityInfo alloc]init];
            rowsObj.title = ([obj[@"title"] isEqual:[NSNull null]])?@"":obj[@"title"];
            rowsObj.rowsDescription = ([obj[@"description"] isEqual:[NSNull null]])?@"":obj[@"description"];
            rowsObj.imageHref = ([obj[@"imageHref"] isEqual:[NSNull null]])?@"":obj[@"imageHref"];
            [_dataRowsArray addObject:rowsObj];
            [rowsObj release];
        }
    }];
    completion(YES, _dataRowsArray,json[@"title"],nil);
}

@end
