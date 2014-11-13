//
//  Contact.m
//  ChatApp
//
//  Created by S on 11/5/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "Contact.h"

@implementation Contact

@dynamic objectIDForUser;
@dynamic username;
@dynamic name;
@dynamic email;
@dynamic user;
@dynamic contactForUser;

+(void)load
{
    [self registerSubclass];
}

+(NSString *)parseClassName
{
    return @"Contact";
}

@end
