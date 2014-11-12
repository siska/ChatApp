//
//  Conversation.m
//  ChatApp
//
//  Created by S on 11/12/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "Conversation.h"

@implementation Conversation

@dynamic users;
//@dynamic userOne;
//@dynamic userTwo;
@dynamic message;

+(void)load
{
    [self registerSubclass];
}

+(NSString *)parseClassName
{
    return @"Conversation";
}

@end
