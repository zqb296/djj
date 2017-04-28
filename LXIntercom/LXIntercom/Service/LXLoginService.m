//
//  LXLoginService.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/20.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXLoginService.h"

@implementation LXLoginService

+ (void)loginWithUserName:(NSString *)userName passWord:(NSString *)passWord result:(LXServiceResult)serviceResult
{
    userName = userName? : @"";
    passWord = passWord? : @"";

    NSString *url = @"user/login";
    [self postUrl:url params:@{@"userid":userName,@"pwd":passWord} result:serviceResult];
}

@end
