//
//  DeviceInfo.m
//  CommonProject
//
//  Created by wuyoujian on 16/5/13.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#import "DeviceInfo.h"
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

@interface DeviceInfo(InternalMethod)
@end

@implementation DeviceInfo

//是否越狱
+ (BOOL)isJailBreak {
    BOOL isjb = NO;
    
    FILE *f = NULL;
    if ((f = fopen("/bin/bash", "r")) ||
        (f = fopen("/Applications/Cydia.app", "r")) ||
        (f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")) ||
        (f = fopen("/usr/sbin/sshd", "r")) ||
        (f = fopen("/etc/apt", "r"))) {
        isjb = YES;
    }
    
    if (f != NULL) {
        fclose(f);
        f = NULL;
    }
    return isjb;
}

+ (BOOL) isEmulator {
    if (MODEL_IPHONE_SIMULATOR == [DeviceInfo detectModel]) {
        return TRUE;
    }

    return FALSE;
}

+ (BOOL)isOS7 {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isOS8 {
#ifdef NSFoundationVersionNumber_iOS_7_1
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        return NO;
    } else {
        return YES;
    }
#else
    return NO;
#endif
}

+ (BOOL)isOS9 {
#ifdef NSFoundationVersionNumber_iOS_8_3
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_8_3) {
        return NO;
    } else {
        return YES;
    }
#else
    return NO;
#endif
}

+ (BOOL)isRetinaScreen {
    return ([UIScreen instancesRespondToSelector:@selector(scale)]?(2 <= [[UIScreen mainScreen] scale]):NO);
}

+ (CGFloat)screenScale {
    return [[UIScreen mainScreen] scale];
}

+ (NSString*)getSystemVersion {
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSString* strVer = [NSString stringWithFormat:@"%f",ver];
    return strVer;
}

+ (CGSize)getScreenSize {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return screenSize;
}

+ (CGFloat)screenWidth {
    return [self getScreenSize].width;
}
+ (CGFloat)screenHeight {
    return [self getScreenSize].height;
}


+(CGSize)getApplicationSize {
    CGSize appSize = [UIScreen mainScreen].applicationFrame.size;
    return appSize;
}


+ (char *)platformCStr {
    static char *machine = NULL;
    if (machine == NULL) {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        machine = (char*)malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
    }
    return machine;
}

+ (NSString *)platform {
    char *machine = [DeviceInfo platformCStr];
    
    NSString *platform = [NSString stringWithUTF8String:machine];
    
    return platform;
}

