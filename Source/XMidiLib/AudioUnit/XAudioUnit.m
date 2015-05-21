//
//  XAudioUnit.m
//  XMidi
//
//  Created by Lugia on 15/5/20.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XAudioUnit.h"
@implementation XAudioUnit
#define kMidiVelocityMinimum 0
#define kMidiVelocityMaximum 127

enum {
    kMIDIMessage_NoteOn    = 0x9,
    kMIDIMessage_NoteOff   = 0x8,
    kMIDIMessage_ControlChange 		= 0xB,
    kMIDIMessage_ProgramChange 		= 0xC,
    kMIDIMessage_BankMSBControl 	= 0,
    kMIDIMessage_BankLSBControl		= 32,
    kMIDIMessageProgramChange = 0xC0
};

- (id)initWithPresetURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        [self createAUGraph];
        [self configureAndStartAudioProcessingGraph:self.processingGraph];
        [self loadSynthFromPresetURL:url];
    }
    
    return self;
}

- (void)startPlayingNote:(UInt32)note withVelocity:(double)velocity
{
    UInt32 noteNum = note;
    UInt32 onVelocity = velocity;
    UInt32 noteCommand = kMIDIMessage_NoteOn << 4 | 0;
    
    OSStatus result = MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, onVelocity, 0);
    if (result != noErr)
    {
        [XFunction writeLog:@"startPlayingNote() failed with error %d in %s.", (int)result, __PRETTY_FUNCTION__];
    }
}

- (void)stopPlayingNote:(UInt32)note
{
    UInt32 noteNum     = note;
    UInt32 noteCommand = kMIDIMessage_NoteOff << 4 | 0;
    
    OSStatus result = MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, 0, 0);
    if (result != noErr)
    {
        [XFunction writeLog:@"stopPlayingNote() failed with error %d in %s.", (int)result, __PRETTY_FUNCTION__];
    }
}

// Create an audio processing graph.
- (BOOL) createAUGraph {
    
    OSStatus result = noErr;
    AUNode samplerNode, ioNode;
    
    // Specify the common portion of an audio unit's identify, used for both audio units
    // in the graph.
    AudioComponentDescription cd = {};
    cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
    cd.componentFlags            = 0;
    cd.componentFlagsMask        = 0;
    
    // Instantiate an audio processing graph
    result = NewAUGraph (&_processingGraph);
    if (result != noErr)
    {
        [XFunction writeLog:@"Unable to create an AUGraph object. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
    }
    
    //Specify the Sampler unit, to be used as the first node of the graph
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_Sampler;
    
    // Add the Sampler unit node to the graph
    result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode);
    if (result != noErr)
    {
        [XFunction writeLog:@"Unable to add the Sampler unit to the audio processing graph. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
    }
    
    // Specify the Output unit, to be used as the second and final node of the graph
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_RemoteIO;
    
    // Add the Output unit node to the graph
    result = AUGraphAddNode (self.processingGraph, &cd, &ioNode);
    if (result != noErr)
    {
        [XFunction writeLog:@"Unable to add the Output unit to the audio processing graph. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
    }
    
    // Open the graph
    result = AUGraphOpen (self.processingGraph);
    if (result != noErr)
    {
        [XFunction writeLog:@"Unable to open the audio processing graph. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
    }
    
    // Connect the Sampler unit to the output unit
    result = AUGraphConnectNodeInput (self.processingGraph, samplerNode, 0, ioNode, 0);
    if (result != noErr)
    {
        [XFunction writeLog:@"Unable to interconnect the nodes in the audio processing graph. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
    }
    
    // Obtain a reference to the Sampler unit from its node
    result = AUGraphNodeInfo (self.processingGraph, samplerNode, 0, &_samplerUnit);
    if (result != noErr)
    {
        [XFunction writeLog:@"Unable to obtain a reference to the Sampler unit. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
    }
    
    // Obtain a reference to the I/O unit from its node
//    result = AUGraphNodeInfo (self.processingGraph, ioNode, 0, &_ioUnit);
//    if (result != noErr)
//    {
//        [XFunction writeLog:@"Unable to obtain a reference to the I/O unit. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
//    }
    
    return YES;
}

// Starting with instantiated audio processing graph, configure its
// audio units, initialize it, and start it.
- (void) configureAndStartAudioProcessingGraph: (AUGraph) graph
{
    OSStatus result = noErr;
    
    if (graph) {
        
        // Initialize the audio processing graph.
        result = AUGraphInitialize (graph);
        if (result != noErr)
        {
            [XFunction writeLog:@"Unable to initialze AUGraph object. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
        }
        
        // Start the graph
        result = AUGraphStart (graph);
        if (result != noErr)
        {
            [XFunction writeLog:@"Unable to start audio processing graph. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
        }
        
        // Print out the graph to the console
        // CAShow (graph);
    }
}

// Load a synthesizer preset file and apply it to the Sampler unit
- (OSStatus) loadSynthFromPresetURL: (NSURL *) presetURL {
    OSStatus result = noErr;

    AUSamplerInstrumentData auPreset = {0};
    
    auPreset.fileURL = (__bridge CFURLRef) presetURL;
    auPreset.instrumentType = kInstrumentType_AUPreset;
    
    result = AudioUnitSetProperty(self.samplerUnit,
                                  kAUSamplerProperty_LoadInstrument,
                                  kAudioUnitScope_Global,
                                  0,
                                  &auPreset,
                                  sizeof(auPreset));
    if (result != noErr)
    {
        [XFunction writeLog:@"Unable to set AudioUnitSetProperty. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
    }
    return result;
}

- (void)stopAudioProcessingGraph {
    OSStatus result = noErr;
    
    if (self.processingGraph) {
        result = AUGraphStop(self.processingGraph);
        if (result != noErr)
        {
            [XFunction writeLog:@"Unable to stop the audio processing graph. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
        }
    }
}

- (void)restartAudioProcessingGraph {
    OSStatus result = noErr;
    
    if (self.processingGraph) {
        result = AUGraphStart(self.processingGraph);
        if (result != noErr)
        {
            [XFunction writeLog:@"Unable to restart the audio processing graph. Error code: %d in %s.", (int)result, __PRETTY_FUNCTION__];
        }
    }
}
@end