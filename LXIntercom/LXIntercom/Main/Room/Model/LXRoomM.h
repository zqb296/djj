//
//  LXRoomM.h
//  LXIntercom
//
//  Created by 余志杰 on 17/4/20.
//  Copyright © 2017年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LXRoomM : NSObject

@property (nonatomic, assign) NSInteger teamid;
@property (nonatomic, assign) BOOL opened;

@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSDate *created;

@property (nonatomic, copy) NSString *memo;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;


@end
