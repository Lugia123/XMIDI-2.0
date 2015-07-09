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
+ (void)progressChanged:(float)progress;
@end

@interface XMidiPlayer : NSObject <XMidiPlayerDelegate>
@property (nonatomic) id<XMidiPlayerDelegate> delegate;
@property (nonatomic) float currentBpm;
//Midi总播放时间(秒)（真实时间）
@property (nonatomic,readonly) float totalTime;
//Midi当前播放时间点(秒)（真实时间）
@property (nonatomic) float time;
//Midi当前标准时间点(秒)（标准时间）
@property (nonatomic) float timeStamp;
//当前播放进度 返回一个0～1的一个小数，代表进度百分比
@property (nonatomic) float progress;

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
//跳转到某个音符开始播放
-(void)gotoNoteByTrackIndex:(int)trackIndex NodeIndex:(int)noteIndex;
//关闭播放器
-(void)closePlayer;
//Midi信息
- (NSString *)midiDescription;
@end
