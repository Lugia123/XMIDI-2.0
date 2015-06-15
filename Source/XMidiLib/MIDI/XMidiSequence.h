//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "XMidiTrack.h"
#import "XMidiNoteMessageEvent.h"
#import "XMidiChannelMessageEvent.h"
#import "XMidiTempoEvent.h"
#import "XFunction.h"

@class XMidiTrack;

@interface XMidiSequence : NSObject

@property (nonatomic) MusicSequence sequence;
//track
@property (nonatomic) NSMutableArray* tracks;
//Tempo Track
@property (nonatomic) XMidiTrack* tempoTrack;

#pragma mark - Function
- (id)init:(NSURL*)midiUrl;
- (id)initWithData:(NSData*)data;
- (float)getTempoBpmInTimeStamp:(float)timeStamp;
- (NSString *)description;

#pragma mark - Properties
@property (nonatomic) MusicTimeStamp length;
@property (nonatomic, readonly) double musicTotalTime;
@property (nonatomic, readonly) UInt32 trackCount;
@end