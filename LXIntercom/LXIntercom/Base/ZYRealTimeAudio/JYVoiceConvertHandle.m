//
//  JYVoiceConvertHandle.m
//  ZYRealTimeAudio
//
//  Created by JustinYang on 16/6/14.
//  Copyright © 2016年 JustinYang. All rights reserved.
//

#define kHandleError(error)  if(error){ NSLog(@"%@",error); exit(1);}
#define kSmaple     44100
#define kDuration   0.005
#define kPlaySize   1
#define kBufferNums   3

#define kRecordDataPacketsSize   (1024)

#define kOutputBus 0
#define kInputBus  1

//存取PCM原始数据的节点
typedef struct PCMNode{
    struct PCMNode *next;
    struct PCMNode *previous;
    void        *data;
    unsigned int dataSize;
} PCMNode;

#import "JYVoiceConvertHandle.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

#include <pthread.h>

#import "JYAudioData.h"

#define kRecordDataLen  (1024*20)
typedef struct {
    NSInteger   front;
    NSInteger   rear;
    SInt16      recordArr[kRecordDataLen];
} RecordStruct;

static pthread_mutex_t  recordLock;
static pthread_cond_t   recordCond;

static pthread_mutex_t  playLock;
static pthread_cond_t   playCond;

static pthread_mutex_t  buffLock;
static pthread_cond_t   buffcond;

@interface BNRAudioQueueBuffer : NSObject
@property (nonatomic,assign) AudioQueueBufferRef buffer;
@end
@implementation BNRAudioQueueBuffer
@end

@interface JYVoiceConvertHandle ()
{
    AURenderCallbackStruct      _inputProc;
    
    AudioStreamBasicDescription _recordFormat;
    AudioStreamBasicDescription _playFormat;
    
    AudioConverterRef           _encodeConvertRef;
    
    AudioQueueRef               _playQueue;
    AudioQueueBufferRef         _queueBuf[kBufferNums];
    NSMutableArray *_buffers;
    NSMutableArray *_reusableBuffers;
}

@property (nonatomic,weak)   AVAudioSession *session;
@property (nonatomic,assign) AudioComponentInstance toneUnit;

@property (nonatomic,strong) NSMutableArray     *aacArry;
@property (atomic   ,assign ,getter=isPlaying) BOOL playing;

@end

@implementation JYVoiceConvertHandle
RecordStruct    recordStruct;

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static JYVoiceConvertHandle *handle;
    dispatch_once(&onceToken, ^{
        handle = [[JYVoiceConvertHandle alloc] init];
        [handle dataInit];
        
        [handle setupAVAudioSession];
        [handle setupRecord];
        [handle setupConvert];
        [handle setupPlay];
    });
    return handle;
}

- (void)setStartRecord:(BOOL)startRecord{
    _startRecord = startRecord;
    if (_startRecord) {
        CheckError(AudioOutputUnitStart(_toneUnit), "couldnt start audio unit");
    }else{
        CheckError(AudioOutputUnitStop(_toneUnit), "couldnt stop audio unit");
    }
}

-(void)audioSessionRouteChangeHandle:(NSNotification *)noti{
    
    [self.session setActive:YES error:nil];
    if (self.startRecord) {
        CheckError(AudioOutputUnitStart(_toneUnit), "couldnt start audio unit");
    }
}

