//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface XMidiEvent : NSObject
enum {
    XMidiEventType_NULL = 0,
    XMidiEventType_ExtendedNote = 1,
    XMidiEventType_ExtendedTempo = 3,
    XMidiEventType_User = 4,
    XMidiEventType_Meta = 5,
    XMidiEventType_MIDINoteMessage = 6,
    XMidiEventType_MIDIChannelMessage = 7,
    XMidiEventType_MIDIRawData = 8,
    XMidiEventType_Parameter = 9,
    XMidiEventType_AUPreset = 10
};

@property (nonatomic) MusicTimeStamp timeStamp;
@property (nonatomic) UInt8 type;
@property (nonatomic) NSData* data;

-(id)init:(XMidiEvent*)event;
-(id)init:(MusicTimeStamp)timeStamp type:(MusicEventType)type data:(NSData*)data;

-(void)initWithEvent:(XMidiEvent*)event;
@end
