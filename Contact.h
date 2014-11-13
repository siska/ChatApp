//
//  Contact.h
//  ChatApp
//
//  Created by S on 11/5/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface Contact : PFObject <PFSubclassing>
@property NSString *objectIDForUser;
@property NSString *username;
@property NSString *name;
@property NSString *email;
@property PFUser *user;
@property PFObject *contactForUser;


@end
