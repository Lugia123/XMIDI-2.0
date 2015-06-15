//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "XFunction.h"
#import "XMidiEvent.h"

@interface XMidiTempoEvent : XMidiEvent
@property (nonatomic) int bpm;
@end
