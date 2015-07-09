//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XMidiEventIterator.h"

@implementation XMidiEventIterator

-(id)init:(XMidiTrack*)track{
    if(self = [super init]){
        [self initWithTrack:track];
    }
    return self;
}

-(void)initWithTrack:(XMidiTrack*)track{
    MusicEventIterator eventIterator;
    OSStatus err = NewMusicEventIterator(track.musicTrack, &eventIterator);
    if (err != 0){
        [XFunction writeLog:@"NewMusicEventIterator() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    
    self.eventIterator = eventIterator;
    [self initChildEvents:track];
}

-(void)initChildEvents:(XMidiTrack*)track{
    if (self.eventIterator == NULL){
        return;
    }
    
    self.tempoEvents = [NSMutableArray array];
    self.noteMessageEvents = [NSMutableArray array];
    self.channelMessageEvents = [NSMutableArray array];
    
    //计算每个音符真实时间
    
    while ([self hasCurrentEvent]) {
        XMidiEvent* event = (XMidiEvent *)[self currentEvent];
        if (event == nil){
            continue;
        }
        
        switch (event.type) {
            case XMidiEventType_ExtendedTempo:
                [self.tempoEvents addObject:[[XMidiTempoEvent alloc] init:event]];
                break;
            case XMidiEventType_MIDINoteMessage:
                [self.noteMessageEvents addObject:[[XMidiNoteMessageEvent alloc] init:event]];
                break;
            case XMidiEventType_MIDIChannelMessage:
                [self.channelMessageEvents addObject:[[XMidiChannelMessageEvent alloc] init:event]];
                break;
            default:
                break;
        }

        [self moveToNextEvent];
    }
}

#pragma mark - Navigating

- (BOOL)seek:(MusicTimeStamp)timeStamp
{
    OSStatus err = MusicEventIteratorSeek(self.eventIterator, timeStamp);
    if (err) {
        [XFunction writeLog:@"MusicEventIteratorSeek() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    return !err;
}

- (BOOL)moveToNextEvent
{
    OSStatus err = MusicEventIteratorNextEvent(self.eventIterator);
    if (err) {
        [XFunction writeLog:@"MusicEventIteratorNextEvent() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    return !err;
}

- (BOOL)moveToPreviousEvent
{
    OSStatus err = MusicEventIteratorPreviousEvent(self.eventIterator);
    if (err) {
        [XFunction writeLog:@"MusicEventIteratorPreviousEvent() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    return !err;
}

#pragma mark - Current Event

- (NSObject *)currentEvent
{
    MusicTimeStamp timeStamp;
    MusicEventType type;
    const void *data;
    UInt32 dataSize;
    
    OSStatus err = MusicEventIteratorGetEventInfo(self.eventIterator, &timeStamp, &type, &data , &dataSize);
    if (err) {
        [XFunction writeLog:@"MusicEventIteratorGetEventInfo() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
        return nil;
    }
    
    return [[XMidiEvent alloc] init:timeStamp type:type data:[NSData dataWithBytes:data length:dataSize]];
}

#pragma mark - Properties

- (BOOL)hasPreviousEvent
{
    Boolean hasPreviousEvent = FALSE;
    OSStatus err = MusicEventIteratorHasPreviousEvent(self.eventIterator, &hasPreviousEvent);
    if (err) {
        [XFunction writeLog:@"MusicEventIteratorHasPreviousEvent() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    return hasPreviousEvent ? YES : NO;
}

- (BOOL)hasCurrentEvent
{
    Boolean hasCurrentEvent = FALSE;
    OSStatus err = MusicEventIteratorHasCurrentEvent(self.eventIterator, &hasCurrentEvent);
    if (err) {
        [XFunction writeLog:@"MusicEventIteratorHasCurrentEvent() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    return hasCurrentEvent ? YES : NO;
}

- (BOOL)hasNextEvent
{
    Boolean hasNextEvent = FALSE;
    OSStatus err = MusicEventIteratorHasNextEvent(self.eventIterator, &hasNextEvent);
    if (err) {
        [XFunction writeLog:@"MusicEventIteratorHasNextEvent() failed with error %d in %s.", err, __PRETTY_FUNCTION__];
    }
    return hasNextEvent ? YES : NO;
}
@end