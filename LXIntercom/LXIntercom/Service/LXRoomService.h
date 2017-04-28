//
//  LXRoomService.h
//  LXIntercom
//
//  Created by 余志杰 on 17/4/20.
//  Copyright © 2017年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXServiceManager.h"

@interface LXRoomService : LXServiceManager

+ (void)getRoomsResult:(LXServiceResult)serviceResult;
+ (void)createRoomPrams:(NSDictionary *)params result:(LXServiceResult)serviceResult;

@end
