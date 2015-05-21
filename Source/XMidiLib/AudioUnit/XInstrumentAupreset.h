//
//  Created by Lugia on 15/3/13.
//  Copyright (c) 2015年 Freedom. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface XInstrumentAupreset : NSObject
@property (nonatomic) int instrumentType;
@property (nonatomic) NSString* aupresentFileName;

//初始化
- (id)initWithInstrumentType:(int)instrumentType AupresentFileName:(NSString*)aupresentFileName;
@end

