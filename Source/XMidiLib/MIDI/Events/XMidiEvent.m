//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//


#import "XMidiEvent.h"

@implementation XMidiEvent
-(id)init:(XMidiEvent*)event{
    if(self = [super init]){
        self = event;
    }
    return self;
}

-(id)init:(MusicTimeStamp)timeStamp
     type:(MusicEventType)type
     data:(NSData*)data
{
    if(self = [super init]){
        self.timeStamp = [[[NSString alloc]initWithFormat:@"%.3f",timeStamp] floatValue];
        self.type = type;
        self.data = [data mutableCopy];
    }
    return self;
}

-(void)initWithEvent:(XMidiEvent*)event
{
    self.timeStamp = event.timeStamp;
    self.type = event.type;
    self.data = [event.data mutableCopy];
}
@end