//
//  Contact.m
//  ChatApp
//
//  Created by S on 11/5/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "Friend.h"

@implementation Friend

@dynamic name;
@dynamic fbID;
@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic friendOf;

+(void)load
{
    [self registerSubclass];
}

+(NSString *)parseClassName
{
    return @"Contacts";
}

@end
