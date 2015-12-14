//
//  MessageInfo.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageInfo : NSObject

@property (nonatomic, assign) NSInteger         uuid;
@property (nonatomic, copy) NSString            *uId;
@property (nonatomic, copy) NSString            *updateDate;
@property (nonatomic, assign) NSInteger         *isRead;
@property (nonatomic, copy) NSString            *content;
@property (nonatomic, copy) NSString            *reward;

@end
