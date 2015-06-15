//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XMidiNoteMessageEvent.h"

@implementation XMidiNoteMessageEvent
NSString *noteNumbers[] = {@"C",@"C#",@"D",@"D#",@"E",@"F",@"F#",@"G",@"G#",@"A",@"A#",@"B"};

-(id)init:(XMidiEvent*)event
{
    if(self = [super init])
    {
        [super initWithEvent:event];
        MIDINoteMessage *noteMessage = (MIDINoteMessage*)[self.data bytes];
        self.isPlayed = false;
        self.channel = noteMessage->channel;
        self.note = noteMessage->note;
        self.velocity = noteMessage->velocity;
        self.releaseVelocity = noteMessage->releaseVelocity;
        self.duration = noteMessage->duration;
        self.duration = [[[NSString alloc]initWithFormat:@"%.3f",self.duration] floatValue];
        
        // Panning ranges between C3 (-50%) to G5 (+50%)
        if (self.note < 48) self.panning = -50.0f;
        if (self.note >= 48 && self.note < 80) self.panning = ((((self.note - 48.0f) / (79 - 48)) * 200.0f) - 100.f) / 2.0f;
        if (self.note >= 80) self.panning = 50.0f;
        
        //Note Numbers
        self.octave = (int)(self.note / 12) - 1;
        self.noteNumber = noteNumbers[self.note - (self.octave + 1) * 12];
    }
    return self;
}
@end