- (void)setupAVAudioSession
{
    //对AudioSession的一些设置
    NSError *error;
    self.session = [AVAudioSession sharedInstance];
    
	[self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    kHandleError(error);
    //route变化监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChangeHandle:) name:AVAudioSessionRouteChangeNotification object:self.session];
    
    [self.session setPreferredIOBufferDuration:kDuration error:&error];
    kHandleError(error);
    [self.session setPreferredSampleRate:kSmaple error:&error];
    kHandleError(error);
    
    [self.session setActive:YES error:&error];
    kHandleError(error);
}

- (void)setupRecord
{
    _inputProc.inputProc = inputRenderTone;
    _inputProc.inputProcRefCon = (__bridge void *)(self);
    
    //    Obtain a RemoteIO unit instance
    AudioComponentDescription acd;
    acd.componentType = kAudioUnitType_Output;
    acd.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    acd.componentFlags = 0;
    acd.componentFlagsMask = 0;
    acd.componentManufacturer = kAudioUnitManufacturer_Apple;
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &acd);
    AudioComponentInstanceNew(inputComponent, &_toneUnit);
    
    UInt32 enable = 1;
    AudioUnitSetProperty(_toneUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         kInputBus,
                         &enable,
                         sizeof(enable));
    
    
    
    _recordFormat = [self getRecordAudioFormat];
    
    CheckError(AudioUnitSetProperty(_toneUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output, kInputBus,
                                    &_recordFormat, sizeof(_recordFormat)),
               "couldn't set the remote I/O unit's input client format");
    
    CheckError(AudioUnitSetProperty(_toneUnit,
                                    kAudioOutputUnitProperty_SetInputCallback,
                                    kAudioUnitScope_Output,
                                    kInputBus,
                                    &_inputProc, sizeof(_inputProc)),
               "couldnt set remote i/o render callback for input");
	
	UInt32 echoCancellation = 0;//0 开启回音消除
	OSStatus result = AudioUnitSetProperty(_toneUnit, kAUVoiceIOProperty_BypassVoiceProcessing, kAudioUnitScope_Global, kOutputBus, &echoCancellation, sizeof(echoCancellation));
	
	result = AudioUnitSetProperty(_toneUnit, kAUVoiceIOProperty_BypassVoiceProcessing, kAudioUnitScope_Global, kInputBus, &echoCancellation, sizeof(echoCancellation));
	CheckError(result,"Error setting passVoiceProcessing");
	
    CheckError(AudioUnitInitialize(_toneUnit),
               "couldn't initialize the remote I/O unit");
}

- (void)setupConvert
{
    //convertInit for PCM TO AAC
    AudioStreamBasicDescription sourceDes = [self getRecordAudioFormat];
    
    AudioStreamBasicDescription targetDes;
    memset(&targetDes, 0, sizeof(targetDes));
    targetDes.mFormatID = kAudioFormatMPEG4AAC;
    targetDes.mSampleRate = kSmaple;
    targetDes.mChannelsPerFrame = sourceDes.mChannelsPerFrame;
    
    UInt32 size = sizeof(targetDes);
    CheckError(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                      0, NULL, &size, &targetDes),
               "couldnt create target data format");
    
    //选择软件编码
    AudioClassDescription audioClassDes;
    CheckError(AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders,
                                          sizeof(targetDes.mFormatID),
                                          &targetDes.mFormatID,
                                          &size), "cant get kAudioFormatProperty_Encoders");
    UInt32 numEncoders = size/sizeof(AudioClassDescription);
    AudioClassDescription audioClassArr[numEncoders];
    CheckError(AudioFormatGetProperty(kAudioFormatProperty_Encoders,
                                      sizeof(targetDes.mFormatID),
                                      &targetDes.mFormatID,
                                      &size,
                                      audioClassArr),
               "wrirte audioClassArr fail");
    for (int i = 0; i < numEncoders; i++) {
        if (audioClassArr[i].mSubType == kAudioFormatMPEG4AAC
            && audioClassArr[i].mManufacturer == kAppleSoftwareAudioCodecManufacturer) {
            memcpy(&audioClassDes, &audioClassArr[i], sizeof(AudioClassDescription));
            break;
        }
    }
    
    CheckError(AudioConverterNewSpecific(&sourceDes, &targetDes, 1,
                                         &audioClassDes, &_encodeConvertRef),
               "cant new convertRef");
    
    size = sizeof(sourceDes);
    CheckError(AudioConverterGetProperty(_encodeConvertRef, kAudioConverterCurrentInputStreamDescription, &size, &sourceDes), "cant get kAudioConverterCurrentInputStreamDescription");
    
    size = sizeof(targetDes);
    CheckError(AudioConverterGetProperty(_encodeConvertRef, kAudioConverterCurrentOutputStreamDescription, &size, &targetDes), "cant get kAudioConverterCurrentOutputStreamDescription");
    
    UInt32 bitRate = 64000;
    size = sizeof(bitRate);
    CheckError(AudioConverterSetProperty(_encodeConvertRef,
                                         kAudioConverterEncodeBitRate,
                                         size, &bitRate),
               "cant set covert property bit rate");
    
    
    
    [self performSelectorInBackground:@selector(convertPCMToAAC) withObject:nil];
    
    _playFormat = targetDes;
}

