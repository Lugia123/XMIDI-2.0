//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "XAudioUnit.h"
#import "XMidiNoteMessage.h"
#import "XMidiTrack.h"

#define MAX_BUFFERS 128

@class XMidiNoteMessage;
@class XMidiTrack;

@protocol XAudioPlayerDelegate <NSObject>
@optional
+ (void)playingSoundNote:(XMidiNoteMessage *)xMidiNoteMessage;
@end

@interface XAudioPlayer : NSObject <XAudioPlayerDelegate>

+(id<XAudioPlayerDelegate>)getDelegate;
+(void)setDelegate:(id<XAudioPlayerDelegate>)d;

//初始化
+ (void)xInit;
//释放资源
+ (void)xDispose;
+ (void)addAudioUnit:(XMidiTrack*)track;

//播放声音
+ (void)playSound:(XMidiNoteMessage *)xMidiNoteMessage;
@end

