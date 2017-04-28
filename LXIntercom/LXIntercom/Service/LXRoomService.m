//
//  LXRoomService.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/20.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXRoomService.h"

static NSString *kUrl = @"team";


@implementation LXRoomService

+ (void)getRoomsResult:(LXServiceResult)serviceResult
{
    [self getUrl:kUrl result:serviceResult];
}

+ (void)createRoomPrams:(NSDictionary *)params result:(LXServiceResult)serviceResult
{
	[self postUrl:kUrl params:params result:serviceResult];
}

@end
