//
//  LXChatVC.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/21.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXChatVC.h"
#import "LXChatManager.h"
#import "JYVoiceConvertHandle.h"

@interface LXChatVC ()<JYVoiceConvertHandleDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (nonatomic, copy) NSString *chatTopic;

@end


@implementation LXChatVC

- (void)dealloc
{
    [JYVoiceConvertHandle shareInstance].startRecord = NO;
}

+ (instancetype)chatWithRoomM:(LXRoomM *) roomM
{
    NSString *topic  = [NSString stringWithFormat:@"room/%@/voice/#",@(roomM.teamid)];
    return [self chatVCWithTopic:topic];
}

+ (instancetype)chatWithUserM:(LXUserM *) userM
{
    NSString *topic = [NSString stringWithFormat:@"user/%@/voice/#",userM.userid];
    return [self chatVCWithTopic:topic];
}

+ (instancetype)chatVCWithTopic:(NSString *)topic
{
    LXChatVC *chatVC =  (LXChatVC *)[LXUITool getVC:self storyboardName:@"Chat"];
    chatVC.chatTopic = [topic copy];
    [[LXChatManager shareManager] subscribeToTopic:topic];
    return chatVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [JYVoiceConvertHandle shareInstance].delegate = self;
    self.startBtn.layer.cornerRadius = 100;
    self.startBtn.layer.masksToBounds = YES;
}

- (IBAction)startAction
{
    self.startBtn.selected = !self.startBtn.selected;
    [JYVoiceConvertHandle shareInstance].startRecord = self.startBtn.selected;
}

- (IBAction)closeAction:(id)sender
{
    [[LXChatManager shareManager] unsubscribeTopic:self.chatTopic];
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)covertedData:(NSData *)data
{
	NSString *replace  = [NSString stringWithFormat:@"$exp/%@",kCurrentUserID];
    NSString *pushDataTopic = [self.chatTopic stringByReplacingOccurrencesOfString:@"#" withString:replace];
	
    [[LXChatManager shareManager] pushData:data toTopic:pushDataTopic];
}

@end