+ (DeviceInfo_Model)detectModel {
    NSString *platform = [DeviceInfo platform];
    
    if ([platform isEqualToString:@"iPhone1,1"])
        return MODEL_IPHONE;
    
    if ([platform isEqualToString:@"iPhone1,2"])
        return MODEL_IPHONE_3G;
    
    if ([platform isEqualToString:@"iPhone2,1"])
        return MODEL_IPHONE_3GS;
    
    if ([platform isEqualToString:@"iPhone3,1"])
        return MODEL_IPHONE_4G;
    
    if ([platform isEqualToString:@"iPhone3,2"])
        return MODEL_IPHONE_4G_REV_A;
    
    if ([platform isEqualToString:@"iPhone3,3"])
        return MODEL_IPHONE_4G_CDMA;
    
    if ([platform isEqualToString:@"iPhone4,1"])
        return MODEL_IPHONE_4GS;
    
    if ([platform isEqualToString:@"iPhone5,1"])
        return MODEL_IPHONE_5G_A1428;
    
    if ([platform isEqualToString:@"iPhone5,2"])
        return MODEL_IPHONE_5G_A1429;
    
    if ([platform isEqualToString:@"iPhone5,3"])
        return MODEL_IPHONE_5C;
    
    if ([platform isEqualToString:@"iPhone5,4"])
        return MODEL_IPHONE_5C;
    
    if ([platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"])
        return MODEL_IPHONE_5S;
    
    if ([platform isEqualToString:@"iPhone7,2"])
        return MODEL_IPHONE_6;
    
    if ([platform isEqualToString:@"iPhone7,1"])
        return MODEL_IPHONE_6PLUS;
    
    if ([platform isEqualToString:@"iPhone8,1"])
        return MODEL_IPHONE_6S;
    
    if ([platform isEqualToString:@"iPhone8,2"])
        return MODEL_IPHONE_6SPLUS;
    
    if ([platform isEqualToString:@"iPod1,1"])
        return MODEL_IPOD_TOUCH;
    
    if ([platform isEqualToString:@"iPod2,1"])
        return MODEL_IPOD_TOUCH_2G;
    
    if ([platform isEqualToString:@"iPod3,1"])
        return MODEL_IPOD_TOUCH_3G;
    
    if ([platform isEqualToString:@"iPod4,1"])
        return MODEL_IPOD_TOUCH_4G;
    
    if ([platform isEqualToString:@"iPad1,1"])
        return MODEL_IPAD;
    
    if ([platform isEqualToString:@"i386"])
        return MODEL_IPHONE_SIMULATOR;
    
    if ([platform isEqualToString:@"x86_64"])
        return MODEL_IPHONE_SIMULATOR;
    
    return MODEL_UNKNOWN;
}


+ (uint)detectDevice {
    NSString *model= [[UIDevice currentDevice] model];
    
    // Some iPod Touch return "iPod Touch", others just "iPod"
    NSString *iPodTouch = @"iPod Touch";
    NSString *iPodTouchLowerCase = @"iPod touch";
    NSString *iPodTouchShort = @"iPod";
    NSString *iPad = @"iPad";
    
    NSString *iPhoneSimulator = @"iPhone Simulator";
    
    uint detected = MODEL_UNKNOWN;
    
    if ([model compare:iPhoneSimulator] == NSOrderedSame)
    {
        // iPhone simulator
        detected = MODEL_IPHONE_SIMULATOR;
    }
    else if ([model compare:iPad] == NSOrderedSame)
    {
        // iPad
        detected = MODEL_IPAD;
    }
    else if ([model compare:iPodTouch] == NSOrderedSame)
    {
        // iPod Touch
        detected = MODEL_IPOD_TOUCH;
    }
    else if ([model compare:iPodTouchLowerCase] == NSOrderedSame)
    {
        // iPod Touch
        detected = MODEL_IPOD_TOUCH;
    }
    else if ([model compare:iPodTouchShort] == NSOrderedSame)
    {
        // iPod Touch
        detected = MODEL_IPOD_TOUCH;
    }
    else
    {
        // Could be an iPhone V1 or iPhone 3G (model should be "iPhone")
        struct utsname u;
        
        // u.machine could be "i386" for the simulator, "iPod1,1" on iPod Touch, "iPhone1,1" on iPhone V1 & "iPhone1,2" on iPhone3G
        uname(&u);
        
        if (!strcmp(u.machine, "iPhone1,1"))
        {
            detected = MODEL_IPHONE;
        }
        else if (!strcmp(u.machine, "iPhone1,2"))
        {
            detected = MODEL_IPHONE_3G;
        }
        else if (!strcmp(u.machine, "iPhone2,1"))
        {
            detected = MODEL_IPHONE_3GS;
        }
        else if (!strcmp(u.machine, "iPhone3,1"))
        {
            detected = MODEL_IPHONE_4G;
        }
        else if (!strcmp(u.machine, "iPhone3,1"))
        {
            detected = MODEL_IPHONE_4G;
        }
        else if (!strcmp(u.machine, "iPhone3,2"))
        {
            detected = MODEL_IPHONE_4G_REV_A;
        }
        else if (!strcmp(u.machine, "iPhone3,3"))
        {
            detected = MODEL_IPHONE_4G_CDMA;
        }
        else if (!strcmp(u.machine, "iPhone4,1"))
        {
            detected = MODEL_IPHONE_4GS;
        }
        else if (!strcmp(u.machine, "iPhone5,1"))
        {
            detected = MODEL_IPHONE_5G_A1428;
        }
        else if (!strcmp(u.machine, "iPhone5,2"))
        {
            detected = MODEL_IPHONE_5G_A1429;
        }
        else if (!strcmp(u.machine, "iPhone5,3"))
        {
            detected = MODEL_IPHONE_5C;
        }
        else if (!strcmp(u.machine, "iPhone5,4"))
        {
            detected = MODEL_IPHONE_5C;
        }
        else if (!strcmp(u.machine, "iPhone6,1"))
        {
            detected = MODEL_IPHONE_5S;
        }
        else if (!strcmp(u.machine, "iPhone7,2"))
        {
            detected = MODEL_IPHONE_6;
        }
        else if (!strcmp(u.machine, "iPhone7,1"))
        {
            detected = MODEL_IPHONE_6PLUS;
        }
        else if (!strcmp(u.machine, "iPhone8,1"))
        {
            detected = MODEL_IPHONE_6S;
        }
        else if (!strcmp(u.machine, "iPhone8,2"))
        {
            detected = MODEL_IPHONE_6SPLUS;
        }
    }
    
    return detected;
}

+ (NSString *)returnDeviceName:(BOOL)ignoreSimulator
{
    NSString *returnValue = @"Unknown";
    
    switch ([DeviceInfo detectDevice])
    {
        case MODEL_IPHONE_SIMULATOR:
            if (ignoreSimulator)
            {
                returnValue = @"iPhone 4G";
            } else
            {
                returnValue = @"iPhone Simulator";
            }
            break;
            
        case MODEL_IPOD_TOUCH:
            returnValue = @"iPod Touch";
            break;
            
        case MODEL_IPHONE:
            returnValue = @"iPhone";
            break;
            
        case MODEL_IPHONE_3G:
            returnValue = @"iPhone 3G";
            break;
            
        case MODEL_IPHONE_3GS:
            returnValue = @"iPhone 3GS";
            break;
            
        case MODEL_IPHONE_4G:
            returnValue = @"iPhone 4G";
            break;
            
        case MODEL_IPHONE_4G_REV_A:
            returnValue = @"iPhone 4G Rev A";
            break;
            
        case MODEL_IPHONE_4G_CDMA:
            returnValue = @"iPhone 4G CDMA";
            break;
            
        case MODEL_IPHONE_4GS:
            returnValue = @"iPhone 4GS";
            break;
            
        case MODEL_IPHONE_5G_A1428:
            returnValue = @"iPhone 5G A1428";
            break;
            
        case MODEL_IPHONE_5G_A1429:
            returnValue = @"iPhone 5G A1429";
            break;
            
        case MODEL_IPHONE_5C:
            returnValue = @"iPhone 5C";
            break;
            
        case MODEL_IPHONE_5S:
            returnValue = @"iPhone 5S";
            break;
            
        case MODEL_IPHONE_6:
            returnValue = @"iPhone 6";
            break;
            
        case MODEL_IPHONE_6PLUS:
            returnValue = @"iPhone 6 Plus";
            break;
            
        case MODEL_IPHONE_6S:
            returnValue = @"iPhone 6S";
            break;
            
        case MODEL_IPHONE_6SPLUS:
            returnValue = @"iPhone 6S Plus";
            break;
            
        case MODEL_IPAD:
            returnValue = @"";
            
        default:
            break;
    }
    
    return returnValue;
}

+ (NSString *)platformString {
    
    NSString *platform = [DeviceInfo platform];
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6S";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6S Plus";
    
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}


+ (NSInteger) getSystemTime {
    NSDate * senddate=[NSDate date];
    //获得系统日期
    NSCalendar * cal            = [NSCalendar currentCalendar];
    NSUInteger unitFlags        =  NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year  = [conponent year];
    NSInteger month = [conponent month];
    NSInteger day   = [conponent day];

    NSInteger systemTime = year * 10000 + month * 100 + day;
    return systemTime;
}

+ (NSString*) getSystemTimeStamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"%f", a];
}

+ (NSString*)getSoftVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString*)kCFBundleVersionKey];
}

+ (NSString*)getHomePath {
    return NSHomeDirectory();
}

+ (NSString*)getDocumentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString*)getCachePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return  [paths objectAtIndex:0];
}

+ (NSString*)getTmpPath {
    return NSTemporaryDirectory();
}

+ (NSInteger)navigationBarHeight {
    return ([[self class] isOS7] ? 64 : 44);
}

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_WIFI1       @"en1"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

// 摘自：http://stackoverflow.com/questions/7072989/iphone-ipad-osx-how-to-get-my-ip-address-programmatically

+ (NSString *)getIPAddress:(BOOL)preferIPv4 {
    
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI1 @"/" IP_ADDR_IPv4,  IOS_CELLULAR @"/" IP_ADDR_IPv4 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI1 @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
