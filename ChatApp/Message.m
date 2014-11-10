//
//  Message.m
//  ChatApp
//
//  Created by S on 11/6/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "Message.h"

@implementation Message

@dynamic message;
@dynamic userCurrent;
@dynamic userContact;
@dynamic date;

+(NSString *)parseClassName
{
    return @"Message";
}

+(void)load
{
    [self registerSubclass];
}

@end
