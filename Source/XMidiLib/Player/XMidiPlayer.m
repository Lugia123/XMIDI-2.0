//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XMidiPlayer.h"

@implementation XMidiPlayer
double currentMusitTime;
XMidiSequence* midiSequence;
BOOL isPaused;
BOOL isPlayTimerEnabled;
double playTimeStamp;
double lastUpdateTime;

+(void)xInit{
    [XAudioPlayer xInit];
}

+(void)xDispose{
    [XAudioPlayer pauseSound];
    [XAudioPlayer xDispose];
}

-(id)init{
    if(self = [super init]){
        isPlayTimerEnabled = true;
        [self playTimer];
    }
    return self;
}

- (void)initMidi:(NSURL*)midiUrl{
    isPaused = true;
    currentMusitTime = 0;
    playTimeStamp = 0;
    self.currentBpm = 100;
    midiSequence = [[XMidiSequence alloc] init:midiUrl];
}

-(void)initMidiWithData:(NSData*)data{
    isPaused = true;
    currentMusitTime = 0;
    playTimeStamp = 0;
    self.currentBpm = 100;
    midiSequence = [[XMidiSequence alloc] initWithData:data];
}

-(void)closePlayer{
    [XAudioPlayer pauseSound];
    isPlayTimerEnabled = false;
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

-(double)totalTime{
    if (midiSequence == NULL){
        return 0;
    }
    return midiSequence.musicTotalTime;
}

-(double)time{
    if (midiSequence == NULL){
        return 0;
    }
    return currentMusitTime;
}

-(void)setTime:(double)newValue{
    if (midiSequence == NULL){
        return;
    }
    
    double progress = newValue / midiSequence.musicTotalTime;
    [self setProgress:progress];
}

-(double)getProgress{
    return currentMusitTime / midiSequence.musicTotalTime;
}

-(void)setProgress:(double)progress{
    if (midiSequence == NULL){
        return;
    }
    
    if (midiSequence.tracks.count <= 0){
        return;
    }
    
    isPaused = true;
    double p = progress;
    if (p < 0){
        p = 0;
    }
    
    if (p > 1){
        p = 1;
    }
    
    double maxTimeStamp = midiSequence.musicTotalTime * p;
    currentMusitTime = 0;
    playTimeStamp = 0;
    while (currentMusitTime < maxTimeStamp) {
        double bpm = [midiSequence getTempoBpmInTimeStamp:playTimeStamp];
        playTimeStamp += 1 / 60.0 / 60.0 * bpm;
        currentMusitTime += 1 / 60.0;
    }
    
    //重置播放标示
    for (int i = 0; i< midiSequence.tracks.count; i++) {
        XMidiTrack* track = midiSequence.tracks[i];
        track.playEventIndex = 0;
        if (track.eventIterator.noteMessageEvents.count <= 0){
            continue;
        }
        for (int index = 0; index < track.eventIterator.noteMessageEvents.count; index ++) {
            XMidiNoteMessageEvent* event = track.eventIterator.noteMessageEvents[index];
            
            event.isPlayed = playTimeStamp >= event.timeStamp && playTimeStamp != 0;
            if (event.isPlayed){
                track.playEventIndex = index;
            }
        }
    }
    
    isPaused = false;
}

-(void)playTimer
{
    double timeSinceLast = [[NSDate date] timeIntervalSince1970] - lastUpdateTime;
    lastUpdateTime = [[NSDate date] timeIntervalSince1970];
    
    double delayInSeconds = 1 / 60.0;
    if (!isPaused && currentMusitTime < midiSequence.musicTotalTime){
        //按bpm速率播放
        self.currentBpm = [midiSequence getTempoBpmInTimeStamp:playTimeStamp];
        playTimeStamp += timeSinceLast / 60.0 * self.currentBpm;
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
        if (isPlayTimerEnabled){
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
            if (playTimeStamp >= event.timeStamp
                && !event.isPlayed
                && !track.isMuted)
            {
                track.playEventIndex = index;
                event.isPlayed = true;
                [XAudioPlayer playSoundByEvent:event];
            }
        }
    }
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