//
//  ChatVC.m
//  ChatApp
//
//  Created by S on 11/11/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "ChatVC.h"


@interface ChatVC ()
@property NSMutableArray *messages;
@property JSQMessagesAvatarImage *placeholderImageData;
@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *usersInConversation = [[NSArray alloc] initWithObjects:[PFUser currentUser], self.selectedUser, nil];
    self.messages = [[NSMutableArray alloc] init];

    self.placeholderImageData = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"blank_avatar"] diameter:30.0];

    self.navigationItem.title = [self.selectedUser objectForKey:@"FirstName"];

    [self queryConversationsMessagesFromParse:usersInConversation];

    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
}

-(void)queryConversationsMessagesFromParse:(NSArray *)usersInConversation
{
    PFQuery *queryForConversations = [PFQuery queryWithClassName:@"Conversation"];
    [queryForConversations whereKey:@"users" containsAllObjectsInArray:usersInConversation];
    //[queryForConversations setLimit:10]; //review where this cuts it off at - most recent or oldest messages - only allows
    [queryForConversations findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error) {
             NSLog(@"Error: %@", error.userInfo);
         }
         else
         {
             for (Conversation *conversation in objects) {
                 JSQMessage *message = [self convertConversationToJSQMessage:conversation];
                 [self.messages addObject:message];
             }

             [self.collectionView reloadData];

             if (self.messages.count > 9)
             {
                 // delay offset change by a tiny amount, or it doesn't work
                 // max added the above comment and set this up so that when the messages are loaded or when they are reloaded, the collection view automatically scrolls to the bottom - he also moved it out of the for loop - we don't want to reload it every time
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self scrollToBottomAnimated:YES];
                 }];
             }
         }
     }];
}

- (NSString *)senderId {
    return [PFUser currentUser].objectId;
}

- (JSQMessage *)convertConversationToJSQMessage:(Conversation *)conversation
{
    return [[JSQMessage alloc] initWithSenderId:conversation.senderId senderDisplayName:conversation.senderDisplayName date:conversation.date text:conversation.text];
}

/*[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:items - 1 inSection:0]
 atScrollPosition:UICollectionViewScrollPositionTop
 animated:animated];   */

//[self scrollToBottomAnimated:YES];


//[self.collectionView setContentOffset:CGPointMake(0, 300)];

//         [self automaticallyScrollsToMostRecentMessage];


//where is the senderID, name, etc coming from?
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    Conversation *conversation = [Conversation object];
    conversation.users = [[NSArray alloc] initWithObjects:[PFUser currentUser], self.selectedUser, nil];
    conversation.text = text;
    conversation.senderId = [PFUser currentUser].objectId;
    conversation.senderDisplayName = [[PFUser currentUser] objectForKey:@"FirstName"];
    conversation.receiverID = self.selectedUser;
    conversation.date = date;
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error userInfo]);
        } else {
            UITextView *textView = self.inputToolbar.contentView.textView;
            textView.text = nil;
            [textView.undoManager removeAllActions];
            [self.messages addObject:[self convertConversationToJSQMessage:conversation]];

            id ip = [NSIndexPath indexPathForItem:self.messages.count - 1 inSection:0];
            [self.collectionView insertItemsAtIndexPaths:@[ip]];
            [self scrollToBottomAnimated:YES];
        }
    }];
}


#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];

    if ([message.senderId isEqualToString:[PFUser currentUser].objectId]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    } else {
        return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = self.messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:[PFUser currentUser].objectId])
    {
        return nil;
    }

    if (indexPath.item - 1 > 0)
    {
        JSQMessage *previousMessage = self.messages[indexPath.item-1];
        if ([previousMessage.senderId isEqualToString:message.senderId])
        {
            return nil;
        }
    }
    return nil; //[[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:[PFUser currentUser].objectId])
    {
        cell.textView.textColor = [UIColor whiteColor];
    }
    else
    {
        cell.textView.textColor = [UIColor blackColor];
    }

    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate



- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:[PFUser currentUser].objectId])  //self.senderId])
    {
        return 0.0f;
    }

    if (indexPath.item - 1 > 0)
    {
        JSQMessage *previousMessage = self.messages[indexPath.item-1];
        if ([previousMessage.senderId isEqualToString:[PFUser currentUser].objectId])
        {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"didTapLoadEarlierMessagesButton");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didTapAvatarImageView");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didTapMessageBubbleAtIndexPath");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

@end
