//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XFunction.h"
#import "XMidiSequence.h"
#import "XAudioPlayer.h"


@protocol XMidiPlayerDelegate <NSObject>
@optional
//播放进度变化 progress是一个0～1的一个小数，代表进度百分比
+ (void)progressChanged:(double)progress;
@end

@interface XMidiPlayer : NSObject <XMidiPlayerDelegate>
@property (nonatomic) id<XMidiPlayerDelegate> delegate;
@property (nonatomic) double currentBpm;
//Midi总播放时间(秒)
@property (nonatomic,readonly) double totalTime;
//Midi当前播放时间点(秒)
@property (nonatomic) double time;

//开启播放设备
+(void)xInit;
//关闭播放设备
+(void)xDispose;

//初始化MIDI URL
-(void)initMidi:(NSURL*)midiUrl;
//初始化MIDI Data
-(void)initMidiWithData:(NSData*)data;
//暂停
-(void)pause;
//播放、继续播放
-(void)play;
//重播
-(void)replay;
//获取当前播放进度 返回一个0～1的一个小数，代表进度百分比
-(double)getProgress;
//设置当前播放进度 progress是一个0～1的一个小数，代表进度百分比
-(void)setProgress:(double)progress;
//关闭播放器
-(void)closePlayer;
@end
