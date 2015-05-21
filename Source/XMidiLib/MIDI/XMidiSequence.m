//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XMidiSequence.h"

//速率
static NSMutableArray* tempoChildEvents;


@implementation XMidiSequence

- (UInt32)trackCount{
    UInt32 trackCount = 0;
    OSStatus err = MusicSequenceGetTrackCount(self.sequence, &trackCount);
    if (err != 0){
        [XFunction writeLog:@"MusicSequenceGetTrackCount() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    return trackCount;
}

- (id)init:(NSURL*)midiUrl{
    if(self = [super init]){
        [self initByUrl:midiUrl];
    }
    return self;
}

- (id)initWithData:(NSData*)data{
    if(self = [super init]){
        [self initByData:data];
    }
    return self;
}

+(NSMutableArray*)getTempoEvents{
    return tempoChildEvents;
}

+(void)setTempoEvents:(NSMutableArray*)newVal{
    if (tempoChildEvents != newVal){
        tempoChildEvents = newVal;
    }
}

-(void)initByData:(NSData*)data{
    MusicSequence sequence;
    OSStatus err = NewMusicSequence(&sequence);
    if (err != 0){
        [XFunction writeLog:@"NewMusicSequence() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }

    self.sequence = sequence;
    err = MusicSequenceFileLoadData(self.sequence, (__bridge CFDataRef)(data), kMusicSequenceFile_MIDIType, 0);
    if (err != 0){
        [XFunction writeLog:@"MusicSequenceFileLoad() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    
    [self initTempoTrack];
    [self initTrack];
//    [self initMusicTotalTimeStamp];
    NSLog(@"musicTotalTime:%f length:%f",self.musicTotalTime,self.length);
}

-(void)initByUrl:(NSURL*)midiUrl{
    MusicSequence sequence;
    OSStatus err = NewMusicSequence(&sequence);
    if (err != 0){
        [XFunction writeLog:@"NewMusicSequence() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }

    self.sequence = sequence;
    err = MusicSequenceFileLoad(self.sequence, (__bridge CFURLRef)(midiUrl), kMusicSequenceFile_MIDIType, 0);
    if (err != 0){
        [XFunction writeLog:@"MusicSequenceFileLoad() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    
    [self initTempoTrack];
    [self initTrack];
//    [self initMusicTotalTimeStamp];
    NSLog(@"musicTotalTime:%f length:%f",self.musicTotalTime,self.length);
}

-(void)initTempoTrack{
    MusicTrack tempoTrack;
    OSStatus err = MusicSequenceGetTempoTrack(self.sequence, &tempoTrack);
    if (err != 0){
        [XFunction writeLog:@"MusicSequenceGetIndTrack() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    
    NSMutableArray* tempoEvents = [NSMutableArray array];
    self.xTempoTrack = [[XMidiTrack alloc] init:tempoTrack trackIndex:-1];
    
//    NSLog(@"loopDuration:%f",self.xTempoTrack.loopDuration);
//    NSLog(@"numberOfLoops:%d",(int)self.xTempoTrack.numberOfLoops);
//    NSLog(@"offset:%f",self.xTempoTrack.offset);
//    NSLog(@"muted:%d",self.xTempoTrack.muted);
//    NSLog(@"solo:%d",self.xTempoTrack.solo);
//    NSLog(@"length:%f",self.xTempoTrack.length);
//    NSLog(@"timeResolution:%d",self.xTempoTrack.timeResolution);
    
    for (int i=0; i<[[[self.xTempoTrack eventIterator]childEvents]count]; i++) {
        XMidiEvent* event = [[self.xTempoTrack eventIterator]childEvents][i];
//        NSLog(@"time:%f bpm:%d",[event timeStamp],[event bpm]);
        [tempoEvents addObject:event];
    }
    [XMidiSequence setTempoEvents:tempoEvents];
}

-(void)initTrack{
    self.tracks = [NSMutableArray array];
    int count = [self trackCount];
    for (int i=0; i<count; i++) {
        MusicTrack track;
        OSStatus err = MusicSequenceGetIndTrack(self.sequence, i, &track);
        if (err != 0){
            [XFunction writeLog:@"MusicSequenceGetIndTrack() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
        }
        XMidiTrack* xTrack = [[XMidiTrack alloc] init:track trackIndex:i];
        [self.tracks addObject:xTrack];
        [XAudioPlayer setAudioUnit:xTrack];
    }
}

#pragma mark - Properties

- (MusicTimeStamp)length
{
    MusicTimeStamp length = 0;
    for (XMidiTrack *track in self.tracks) {
        MusicTimeStamp trackLength = track.length + track.offset;
        if (trackLength > length) length = trackLength;
    }
    
    return length;
}

- (double)musicTotalTime
{
    double duration = 0;
    OSStatus err = MusicSequenceGetSecondsForBeats(self.sequence, self.length, &duration);
    if (err){
        [XFunction writeLog:@"MusicSequenceGetSecondsForBeats() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    return duration;
}

@end