- (void)setupPlay
{
    CheckError(AudioQueueNewOutput(&_playFormat,
                                   fillBufCallback,
                                   (__bridge void *)self,
                                   NULL,
                                   NULL,
                                   0,
                                   &(_playQueue)),
               "cant new audio queue");
    CheckError( AudioQueueSetParameter(_playQueue,
                                       kAudioQueueParam_Volume, 1.0),
               "cant set audio queue gain");
    
    for (int i = 0; i < kBufferNums; i++) {
        AudioQueueBufferRef buffer;
        CheckError(AudioQueueAllocateBuffer(_playQueue, kRecordDataPacketsSize, &buffer), "cant alloc buff");
        BNRAudioQueueBuffer *buffObj = [[BNRAudioQueueBuffer alloc] init];
        buffObj.buffer = buffer;
        [_buffers addObject:buffObj];
        [_reusableBuffers addObject:buffObj];
    }
    
    [self performSelectorInBackground:@selector(playData) withObject:nil];
}

-(void)dataInit{
    int rc;
    rc = pthread_mutex_init(&recordLock,NULL);
    assert(rc == 0);
    rc = pthread_cond_init(&recordCond, NULL);
    assert(rc == 0);
    
    rc = pthread_mutex_init(&playLock,NULL);
    assert(rc == 0);
    rc = pthread_cond_init(&playCond, NULL);
    assert(rc == 0);
    
    rc = pthread_mutex_init(&buffLock,NULL);
    assert(rc == 0);
    rc = pthread_cond_init(&buffcond, NULL);
    assert(rc == 0);
    
    
    memset(recordStruct.recordArr, 0, kRecordDataLen);
    recordStruct.front = recordStruct.rear = 0;
    
    self.aacArry = [[NSMutableArray alloc] init];
    
    _buffers = [[NSMutableArray alloc] init];
    _reusableBuffers = [[NSMutableArray alloc] init];
    
}

OSStatus inputRenderTone(
                         void *inRefCon,
                         AudioUnitRenderActionFlags 	*ioActionFlags,
                         const AudioTimeStamp 		*inTimeStamp,
                         UInt32 						inBusNumber,
                         UInt32 						inNumberFrames,
                         AudioBufferList 			*ioData)

{
    
    JYVoiceConvertHandle *THIS=(__bridge JYVoiceConvertHandle*)inRefCon;
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = NULL;
    bufferList.mBuffers[0].mDataByteSize = 0;
    OSStatus status = AudioUnitRender(THIS->_toneUnit,
                                      ioActionFlags,
                                      inTimeStamp,
                                      kInputBus,
                                      inNumberFrames,
                                      &bufferList);
    
    NSInteger lastTimeRear = recordStruct.rear;
    for (int i = 0; i < inNumberFrames; i++) {
        SInt16 data = ((SInt16 *)bufferList.mBuffers[0].mData)[i];
        recordStruct.recordArr[recordStruct.rear] = data;
        recordStruct.rear = (recordStruct.rear+1)%kRecordDataLen;
    }
    
    if ((lastTimeRear/kRecordDataPacketsSize + 1) == (recordStruct.rear/kRecordDataPacketsSize)) {
        pthread_cond_signal(&recordCond);
    }
    return status;
}


