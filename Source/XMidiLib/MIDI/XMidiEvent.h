//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "XFunction.h"
#import "XMidiNoteMessage.h"
#import "XMidiChannelMessage.h"
#import "XMidiSequence.h"
#import "XAudioPlayer.h"

@class XMidiSequence;
@class XMidiNoteMessage;
@class XMidiChannelMessage;
@class XMidiTrack;
@class XOpenAL;

@interface XMidiEvent : NSObject
@property (nonatomic) XMidiTrack* track;
@property (nonatomic) MusicTimeStamp timeStamp;//出现时间
@property (nonatomic) MusicEventType type;
@property (nonatomic) NSData* data;
@property (nonatomic) BOOL isPlayed;
@property (nonatomic) int bpm;
@property (nonatomic) XMidiNoteMessage* noteMessage;
@property (nonatomic) XMidiChannelMessage *channelMessage;

-(id)init:(MusicTimeStamp)timeStamp type:(MusicEventType)type data:(NSData*)data;
-(void)playEvent;

+(float)getTempoBpmInTimeStamp:(float)timeStamp;
@end
