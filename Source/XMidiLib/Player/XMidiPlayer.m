//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XMidiPlayer.h"

@implementation XMidiPlayer

float DELAY_IN_SECONDS = 0.001;
float BASICS_BPM = 60.0;

float currentMusitTime;
float currentTimeStamp;
double lastUpdateTime;
XMidiSequence* midiSequence;
BOOL isPaused;
BOOL isClosed;

+(void)xInit{
    [XAudioPlayer xInit];
}

+(void)xDispose{
    [XAudioPlayer pauseSound];
    [XAudioPlayer xDispose];
}

-(id)init{
    if(self = [super init]){
        isClosed = false;
        [self playTimer];
    }
    return self;
}

- (void)initMidi:(NSURL*)midiUrl{
    isPaused = true;
    currentMusitTime = 0;
    currentTimeStamp = 0;
    self.currentBpm = 100;
    midiSequence = [[XMidiSequence alloc] init:midiUrl];
}

-(void)initMidiWithData:(NSData*)data{
    isPaused = true;
    currentMusitTime = 0;
    currentTimeStamp = 0;
    self.currentBpm = 100;
    midiSequence = [[XMidiSequence alloc] initWithData:data];
}

-(void)closePlayer{
    [XAudioPlayer pauseSound];
    isClosed = true;
    isPaused = true;
    midiSequence = NULL;
}

-(void)pause{
    [XAudioPlayer pauseSound];
    isPaused = true;
}

-(void)play{
    isPaused = false;
    lastUpdateTime = [[NSDate date] timeIntervalSince1970];
}

-(void)replay{
    [XAudioPlayer pauseSound];
    [self setProgress:0];
}

-(float)totalTime{
    if (midiSequence == NULL){
        return 0;
    }
    return midiSequence.musicTotalTime;
}

-(float)time{
    if (midiSequence == NULL){
        return 0;
    }
    return currentMusitTime;
}

-(void)setTime:(float)newValue{
    if (midiSequence == NULL){
        return;
    }
    
    float progress = newValue / midiSequence.musicTotalTime;
    [self setProgress:progress];
}

-(float)timeStamp{
    if (midiSequence == NULL){
        return 0;
    }
    return currentTimeStamp;
}

-(void)setTimeStamp:(float)newValue{
    if (midiSequence == NULL){
        return;
    }
    
    if (midiSequence.tracks.count <= 0){
        return;
    }
    
    isPaused = true;

    float maxTime = midiSequence.length;
    currentMusitTime = 0;
    currentTimeStamp = 0;
    while (currentTimeStamp < maxTime) {
        float bpm = [midiSequence getTempoBpmInTimeStamp:currentTimeStamp];
        if (currentTimeStamp >= newValue){
            break;
        }
        currentTimeStamp += DELAY_IN_SECONDS;
        currentMusitTime += DELAY_IN_SECONDS / bpm * BASICS_BPM;
        
        currentTimeStamp = [[[NSString alloc]initWithFormat:@"%.3f",currentTimeStamp] floatValue];
    }
    
    [self resetPlayTag];
    
    isPaused = false;
}

-(float)getProgress{
    return currentMusitTime / midiSequence.musicTotalTime;
}

-(void)setProgress:(float)progress{
    if (midiSequence == NULL){
        return;
    }
    
    if (midiSequence.tracks.count <= 0){
        return;
    }
    
    isPaused = true;
    float p = progress;
    if (p < 0){
        p = 0;
    }
    
    if (p > 1){
        p = 1;
    }
    
    float maxTime = midiSequence.musicTotalTime * p;
    currentMusitTime = 0;
    currentTimeStamp = 0;
    while (currentMusitTime < maxTime) {
        float bpm = [midiSequence getTempoBpmInTimeStamp:currentTimeStamp];
        currentTimeStamp += DELAY_IN_SECONDS / BASICS_BPM * bpm;
        currentMusitTime += DELAY_IN_SECONDS;
        
        currentMusitTime = [[[NSString alloc]initWithFormat:@"%.3f",currentMusitTime] floatValue];
    }
    
    //重置播放标示
    [self resetPlayTag];
    
    isPaused = false;
}

