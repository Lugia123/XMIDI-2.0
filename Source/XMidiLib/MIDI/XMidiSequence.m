//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XMidiSequence.h"

@implementation XMidiSequence

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
    
    [self initMidiTrack];
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
    
    [self initMidiTrack];
}

-(void)initMidiTrack
{
    [self initTempoTrack];
    [self initTrack];
    [self initAudioUnit];
}

-(void)initTempoTrack{
    MusicTrack tempoTrack;
    OSStatus err = MusicSequenceGetTempoTrack(self.sequence, &tempoTrack);
    if (err != 0){
        [XFunction writeLog:@"MusicSequenceGetTempoTrack() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    
    self.tempoTrack = [[XMidiTrack alloc] init:tempoTrack trackIndex:-1];
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
    }
}

-(void)initAudioUnit
{
    for (XMidiTrack *track in self.tracks)
    {
        for (XMidiChannelMessageEvent* event in track.eventIterator.channelMessageEvents)
        {
            if (event.channelType == XMidiChannelType_ProgramChange){
                [XAudioPlayer setAudioUnit:event];
            }
        }
    }
}

-(float)getTempoBpmInTimeStamp:(float)timeStamp{
    NSMutableArray* tempoChildEvents = self.tempoTrack.eventIterator.tempoEvents;
    int bpm = 100;
    if (timeStamp <= 0 && tempoChildEvents.count > 0){
        return [tempoChildEvents[0] bpm];
    }
    for (int i=(int)([tempoChildEvents count] - 1); i>=0; i--) {
        if ([tempoChildEvents[i] timeStamp] <= timeStamp){
            if ([tempoChildEvents[i] bpm] != 0){
                bpm = [tempoChildEvents[i] bpm];
            }
            break;
        }
    }
    return bpm;
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

- (UInt32)trackCount{
    UInt32 trackCount = 0;
    OSStatus err = MusicSequenceGetTrackCount(self.sequence, &trackCount);
    if (err != 0){
        [XFunction writeLog:@"MusicSequenceGetTrackCount() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    return trackCount;
}

#pragma mark - Description
- (NSString *)description
{
    NSString *result = [NSString stringWithFormat:@""];
    result = [result stringByAppendingFormat:@"\n==========XMidi Description=========="];
    result = [result stringByAppendingFormat:@"\nMusicTotalTime:%f",self.musicTotalTime];
    result = [result stringByAppendingFormat:@"\nLength:%f",self.length];
    
    result = [result stringByAppendingFormat:@"\n----------Tempo Track----------"];
    for (XMidiTempoEvent* tempoEvent in self.tempoTrack.eventIterator.tempoEvents)
    {
        result = [result stringByAppendingFormat:@"\nTimeStamp:%f  bpm:%d", tempoEvent.timeStamp, tempoEvent.bpm];
    }
    
    result = [result stringByAppendingFormat:@"\n----------Track----------"];
    for (XMidiTrack *track in self.tracks)
    {
        result = [result stringByAppendingFormat:@"\n----------Track Index:%d----------", track.trackIndex];
        result = [result stringByAppendingFormat:@"\n----------Note Message Start----------"];
        int noteIndex = 0;
        for (XMidiNoteMessageEvent* event in track.eventIterator.noteMessageEvents)
        {
            result = [result stringByAppendingFormat:@"\nIndex:%d  TimeStamp:%f  Channel:%d  Note:%d  NoteNumber:%@  Octave:%d  Velocity:%d  Duration:%f",
                      noteIndex,
                      event.timeStamp,
                      event.channel,
                      event.note,
                      event.noteNumber,
                      event.octave,
                      event.velocity,
                      event.duration];
            noteIndex++;
        }
        result = [result stringByAppendingFormat:@"\n----------Note Message End----------"];
        
        result = [result stringByAppendingFormat:@"\n----------Channel Message Start----------"];
        for (XMidiChannelMessageEvent* event in track.eventIterator.channelMessageEvents)
        {
            if (event.channelType != XMidiChannelType_ProgramChange){
                continue;
            }
            NSString *channelType = @"Ect";
            switch (event.channelType) {
                case XMidiChannelType_NoteOff:
                    channelType = @"Note Off";
                    break;
                case XMidiChannelType_NoteOn:
                    channelType = @"Note On";
                    break;
                case XMidiChannelType_PolyphonicKeyAftertouch:
                    channelType = @"Polyphonic Key Aftertouch";
                    break;
                case XMidiChannelType_ControlChange:
                    channelType = @"Control Change";
                    break;
                case XMidiChannelType_ProgramChange:
                    channelType = @"Program Change";
                    break;
                case XMidiChannelType_ChannelAfterTouch:
                    channelType = @"Channel After Touch";
                    break;
                case XMidiChannelType_PitchBendChange:
                    channelType = @"PitchBend Change";
                    break;
                case XMidiChannelType_System:
                    channelType = @"System";
                    break;
            }
            result = [result stringByAppendingFormat:@"\nTimeStamp:%f  ChannelType:%@  Channel:%d  Status:%x  Data1:%x  Data2:%x  Reserved:%x",
                      event.timeStamp,
                      channelType,
                      event.channel,
                      event.status,
                      event.data1,
                      event.data2,
                      event.reserved];
        }
        result = [result stringByAppendingFormat:@"\n----------Channel Message End----------"];
    }
    return result;
}
@end















