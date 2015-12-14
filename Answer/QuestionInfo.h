//
//  QuestionInfo.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionInfo : NSObject

@property (nonatomic, assign) NSInteger     uuid;
@property (nonatomic, copy) NSString        *uId;
@property (nonatomic, assign) NSInteger     *mediaType;
@property (nonatomic, copy) NSString        *mediaURL;
@property (nonatomic, copy) NSString        *thumbnail;
@property (nonatomic, copy) NSString        *content;
@property (nonatomic, assign) CGFloat       *longitude;
@property (nonatomic, assign) CGFloat       *latitude;
@property (nonatomic, copy) NSString        *address;
@property (nonatomic, assign) NSInteger     isAnonymous;
@property (nonatomic, assign) NSInteger     hasBestAnswer;
@property (nonatomic, copy) NSString        *reward;
@property (nonatomic, copy) NSString        *updateDate;

@end
