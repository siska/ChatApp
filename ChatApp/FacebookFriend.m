//
//  FacebookFriend.m
//  ChatApp
//
//  Created by Vi on 11/12/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "FacebookFriend.h"

@implementation FacebookFriend

@dynamic name;
@dynamic fbID;
@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic friendOf;


+(NSString *)parseClassName
{
    return @"FacebookFriend";
}

+(void)load
{
    [self registerSubclass];
}

@end
