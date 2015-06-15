//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "XFunction.h"
#import "XAudioPlayer.h"
#import "XMidiEvent.h"

@interface XMidiNoteMessageEvent : XMidiEvent
@property (nonatomic) BOOL isPlayed;
@property (nonatomic) UInt8 channel;
@property (nonatomic) UInt8 note;
@property (nonatomic) UInt8 velocity;
@property (nonatomic) UInt8 releaseVelocity;	// was "reserved". 0 is the correct value when you don't know.
@property (nonatomic) Float32 duration;
@property (nonatomic) float panning;    // < 0 is left, 0 is center, > 0 is right
@property (nonatomic) UInt8 octave;
@property (nonatomic) NSString *noteNumber;
@end
