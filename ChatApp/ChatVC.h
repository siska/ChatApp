//
//  ChatVC.h
//  ChatApp
//
//  Created by S on 11/11/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "JSQMessagesBubbleImage.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "JSQMessageData.h"
#import "UIColor+JSQMessages.h"
#import "JSQMessagesTimestampFormatter.h"
#import "JSQMessagesAvatarImage.h"
#import "JSQMessagesAvatarImageFactory.h"
#import <Parse/Parse.h>
#import "Conversation.h"

@interface ChatVC : JSQMessagesViewController <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout>     //<JSQMessagesCollectionViewDataSource> //, JSQMessagesCollectionViewCellDelegate> //, JSQMessagesCollectionViewDelegateFlowLayout, JSQMessageBubbleImageDataSource>

@property PFUser *selectedUser;


@end
