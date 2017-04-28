//
//  VoiceConvertHandle.h
//  BleVOIP
//
//  Created by JustinYang on 16/6/14.
//  Copyright © 2016年 JustinYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JYVoiceConvertHandleDelegate <NSObject>

-(void)covertedData:(NSData *)data;

@end

@interface JYVoiceConvertHandle : NSObject
@property (nonatomic,weak) id<JYVoiceConvertHandleDelegate> delegate;
@property (nonatomic)   BOOL    startRecord;

+ (instancetype)shareInstance;
- (void)playWithData:(NSData *)data;


@end
