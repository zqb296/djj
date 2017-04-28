//
//  LXChatManager.h
//  LXIntercom
//
//  Created by 余志杰 on 17/4/21.
//  Copyright © 2017年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LXRoomM.h"
#import "LXUserM.h"

@interface LXChatManager : NSObject

@property (nonatomic, assign ,readonly,getter=isConnected) BOOL connected;

+ (instancetype)shareManager;

- (void)connect;
- (void)subscribeToTopic:(NSString *)topic;
- (void)unsubscribeTopic:(NSString *)topic;
- (void)pushData:(id)data toTopic:(NSString *)topic;


@end
