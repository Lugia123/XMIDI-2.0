//
//  XAudioUnit.h
//  XMidi
//
//  Created by Lugia on 15/5/20.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XFunction.h"
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface XAudioUnit : NSObject 
@property (nonatomic) Float64   graphSampleRate;
@property (nonatomic) AUGraph   processingGraph;
@property (nonatomic) AudioUnit samplerUnit;
@property (nonatomic) AudioUnit ioUnit;
@property (nonatomic) int trackIndex;
@property (nonatomic) int instrumentType;

- (id)initWithPresetURL:(NSURL *)url;
- (void)startPlayingNote:(UInt32)note withVelocity:(double)velocity;
- (void)stopPlayingNote:(UInt32)note;
@end