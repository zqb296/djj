//
//  LXTalkingButton.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/25.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXTalkingButton.h"
#import "LXWaveLayer.h"

@interface LXTalkingButton ()

@property (nonatomic, strong)  LXWaveLayer *waveLayer;


@end

@implementation LXTalkingButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    
    CGFloat waveH = 50;
    self.waveLayer.frame = CGRectMake(0, size.height - waveH - 10, size.width, waveH);

}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
	self.waveLayer.anmatied = selected;
}

- (void)test
{
	[self.waveLayer addVal:arc4random_uniform(100)/100.];
	[self performSelector:@selector(test) withObject:self afterDelay:0.17];
}

- (LXWaveLayer *)waveLayer
{
    if (_waveLayer == nil) {
        _waveLayer = [[LXWaveLayer alloc] initWithMaxCount:80];
        [self.layer addSublayer:_waveLayer];
        _waveLayer.contentsScale = [UIScreen mainScreen].scale;
		
		[self test];
    }
    return _waveLayer;
}

@end
