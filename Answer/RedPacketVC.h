//
//  RedPacketVC.h
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "BaseVC.h"

@protocol RedSetDelegate <NSObject>
-(void)setRedNumber:(NSInteger)number;
@end

@interface RedPacketVC : BaseVC

@property (nonatomic, weak) id<RedSetDelegate> delegate;

@end
