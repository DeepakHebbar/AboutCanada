//
//  ACApiManager.m
//  AboutCanada
//
//  Created by Deepak Kumar on 21/12/14.
//  Copyright (c) 2014 Deepak Kumar. All rights reserved.
//

#import "ACApiManager.h"

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

@end