-(void)convertPCMToAAC
{
    UInt32 maxPacketSize = 0;
    UInt32 size = sizeof(maxPacketSize);
    CheckError(AudioConverterGetProperty(_encodeConvertRef,
                                         kAudioConverterPropertyMaximumOutputPacketSize,
                                         &size,
                                         &maxPacketSize),
               "cant get max size of packet");
    
    AudioBufferList *bufferList = malloc(sizeof(AudioBufferList));
    bufferList->mNumberBuffers = 1;
    bufferList->mBuffers[0].mNumberChannels = 1;
    bufferList->mBuffers[0].mData = malloc(maxPacketSize);
    bufferList->mBuffers[0].mDataByteSize = maxPacketSize;
    
    for (; ; ) {
        @autoreleasepool {
            
            
            pthread_mutex_lock(&recordLock);
            while (ABS(recordStruct.rear - recordStruct.front) < kRecordDataPacketsSize) {
                pthread_cond_wait(&recordCond, &recordLock);
            }
            pthread_mutex_unlock(&recordLock);
            
            SInt16 *readyData = (SInt16 *)calloc(kRecordDataPacketsSize, sizeof(SInt16));
            memcpy(readyData, &recordStruct.recordArr[recordStruct.front], kRecordDataPacketsSize*sizeof(SInt16));
            recordStruct.front = (recordStruct.front+kRecordDataPacketsSize)%kRecordDataLen;
            UInt32 packetSize = 1;
            
            AudioStreamPacketDescription *outputPacketDescriptions = malloc(sizeof(AudioStreamPacketDescription)*packetSize);
            bufferList->mBuffers[0].mDataByteSize = maxPacketSize;
            CheckError(AudioConverterFillComplexBuffer(_encodeConvertRef,
                                                       encodeConverterComplexInputDataProc,
                                                       readyData,
                                                       &packetSize,
                                                       bufferList,
                                                       outputPacketDescriptions),
                       "cant set AudioConverterFillComplexBuffer");
            free(outputPacketDescriptions);
            free(readyData);
            
            NSMutableData *fullData = [NSMutableData dataWithBytes:bufferList->mBuffers[0].mData length:bufferList->mBuffers[0].mDataByteSize];
            
            if ([self.delegate respondsToSelector:@selector(covertedData:)]) {
                [self.delegate covertedData:[fullData copy]];
            }
            
        }
    }
}
- (void)playWithData:(NSData *)data
{
    static int lastIndex = 0;
    pthread_mutex_lock(&playLock);
    AudioStreamPacketDescription packetDescription;
    packetDescription.mDataByteSize = (UInt32)[data length];
    packetDescription.mStartOffset = lastIndex;
    lastIndex += [data length];
    JYAudioData *audioData = [JYAudioData parsedAudioDataWithBytes:[data bytes] packetDescription:packetDescription];
    [self.aacArry addObject:audioData];
    BOOL  couldSignal = NO;
    if (self.aacArry.count%kPlaySize == 0 && self.aacArry.count > 0) {
        lastIndex = 0;
        couldSignal = YES;
    }
    pthread_mutex_unlock(&playLock);
    if (couldSignal) {
        pthread_cond_signal(&playCond);
    }
}


-(void)playData
{
    for (; ; ) {
        @autoreleasepool {
            
            NSMutableData *data = [[NSMutableData alloc] init];
            pthread_mutex_lock(&playLock);
            if (self.aacArry.count%kPlaySize != 0 || self.aacArry.count == 0)
            {
                static NSTimeInterval waitTime;
                waitTime = [[NSDate date] timeIntervalSince1970];
                pthread_cond_wait(&playCond, &playLock);
                NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
                
                if (currentTime - waitTime > 0.5) {
                    if (self.playing) {
                        AudioQueueStop(_playQueue, YES);
                        self.playing = NO;
                    }
                }
            }
            
            AudioStreamPacketDescription *paks = calloc(sizeof(AudioStreamPacketDescription), kPlaySize);
            for (int i = 0; i < kPlaySize ; i++) {
                JYAudioData *audio = [self.aacArry firstObject];
                [data appendData:audio.data];
                paks[i].mStartOffset = audio.packetDescription.mStartOffset;
                paks[i].mDataByteSize = audio.packetDescription.mDataByteSize;
                [self.aacArry removeObjectAtIndex:0];
            }
            pthread_mutex_unlock(&playLock);
            
            pthread_mutex_lock(&buffLock);
            if (_reusableBuffers.count == 0) {
                pthread_cond_wait(&buffcond, &buffLock);
            }
            
            if (!self.playing) {
                AudioQueueStart(_playQueue, nil);
                self.playing = YES;
            }
            
            BNRAudioQueueBuffer *bufferObj = [_reusableBuffers firstObject];
            [_reusableBuffers removeObject:bufferObj];
            pthread_mutex_unlock(&buffLock);
            
            memcpy(bufferObj.buffer->mAudioData,[data bytes] , [data length]);
            bufferObj.buffer->mAudioDataByteSize = (UInt32)[data length];
            CheckError(AudioQueueEnqueueBuffer(_playQueue, bufferObj.buffer, kPlaySize, paks), "cant enqueue");
            free(paks);
            
        }
    }
}

