//
//  LXChatManager.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/21.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXChatManager.h"
#import <MQTTClient/MQTTClient.h>
#import "JYVoiceConvertHandle.h"

@interface LXChatManager ()<MQTTSessionDelegate>

@property (strong, nonatomic) MQTTSession *session;

@end

@implementation LXChatManager

+ (instancetype)shareManager
{
    static LXChatManager *chatManger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chatManger = [LXChatManager new];
        [[NSNotificationCenter defaultCenter] addObserver:chatManger selector:@selector(connect) name:kNoticeKey_UserLoginSuccessed object:nil];
    });
    return chatManger;
}

- (void)connect
{
    LXUserM *currentUser =  [LXDataManager currentUser];
    if (self.session) {
        [self.session disconnect];
        [self.session close];
    }
    
    if (currentUser) {
        MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
        transport.host = @"192.168.1.163";
        transport.port = 1883;
		
        
        self.session = [[MQTTSession alloc] init];
        self.session.transport = transport;
        
        self.session.delegate = self;
        
        self.session.clientId = currentUser.userid;
        [self.session setUserName:currentUser.userid];
        [self.session setPassword:currentUser.pwd];
        
        __weak typeof(self) weakSelf = self;
        [self.session connectWithConnectHandler:^(NSError *error) {
            _connected = !error;
            if (_connected)
            {
                //通配
                NSString *selfTopic = [NSString stringWithFormat:@"user/%@/#",currentUser.userid];
                [weakSelf subscribeToTopic:selfTopic];
            }
            kAlertMsg(_connected ?  @"连接成功" :@"连接失败");
        }];
    }else{
        kAlertMsg(@"未登录");
    }
}

- (void)subscribeToTopic:(NSString *)topic
{
    [self.session subscribeToTopic:topic atLevel:MQTTQosLevelAtMostOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){

    }];
}

- (void)unsubscribeTopic:(NSString *)topic
{
    [self.session unsubscribeTopic:topic];
}

- (void)pushData:(id)data toTopic:(NSString *)topic
{
	
	[[JYVoiceConvertHandle shareInstance] playWithData:data];
//    NSData *pushData = data;
//    if ([data isKindOfClass:[NSString class]]) {
//        pushData = [data dataUsingEncoding:NSUTF8StringEncoding];
//    }
//    
//    [self.session publishAndWaitData:pushData
//                             onTopic:topic
//                              retain:NO
//                                 qos:MQTTQosLevelAtMostOnce];
}

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
//    if ([topic containsString:@"voice"])
//    {
//        [[JYVoiceConvertHandle shareInstance] playWithData:data];
//    }
// 
}



@end
