//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "XAudioUnit.h"
#import "XMidiNoteMessage.h"
#import "XMidiTrack.h"
#import "XInstrumentAupreset.h"


@class XMidiNoteMessage;
@class XMidiTrack;

enum
{
    InstrumentFirstType_Piano = 10001,
    InstrumentFirstType_ChromaticPercussion = 10002,
    InstrumentFirstType_Organ = 10003,
    InstrumentFirstType_Guitar = 10004,
    InstrumentFirstType_Bass = 10005,
    InstrumentFirstType_OrchestraSolo = 10006,
    InstrumentFirstType_OrchestraEnsemble = 10007,
    InstrumentFirstType_Brass = 10008,
    InstrumentFirstType_Reed = 10009,
    InstrumentFirstType_Wind = 10010,
    InstrumentFirstType_SynthLead = 10011,
    InstrumentFirstType_SynthPad = 10012,
    InstrumentFirstType_SynthSoundFX = 10013,
    InstrumentFirstType_Ethnic = 10014,
    InstrumentFirstType_Percussive = 10015,
    InstrumentFirstType_SoundEffect = 10016,
    InstrumentFirstType_DrumSounds = 10017
};

enum
{
    InstrumentSecondType_OrchestralKit = 48
};

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

//根据track生成AudioUnit
+ (void)setAudioUnit:(XMidiTrack*)track;

//设置音频
+ (void)setInstrumentAupreset:(int)instrumentType aupresent:(NSString*)aupresentFileName;

//播放声音
+ (void)playSound:(XMidiNoteMessage *)xMidiNoteMessage;

//停止声音
+ (void)pauseSound;
@end

