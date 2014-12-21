//
//  ACApiManager.h
//  AboutCanada
//
//  Created by Deepak Kumar on 21/12/14.
//  Copyright (c) 2014 Deepak Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

///Completion Handler for data Api call
typedef void (^ACApiResponseHandler) (BOOL finished, NSArray *rowsArray, NSString *pageTitle, NSError *error);

/*!
 Api Manager class holds all the service calls related code and all data connections should be handled in this class.
 */
@interface ACApiManager : NSObject

///Singleton instance of the Api manager class.Use this to access the API manager
+(ACApiManager *)sharedInstance;
-(void)loadApiDataAndUpdateTheTableViewWithCompletionHandler:(ACApiResponseHandler)completion;

@end
