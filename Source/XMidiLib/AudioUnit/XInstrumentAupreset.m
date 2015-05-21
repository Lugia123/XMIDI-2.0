//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//

#import "XInstrumentAupreset.h"

@implementation XInstrumentAupreset
- (id)initWithInstrumentType:(int)instrumentType AupresentFileName:(NSString*)aupresentFileName
{
    if(self = [super init]){
        self.instrumentType = instrumentType;
        self.aupresentFileName = aupresentFileName;
    }
    return self;
}
@end
