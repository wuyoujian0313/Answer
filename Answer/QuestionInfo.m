//
//  QuestionInfo.m
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionInfo.h"

@implementation QuestionInfo


- (id)initWithCoder:(NSCoder*)coder {
    if (self = [super init]) {
        
        self.uuid        = [coder decodeObjectForKey:@"uuid"];
        self.uId         = [coder decodeObjectForKey:@"uId"];
        self.userId      = [coder decodeObjectForKey:@"userId"];
        
        self.mediaType        = [coder decodeObjectForKey:@"mediaType"];
        self.mediaURL         = [coder decodeObjectForKey:@"mediaURL"];
        self.thumbnail      = [coder decodeObjectForKey:@"thumbnail"];
        
        self.content        = [coder decodeObjectForKey:@"content"];
        self.longitude         = [coder decodeObjectForKey:@"longitude"];
        self.latitude      = [coder decodeObjectForKey:@"latitude"];
        
        self.address        = [coder decodeObjectForKey:@"address"];
        self.isAnonymous         = [coder decodeObjectForKey:@"isAnonymous"];
        self.hasBestAnswer      = [coder decodeObjectForKey:@"hasBestAnswer"];
        
        self.reward        = [coder decodeObjectForKey:@"reward"];
        self.updateDate         = [coder decodeObjectForKey:@"updateDate"];
        self.fenlei      = [coder decodeObjectForKey:@"fenlei"];
        self.mediaLen         = [coder decodeObjectForKey:@"mediaLen"];
        self.mark      = [coder decodeObjectForKey:@"mark"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:_uuid forKey:@"uuid"];
    [coder encodeObject:_uId forKey:@"uId"];
    [coder encodeObject:_userId forKey:@"userId"];
    
    [coder encodeObject:_mediaType forKey:@"mediaType"];
    [coder encodeObject:_mediaURL forKey:@"mediaURL"];
    [coder encodeObject:_thumbnail forKey:@"thumbnail"];
    
    [coder encodeObject:_content forKey:@"content"];
    [coder encodeObject:_longitude forKey:@"longitude"];
    [coder encodeObject:_latitude forKey:@"latitude"];
    
    [coder encodeObject:_address forKey:@"address"];
    [coder encodeObject:_isAnonymous forKey:@"isAnonymous"];
    [coder encodeObject:_hasBestAnswer forKey:@"hasBestAnswer"];
    
    [coder encodeObject:_reward forKey:@"reward"];
    [coder encodeObject:_updateDate forKey:@"updateDate"];
    [coder encodeObject:_fenlei forKey:@"fenlei"];
    [coder encodeObject:_mediaLen forKey:@"mediaLen"];
    [coder encodeObject:_mark forKey:@"mark"];
}

- (NSString *)mediaURL {
    return [NSString stringWithFormat:@"%@/%@",kNetworkServerIP,_mediaURL];
}

- (NSString *)thumbnail {
    return [NSString stringWithFormat:@"%@/%@",kNetworkServerIP,_thumbnail];
}

- (NSString *)headImage {
    return [NSString stringWithFormat:@"%@/%@",kNetworkServerIP,_headImage];
}

@end
