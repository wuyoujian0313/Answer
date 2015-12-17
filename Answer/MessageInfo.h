//
//  MessageInfo.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageInfo : NSObject

@property (nonatomic, strong) NSNumber          *uuid;
@property (nonatomic, copy) NSString            *uId;
@property (nonatomic, strong) NSNumber          *updateDate;
@property (nonatomic, strong) NSNumber          *isRead;
@property (nonatomic, copy) NSString            *content;
@property (nonatomic, copy) NSString            *reward;

@end