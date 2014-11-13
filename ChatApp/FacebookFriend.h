//
//  FacebookFriend.h
//  ChatApp
//
//  Created by Vi on 11/12/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import <Foundation/Foundation.h>

@interface FacebookFriend : PFObject <PFSubclassing>

@property NSString *name;
@property NSString *fbID;
@property NSString *lastName;
@property NSString *firstName;
@property NSString *email;
@property PFUser *friendOf;

@end
