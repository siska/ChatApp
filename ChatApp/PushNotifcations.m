//
//  PushNotifcations.m
//  ChatApp
//
//  Created by Vi on 11/18/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "PushNotifcations.h"

@implementation PushNotifcations

+(void)sendPushWhenMessageRecieved{
    PFQuery *userQuery  = [PFUser query];
    PFQuery *recieverOfMessage = [PFQuery queryWithClassName:@"Conversation"];

    PFQuery *pushQuery = [PFInstallation query];

    [userQuery  whereKey:@"User" matchesKey:@"recieverID" inQuery:recieverOfMessage];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    Conversation *friend = [[Conversation alloc] init];
    NSString *friendName = friend.senderDisplayName;
    [push setMessage:[NSString stringWithFormat:@"You have a message from %@",friendName]];
    [push sendPushInBackground];
}

@end
