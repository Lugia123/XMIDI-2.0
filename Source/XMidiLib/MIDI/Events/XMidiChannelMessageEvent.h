//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "XFunction.h"
#import "XAudioPlayer.h"
#import "XMidiEvent.h"

@interface XMidiChannelMessageEvent : XMidiEvent
struct MidiInstrument {
    int type;
    int hbank, lbank, patch;
    int split;
    const char* name;
    int firstType;
};

enum {
    MidiType_UNKNOWN = 0,
    MidiType_GM = 1,
    MidiType_GS = 2,
    MidiType_XG = 4
};

enum {
    XMidiChannelType_NoteOff = 0,
    XMidiChannelType_NoteOn = 1,
    XMidiChannelType_PolyphonicKeyAftertouch = 2,
    XMidiChannelType_ControlChange = 3,
    XMidiChannelType_ProgramChange = 4,
    XMidiChannelType_ChannelAfterTouch = 5,
    XMidiChannelType_PitchBendChange = 6,
    XMidiChannelType_System = 7
};

extern struct MidiInstrument minstr[];
@property (nonatomic) UInt8 channel;
@property (nonatomic) UInt8 status;
@property (nonatomic) UInt8 data1;
@property (nonatomic) UInt8 data2;
@property (nonatomic) UInt8 reserved;
@property (nonatomic) UInt8 channelType;

#pragma mark - ProgramChange
@property (nonatomic) NSString* instrumentName;
@property (nonatomic) int instrumentFirstType;
@property (nonatomic) int instrumentSecondType;
@end
