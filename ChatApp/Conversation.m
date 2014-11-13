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
//@dynamic message;

//required to create JSQMessage in ChatVC
@dynamic text;
@dynamic senderId;
@dynamic senderDisplayName;
@dynamic date;


+(void)load
{
    [self registerSubclass];
}

+(NSString *)parseClassName
{
    return @"Conversation";
}

@end
