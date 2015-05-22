//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XAudioPlayer.h"

@implementation XAudioPlayer
#define DEFAULT_AUPRESENT @"Yamaha Grand Piano"

static BOOL isDisposed = false;
static NSMutableArray* xAudioUnits;
static NSMutableArray* xInstrumentAupresets;

static id<XAudioPlayerDelegate> delegate;

+(id<XAudioPlayerDelegate>)getDelegate{
    return delegate;
}

+(void)setDelegate:(id<XAudioPlayerDelegate>)d{
    delegate = d;
}

+(void)xInit{
    //设置文件打开最大数
    struct rlimit rlp;
    getrlimit(RLIMIT_NOFILE, &rlp);
    rlp.rlim_cur = 10240;
    setrlimit(RLIMIT_NOFILE, &rlp);
    
    isDisposed = false;
    xAudioUnits = [NSMutableArray array];
    //设置默认音频
    xInstrumentAupresets = [NSMutableArray array];
    //FirstType
    [self setInstrumentAupreset:InstrumentFirstType_Piano aupresent:@"Yamaha Grand Piano"];//1
    [self setInstrumentAupreset:InstrumentFirstType_ChromaticPercussion aupresent:@"Celesta"];//2
    [self setInstrumentAupreset:InstrumentFirstType_Organ aupresent:@"Full Organ"];//3
    [self setInstrumentAupreset:InstrumentFirstType_Guitar aupresent:@"Classical Acoustic Guitar"];//4
    [self setInstrumentAupreset:InstrumentFirstType_Bass aupresent:@"Muted Electric Bass"];//5
    [self setInstrumentAupreset:InstrumentFirstType_OrchestraSolo aupresent:@"String Ensemble"];//6
    [self setInstrumentAupreset:InstrumentFirstType_OrchestraEnsemble aupresent:@"String Ensemble"];//7
    [self setInstrumentAupreset:InstrumentFirstType_Brass aupresent:@"French Horns"];//8
    [self setInstrumentAupreset:InstrumentFirstType_Reed aupresent:@"Alto Sax"];//9
    [self setInstrumentAupreset:InstrumentFirstType_Wind aupresent:@"Flutes"];//10
    [self setInstrumentAupreset:InstrumentFirstType_SynthLead aupresent:@""];//11
    [self setInstrumentAupreset:InstrumentFirstType_SynthPad aupresent:@""];//12*
    [self setInstrumentAupreset:InstrumentFirstType_SynthSoundFX aupresent:@""];//13
    [self setInstrumentAupreset:InstrumentFirstType_Ethnic aupresent:@""];//14
    [self setInstrumentAupreset:InstrumentFirstType_Percussive aupresent:@""];//15
    [self setInstrumentAupreset:InstrumentFirstType_SoundEffect aupresent:@""];//16
    [self setInstrumentAupreset:InstrumentFirstType_DrumSounds aupresent:@""];//17
    
    //SecondType
    [self setInstrumentAupreset:InstrumentSecondType_OrchestralKit aupresent:@"Orchestral Kit"];
}

+ (void)xDispose{
    isDisposed = true;
}

+(void)setInstrumentAupreset:(int)instrumentType aupresent:(NSString*)aupresentFileName
{
    XInstrumentAupreset* instrumentAupreset = [self getInstrumentAupreset:instrumentType];
    if (instrumentAupreset == nil){
        instrumentAupreset = [[XInstrumentAupreset alloc] initWithInstrumentType:instrumentType AupresentFileName:aupresentFileName];
        [xInstrumentAupresets addObject:instrumentAupreset];
        return;
    }
    instrumentAupreset.aupresentFileName = aupresentFileName;
}

+(XInstrumentAupreset*)getInstrumentAupreset:(int)instrumentType
{
    for(int i=0;i<xInstrumentAupresets.count;i++){
        XInstrumentAupreset *instrumentAupreset = xInstrumentAupresets[i];
        if (instrumentAupreset.instrumentType == instrumentType){
            return instrumentAupreset;
        }
    }
    return nil;
}

