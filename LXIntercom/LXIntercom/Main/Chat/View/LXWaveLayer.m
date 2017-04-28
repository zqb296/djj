//
//  LXWaveLayer.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/25.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXWaveLayer.h"

@interface LXWaveLayer ()

@property (nonatomic, strong) NSMutableArray *waveValues;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) BOOL hadAdded;

@end

@implementation LXWaveLayer

- (instancetype)initWithMaxCount:(NSUInteger)maxCount
{
	if (self = [super init]) {
		self.maxCount = maxCount > 0 ? maxCount :50;
		self.anmatied = NO;
	}
	return self;
}

- (instancetype)init
{
	NSAssert(false, @"请使用initWithMaxCount");
	return nil;
}

- (void)setAnmatied:(BOOL)anmatied
{
	_anmatied = anmatied;
	self.hidden = !_anmatied;
	[self.displayLink setPaused: !_anmatied];
}

//0 - 1;
- (void)addVal:(float)val
{
	if (self.waveValues.count == self.maxCount) {
		[self.waveValues removeObjectAtIndex:0];
	}
	
	if (val < 0) {
		val = 0;
	}
	
	if (val > 1) {
		val = 1;
	}
	
	[self.waveValues addObject:@(val)];
	self.hadAdded = YES;
}

- (void)drawInContext:(CGContextRef)ctx
{
	CGFloat height = self.frame.size.height;
	CGFloat width = self.frame.size.width;
	
	CGContextTranslateCTM(ctx, 0, height);
	CGContextScaleCTM(ctx, 1, -1);

    CGFloat startX = width;
    CGFloat startY = height;
	
	CGFloat paddingX = width / (self.maxCount * 1.0);

    CGContextMoveToPoint(ctx, startX, startY);
	
	NSUInteger maxCount = self.maxCount;
	
    for (NSInteger i = maxCount - 1; i >= 0; i--)
	{
		CGFloat finalY = 0;
		if (i < self.waveValues.count) {
    		NSNumber *valF = self.waveValues[i];
			finalY = startY  * [valF floatValue];
		}else{
		
			continue;
		}
		
        startX -= paddingX;

        CGContextAddLineToPoint(ctx, startX, finalY);
    }
	
	CGContextSetLineWidth(ctx, paddingX * 0.5);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx,kCGLineCapRound);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextStrokePath(ctx);
}

- (void)displayAction
{
	if (self.hadAdded == NO) {
		[self addVal:0];
	}
	self.hadAdded = NO;
	
	[self setNeedsDisplay];
}

- (NSMutableArray *)waveValues
{
	if (_waveValues == nil) {
		_waveValues = [NSMutableArray array];
		[_waveValues addObject:@0];
	}
	return _waveValues;
}

- (CADisplayLink *)displayLink
{
	if(_displayLink == nil){
		__weak typeof(self)weakSelf = self;
		_displayLink = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(displayAction)];
		[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	}
	return _displayLink;
}

@end
