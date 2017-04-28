//
//  LXContactService.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/20.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXContactService.h"

@implementation LXContactService

+ (void)getContactsResult:(LXServiceResult)serviceResult
{
    NSString *url = @"user";
    [self getUrl:url result:serviceResult];
}

@end