+ (void)setAudioUnit:(XMidiEvent*)event
{
    if (event == nil || event.channelMessage == nil){
        return;
    }
    XMidiChannelMessage* channelMessage = event.channelMessage;
    if (channelMessage.instrumentFirstType <= 0){
        return;
    }
    
    NSString *preset = DEFAULT_AUPRESENT;
    //SecondType
    XInstrumentAupreset *instrumentAupreset = [self getInstrumentAupreset:channelMessage.instrumentSecondType];
    if (instrumentAupreset == nil){
        //FirstType
        instrumentAupreset = [self getInstrumentAupreset:channelMessage.instrumentFirstType];
    }
//    XInstrumentAupreset *instrumentAupreset = [self getInstrumentAupreset:channelMessage.instrumentFirstType];
    
    if (instrumentAupreset != nil){
        preset = instrumentAupreset.aupresentFileName;
    }
    
    if ([@"" isEqual:preset]){
        preset = DEFAULT_AUPRESENT;
    }

    NSString *presetFilePath = [[NSBundle mainBundle] pathForResource:preset ofType:@"aupreset"];
    if (presetFilePath == nil || [@"" isEqual:presetFilePath]){
        [XFunction writeLog:@"No Aupreset File Find. Channel:%d FirstType:%d SecondType:%d",
         channelMessage.channel, channelMessage.instrumentFirstType, channelMessage.instrumentSecondType];
        return;
    }
    
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:presetFilePath];
    NSLog(@"Channel:%d TimeStamp:%f FirstType:%d SecondType:%d Preset:%@",
          channelMessage.channel, event.timeStamp, channelMessage.instrumentFirstType, channelMessage.instrumentSecondType,preset);
    
    
    XAudioUnit *audioUnit = [self getAudioUnit:channelMessage.channel timeStamp:event.timeStamp];
    if (audioUnit == nil){
        audioUnit = [[XAudioUnit alloc] initWithPresetURL:presetURL];
        audioUnit.channel = channelMessage.channel;
        audioUnit.timeStamp = event.timeStamp;
        [xAudioUnits addObject:audioUnit];
        return;
    }
    
    [audioUnit loadSynthFromPresetURL:presetURL];
}

//获取au
//根据channel和时间
+ (XAudioUnit*)getAudioUnit:(int)channel timeStamp:(MusicTimeStamp)timeStamp;{
    XAudioUnit *result = nil;
    for(int i=0;i<xAudioUnits.count;i++){
        XAudioUnit *audioUnit = xAudioUnits[i];
        if (audioUnit.channel == channel
            && audioUnit.timeStamp <= timeStamp){
            result = audioUnit;
        }
    }
    return result;
}

+ (XAudioUnit*)getFirstAudioUnit:(int)channel
{
    for(int i=0;i<xAudioUnits.count;i++){
        XAudioUnit *audioUnit = xAudioUnits[i];
        if (audioUnit.channel == channel){
            return audioUnit;
        }
    }
    return nil;
}

+ (void)playSound:(XMidiEvent *)event {
    if (isDisposed
        || event.track.isMuted
        || event.noteMessage == nil){
        return;
    }
    
    XAudioUnit *au = [self getAudioUnit:event.noteMessage.channel timeStamp:event.timeStamp];
    
    if (au == nil){
        //如果根据时间没有拿到对应的au，则获取channel对应的第一个au
        au = [self getFirstAudioUnit:event.noteMessage.channel];
    }
    
    if (au == nil){
        [XFunction writeLog:@"Cant find AudioUnit by channel %d.",event.noteMessage.channel];
        return;
    }
    
    Float32 velocity = event.noteMessage.velocity;
    if (velocity > 100){
        //防止音过高
        velocity = 100;
    }
    
    //play
    [au startPlayingNote:event.noteMessage.note withVelocity:velocity];
    
    //stop
    Float32 duration = event.noteMessage.duration;
    if (duration < 0){
        duration = 0;
    }
    
    double delayInSeconds = duration*0.8;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (isDisposed){
            return;
        }
        
        [au stopPlayingNote:event.noteMessage.note];
    });
    
    if (delegate != nil
        && [delegate respondsToSelector:@selector(playingSoundNote:)]) {
        [delegate playingSoundNote:event];
    }
}

+ (void)pauseSound
{
    for(int i=0;i<xAudioUnits.count;i++){
        XAudioUnit *audioUnit = xAudioUnits[i];
        for(int j=0;j<128;j++){
            [audioUnit stopPlayingNote:j];
        }
    }
}
@end
