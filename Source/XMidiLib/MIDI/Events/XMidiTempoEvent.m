//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XMidiTempoEvent.h"

@implementation XMidiTempoEvent
-(id)init:(XMidiEvent*)event
{
    if(self = [super init])
    {
        [super initWithEvent:event];
        ExtendedTempoEvent *tempoEvent = (ExtendedTempoEvent *)[self.data bytes];
        self.bpm = tempoEvent->bpm;
    }
    return self;
}
@end