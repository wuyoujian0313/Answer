//
//  BaiduMapLocationResult.h
//  Answer
//
//  Created by wuyj on 16/1/4.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "NetResultBase.h"


@interface BaiduMapAdress : NSObject
@property(nonatomic, copy)NSString              *city;
@property(nonatomic, copy)NSString              *country;
@property(nonatomic, copy)NSString              *district;
@property(nonatomic, copy)NSString              *province;
@property(nonatomic, copy)NSString              *street;
@property(nonatomic, copy)NSString              *street_number;
@property(nonatomic, strong)NSNumber            *country_code;
@property(nonatomic, copy)NSString              *direction;
@property(nonatomic, copy)NSString              *distance;

@end

@interface BaiduMapLocation : NSObject
@property(nonatomic, strong)NSNumber            *lng;
@property(nonatomic, strong)NSNumber            *lat;
@end

@interface BaiduMapPOIRegions : NSObject
@property(nonatomic, copy)NSString              *direction_desc;
@property(nonatomic, copy)NSString              *name;
@end

@interface BaiduMapLocationResult : NetResultBase
@property(nonatomic, strong)BaiduMapAdress              *addressComponent;
@property(nonatomic, copy)NSString                      *business;
@property(nonatomic, strong)NSNumber                    *cityCode;
@property(nonatomic, copy)NSString                      *formatted_address;
@property(nonatomic, strong)BaiduMapLocation            *location;
@property (nonatomic, strong, getter=poiRegions) NSArray   *BaiduParserArray(poiRegions,BaiduMapPOIRegions);


@end
