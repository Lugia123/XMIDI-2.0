//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "XFunction.h"
#import "XMidiEvent.h"
#import "XMidiTrack.h"
#import "XMidiNoteMessageEvent.h"
#import "XMidiChannelMessageEvent.h"
#import "XMidiTempoEvent.h"

@class XMidiTrack;

@interface XMidiEventIterator : NSObject
@property (nonatomic) MusicEventIterator eventIterator;

@property (nonatomic) NSMutableArray* tempoEvents;
@property (nonatomic) NSMutableArray* noteMessageEvents;
@property (nonatomic) NSMutableArray* channelMessageEvents;

-(id)init:(XMidiTrack*)track;
@end