//
//  LXWaveLayer.h
//  LXIntercom
//
//  Created by 余志杰 on 17/4/25.
//  Copyright © 2017年 LX. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface LXWaveLayer : CALayer

@property (nonatomic, assign) BOOL anmatied;

- (instancetype)initWithMaxCount:(NSUInteger)maxCount;
//0 - 1;
- (void)addVal:(float)val;

@end
