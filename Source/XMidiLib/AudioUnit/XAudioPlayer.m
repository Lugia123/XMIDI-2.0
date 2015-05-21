//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XAudioPlayer.h"

@implementation XAudioPlayer
static NSMutableArray* xAudioUnits;
static id<XAudioPlayerDelegate> delegate;
static BOOL isDisposed = false;

enum
{
    InstrumentTypePiano = 1,
    InstrumentTypeChromaticPercussion = 2,
    InstrumentTypeOrgan = 3,
    InstrumentTypeGuitar = 4,
    InstrumentTypeBass = 5,
    InstrumentTypeOrchestraSolo = 6,
    InstrumentTypeOrchestraEnsemble = 7,
    InstrumentTypeBrass = 8,
    InstrumentTypeReed = 9,
    InstrumentTypeWind = 10,
    InstrumentTypeSynthLead = 11,
    InstrumentTypeSynthPad = 12,
    InstrumentTypeSynthSoundFX = 13,
    InstrumentTypeEthnic = 14,
    InstrumentTypePercussive = 15,
    InstrumentTypeSoundEffect = 16,
    InstrumentTypeDrumSounds = 17
};

enum
{
  InstrumentSubTypeOrchestralKit = 48
};

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
//    NSLog(@"before %d %d", rlp.rlim_cur, rlp.rlim_max);
    
    rlp.rlim_cur = 10240;
    setrlimit(RLIMIT_NOFILE, &rlp);
           
//    getrlimit(RLIMIT_NOFILE, &rlp);
//     NSLog(@"after %d %d", rlp.rlim_cur, rlp.rlim_max);
    
    isDisposed = false;
    xAudioUnits = [NSMutableArray array];
}

+ (void)xDispose{
    isDisposed = true;
}

+ (void)addAudioUnit:(XMidiTrack*)track
{
    if (track == nil || track.eventIterator == nil){
        return;
    }
    
    if (track.eventIterator.childEvents.count == 0){
        return;
    }
    
    NSString *instrumentType = @"";
    int type = track.instrumentType;
    switch (type) {
        case InstrumentTypePiano:
            instrumentType = @"Yamaha Grand Piano";
            break;
        case InstrumentTypeOrchestraSolo:
            instrumentType = @"String Ensemble";
            break;
        case InstrumentTypeOrchestraEnsemble:
            instrumentType = @"String Ensemble";
            break;
        case InstrumentTypeBrass:
            instrumentType = @"French Horn Solo+";
            break;
        case InstrumentTypeReed:
            instrumentType = @"Clarient Solo+";
            break;
        case InstrumentTypeWind:
            instrumentType = @"Flute Solo+";
            break;
        default:
            NSLog(@"Not Support Instrument TrackIndex:%d PatchNumber:%d P:%d",
                  track.trackIndex, track.instrumentPatchNumber, type);
            return;
            break;
    }
    
    //针对性子类
    switch (track.instrumentPatchNumber) {
        case InstrumentSubTypeOrchestralKit:
            instrumentType = @"Orchestral Kit";
            break;
    }

    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:instrumentType ofType:@"aupreset"]];
    NSLog(@"TrackIndex:%d PatchNumber:%d P:%d",
          track.trackIndex, track.instrumentPatchNumber, type);
    
    XAudioUnit *audioUnit = [[XAudioUnit alloc] initWithPresetURL:presetURL];
    audioUnit.trackIndex = track.trackIndex;
    audioUnit.instrumentType = type;
    [xAudioUnits addObject:audioUnit];
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
    
//    NSLog(@"trackIndex:%d note:%d duration:%f",
//          xMidiNoteMessage.track.instrumentType, xMidiNoteMessage.note, xMidiNoteMessage.duration);
    
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
@end