OSStatus encodeConverterComplexInputDataProc(AudioConverterRef inAudioConverter,
                                             UInt32 *ioNumberDataPackets,
                                             AudioBufferList *ioData,
                                             AudioStreamPacketDescription **outDataPacketDescription,
                                             void *inUserData)
{
    ioData->mBuffers[0].mData = inUserData;
    ioData->mBuffers[0].mNumberChannels = 1;
    ioData->mBuffers[0].mDataByteSize = kRecordDataPacketsSize * 2;
    *ioNumberDataPackets = kRecordDataPacketsSize;
    return 0;
}
static void CheckError(OSStatus error,const char *operaton){
    if (error==noErr) {
        return;
    }
    char errorString[20]={};
    *(UInt32 *)(errorString+1)=CFSwapInt32HostToBig(error);
    if (isprint(errorString[1])&&isprint(errorString[2])&&isprint(errorString[3])&&isprint(errorString[4])) {
        errorString[0]=errorString[5]='\'';
        errorString[6]='\0';
    }else{
        sprintf(errorString, "%d",(int)error);
    }
    fprintf(stderr, "Error:%s (%s)\n",operaton,errorString);
    exit(1);
}

static void fillBufCallback(void *inUserData,
                            AudioQueueRef inAQ,
                            AudioQueueBufferRef buffer){
    JYVoiceConvertHandle *THIS=(__bridge JYVoiceConvertHandle*)inUserData;
    
    for (int i = 0; i < THIS->_buffers.count; ++i) {
        if (buffer == [THIS->_buffers[i] buffer]) {
            pthread_mutex_lock(&buffLock);
            [THIS->_reusableBuffers addObject:THIS->_buffers[i]];
            pthread_mutex_unlock(&buffLock);
            pthread_cond_signal(&buffcond);
            break;
        }
    }
}

- (AudioStreamBasicDescription)getRecordAudioFormat
{
    AudioStreamBasicDescription mAudioFormat = {0};
    mAudioFormat.mSampleRate         = kSmaple;//采样率
    mAudioFormat.mFormatID           = kAudioFormatLinearPCM;//PCM采样
    mAudioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;
    mAudioFormat.mFramesPerPacket    = 1;//每个数据包多少帧
    mAudioFormat.mChannelsPerFrame   = 1;//1单声道，2立体声
    mAudioFormat.mBitsPerChannel     = 16;//语音每采样点占用位数
    mAudioFormat.mBytesPerFrame      = mAudioFormat.mBitsPerChannel*mAudioFormat.mChannelsPerFrame/8;//每帧的bytes数
    mAudioFormat.mBytesPerPacket     = mAudioFormat.mBytesPerFrame*mAudioFormat.mFramesPerPacket;//每个数据包的bytes总数，每帧的bytes数＊每个数据包的帧数
    
    return mAudioFormat;
}

#pragma mark - mutex
- (void)_mutexInit
{
    pthread_mutex_init(&buffLock, NULL);
    pthread_cond_init(&buffcond, NULL);
}

- (void)_mutexDestory
{
    pthread_mutex_destroy(&buffLock);
    pthread_cond_destroy(&buffcond);
}

- (void)_mutexWait
{
    pthread_mutex_lock(&buffLock);
    pthread_cond_wait(&buffcond, &buffLock);
    pthread_mutex_unlock(&buffLock);
}

- (void)_mutexSignal
{
    pthread_mutex_lock(&buffLock);
    pthread_mutex_unlock(&buffLock);
    pthread_cond_signal(&buffcond);
}

@end
