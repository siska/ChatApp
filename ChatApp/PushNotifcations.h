//
//  PushNotifcations.h
//  ChatApp
//
//  Created by Vi on 11/18/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Conversation.h"

@interface PushNotifcations : NSObject

+(void)sendPushWhenMessageRecieved;


@end