//重置播放标示
-(void)resetPlayTag
{
    currentTimeStamp = [[[NSString alloc]initWithFormat:@"%.3f",currentTimeStamp] floatValue];
    for (int i = 0; i< midiSequence.tracks.count; i++) {
        XMidiTrack* track = midiSequence.tracks[i];
        track.playEventIndex = 0;
        if (track.eventIterator.noteMessageEvents.count <= 0){
            continue;
        }
        for (int index = 0; index < track.eventIterator.noteMessageEvents.count; index ++) {
            XMidiNoteMessageEvent* event = track.eventIterator.noteMessageEvents[index];
            
            event.isPlayed = (int)(currentTimeStamp * 1000) >= (int)(event.timeStamp * 1000) && currentTimeStamp != 0;
            if (event.isPlayed){
                track.playEventIndex = index;
            }
        }
    }
}

-(void)playTimer
{
    double timeSinceLast = [[NSDate date] timeIntervalSince1970] - lastUpdateTime;
    lastUpdateTime = [[NSDate date] timeIntervalSince1970];
    
    float delayInSeconds = 1 / 60;
    if (!isPaused && currentMusitTime < midiSequence.musicTotalTime){
        //按bpm速率播放
        self.currentBpm = [midiSequence getTempoBpmInTimeStamp:currentTimeStamp];
        currentTimeStamp += timeSinceLast / BASICS_BPM * self.currentBpm;
        currentMusitTime += timeSinceLast;
        if (currentMusitTime > midiSequence.musicTotalTime){
            currentMusitTime = midiSequence.musicTotalTime;
        }
        [self playSound];
        if (self.delegate != nil
            && [self.delegate respondsToSelector:@selector(progressChanged:)]) {
            [self.delegate progressChanged:[self getProgress]];
        }
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (!isClosed){
            [self playTimer];
        }
    });
}

-(void)playSound{
    if (midiSequence == NULL){
        return;
    }
    
    if (midiSequence.tracks.count <= 0){
        return;
    }
    
    for (int i = 0; i<midiSequence.tracks.count; i++) {
        XMidiTrack* track = midiSequence.tracks[i];
        for (int index = track.playEventIndex; index<track.playEventIndex + 10; index++) {
            if (index < track.playEventIndex || index >= track.eventIterator.noteMessageEvents.count){
                continue;
            }
            
            XMidiNoteMessageEvent* event = track.eventIterator.noteMessageEvents[index];
            if ((int)(currentTimeStamp * 1000) >= (int)(event.timeStamp * 1000)
                && !event.isPlayed
                && !track.isMuted)
            {
                track.playEventIndex = index;
                event.isPlayed = true;
                
//                NSString *result = [NSString stringWithFormat:@""];
//                result = [result stringByAppendingFormat:@"\nTimeStamp:%f  Channel:%d  Note:%d  NoteNumber:%@  Octave:%d  Velocity:%d  Duration:%f",
//                          event.timeStamp,
//                          event.channel,
//                          event.note,
//                          event.noteNumber,
//                          event.octave,
//                          event.velocity,
//                          event.duration];
//                NSLog(@"%@",result);
                [XAudioPlayer playSoundByEvent:event];
            }
        }
    }
}

-(void)gotoNoteByTrackIndex:(int)trackIndex NodeIndex:(int)noteIndex
{
    if (midiSequence == NULL){
        return;
    }
    
    if (midiSequence.tracks.count <= 0
        || trackIndex >= midiSequence.tracks.count){
        return;
    }
    
    isPaused = true;
    
    //跳转到想要播放的那个音符的前一个音符时间
    noteIndex = noteIndex - 1;
    if (noteIndex < 0){
        noteIndex = 0;
    }
    
    XMidiTrack* track = midiSequence.tracks[trackIndex];
    if (track.eventIterator.noteMessageEvents.count <= 0
        || noteIndex >= track.eventIterator.noteMessageEvents.count){
        isPaused = false;
        return;
    }
    
    XMidiNoteMessageEvent* event = track.eventIterator.noteMessageEvents[noteIndex];
    if (event.timeStamp <= 0){
        isPaused = false;
        return;
    }
    
    self.timeStamp = event.timeStamp;
    
    isPaused = false;
}

#pragma mark - Description
- (NSString *)midiDescription
{
    if (midiSequence != nil){
        return [midiSequence description];
    }
    
    return @"";
}
@end