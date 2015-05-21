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
    [self setInstrumentAupreset:InstrumentFirstType_Piano aupresent:@"Yamaha Grand Piano"];
    [self setInstrumentAupreset:InstrumentFirstType_ChromaticPercussion aupresent:@""];
    [self setInstrumentAupreset:InstrumentFirstType_Organ aupresent:@""];
    [self setInstrumentAupreset:InstrumentFirstType_Guitar aupresent:@""];
    [self setInstrumentAupreset:InstrumentFirstType_Bass aupresent:@""];
    [self setInstrumentAupreset:InstrumentFirstType_OrchestraSolo aupresent:@"String Ensemble"];
    [self setInstrumentAupreset:InstrumentFirstType_OrchestraEnsemble aupresent:@"String Ensemble"];
    [self setInstrumentAupreset:InstrumentFirstType_Brass aupresent:@"French Horn Solo+"];
    [self setInstrumentAupreset:InstrumentFirstType_Reed aupresent:@"Clarient Solo+"];
    [self setInstrumentAupreset:InstrumentFirstType_Wind aupresent:@"Flute Solo+"];
    [self setInstrumentAupreset:InstrumentFirstType_SynthLead aupresent:@""];
    [self setInstrumentAupreset:InstrumentFirstType_SynthPad aupresent:@""];
    [self setInstrumentAupreset:InstrumentFirstType_SynthSoundFX aupresent:@""];
    [self setInstrumentAupreset:InstrumentFirstType_Ethnic aupresent:@""];
    [self setInstrumentAupreset:InstrumentFirstType_Percussive aupresent:@""];
    [self setInstrumentAupreset:InstrumentFirstType_SoundEffect aupresent:@""];
    [self setInstrumentAupreset:InstrumentFirstType_DrumSounds aupresent:@""];
    
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

+ (void)setAudioUnit:(XMidiTrack*)track
{
    if (track == nil || track.eventIterator == nil){
        return;
    }
    
    if (track.eventIterator.childEvents.count == 0){
        return;
    }
    
    if (track.instrumentFirstType <= 0){
        return;
    }
    
    NSString *preset = DEFAULT_AUPRESENT;
    //SecondType
    XInstrumentAupreset *instrumentAupreset = [self getInstrumentAupreset:track.instrumentSecondType];
    if (instrumentAupreset == nil){
        //FirstType
        instrumentAupreset = [self getInstrumentAupreset:track.instrumentFirstType];
    }
    preset = instrumentAupreset.aupresentFileName;

    NSString *presetFilePath = [[NSBundle mainBundle] pathForResource:preset ofType:@"aupreset"];
    if (presetFilePath == nil || [@"" isEqual:presetFilePath]){
        [XFunction writeLog:@"No Aupreset File Find. TrackIndex:%d FirstType:%d SecondType:%d",
         track.trackIndex, track.instrumentFirstType, track.instrumentSecondType];
        return;
    }
    
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:presetFilePath];
    NSLog(@"TrackIndex:%d FirstType:%d SecondType:%d",
          track.trackIndex, track.instrumentFirstType, track.instrumentSecondType);
    
    
    XAudioUnit *audioUnit = [self getAudioUnit:track.trackIndex];
    if (audioUnit == nil){
        audioUnit = [[XAudioUnit alloc] initWithPresetURL:presetURL];
        audioUnit.trackIndex = track.trackIndex;
        [xAudioUnits addObject:audioUnit];
        return;
    }
    
    [audioUnit loadSynthFromPresetURL:presetURL];
}

+ (XAudioUnit*)getAudioUnit:(int)trackIndex{
    for(int i=0;i<xAudioUnits.count;i++){
        XAudioUnit *audioUnit = xAudioUnits[i];
        if (audioUnit.trackIndex == trackIndex){
            return audioUnit;
        }
    }
    return nil;
}

+ (void)playSound:(XMidiNoteMessage *)xMidiNoteMessage {
    if (isDisposed){
        return;
    }
    
    XAudioUnit *au = [self getAudioUnit:xMidiNoteMessage.track.trackIndex];
    
    if (au == nil){
        return;
    }
    
    Float32 velocity = xMidiNoteMessage.velocity;
    if (velocity > 100){
        //防止音过高
        velocity = 100;
    }
    
    //play
    [au startPlayingNote:xMidiNoteMessage.note withVelocity:velocity];
    
    //stop
    Float32 duration = xMidiNoteMessage.duration;
    if (duration < 0){
        duration = 0;
    }
    
    double delayInSeconds = duration*0.8;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (isDisposed){
            return;
        }
        
        [au stopPlayingNote:xMidiNoteMessage.note];
    });
    
    if (delegate != nil
        && [delegate respondsToSelector:@selector(playingSoundNote:)]) {
        [delegate playingSoundNote:xMidiNoteMessage];
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
