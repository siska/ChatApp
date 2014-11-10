//
//  MessageViewController.m
//  ChatApp
//
//  Created by S on 11/5/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "MessageViewController.h"

@interface MessageViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property NSArray *allCurrentUserMessages;
@property NSArray *allContactUserMessages;
@property NSMutableArray *combinedMessages;
@property NSMutableArray *combinedAndOrderedMessages;


@end

@implementation MessageViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.allContactUserMessages = [NSArray array];
    [self queryCurrentUserMessagesFromParse];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

// I need to get both messages sent from current user to other and from other to current user, then somehow order them based on date and time, then pull them into table views showing name and content of message
-(void)queryCurrentUserMessagesFromParse
{   NSLog(@"Should be called 1");
    PFQuery *queryForMessages = [PFQuery queryWithClassName:@"Message"];
    [queryForMessages whereKey:@"userCurrent" equalTo:[PFUser currentUser]];
    [queryForMessages whereKey:@"userContact" equalTo:self.selectedUser];
    [queryForMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error) {
             NSLog(@"Error: %@", error.userInfo);
             self.allCurrentUserMessages = [NSArray array];
         }
         else
         {
             self.allCurrentUserMessages = objects;
         }
         NSLog(@"queryCurrentUserMessagesFromParse returned: %@", self.allCurrentUserMessages);
         [self queryContactUserMessagesFromParse];
     }];
}

-(void)queryContactUserMessagesFromParse
{
    NSLog(@"Should be called 2");
    PFQuery *queryForMessages = [PFQuery queryWithClassName:@"Message"];
    [queryForMessages whereKey:@"userCurrent" equalTo:self.selectedUser];
    [queryForMessages whereKey:@"userContact" equalTo:[PFUser currentUser]];
    [queryForMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error) {
             NSLog(@"Error: %@", error.userInfo);
             self.allContactUserMessages = [NSArray array];
         }
         else
         {
             self.allContactUserMessages = objects;
         }
         NSLog(@"queryContactUserMessagesFromParse returned: %@", self.allContactUserMessages);
         [self combineCurrentMessagesArrays];
     }];
}


-(void)combineCurrentMessagesArrays
{
    NSLog(@"Should be called 3");

    self.combinedMessages = [[NSMutableArray alloc] init];

    for (Message *message in self.allCurrentUserMessages) {
        [self.combinedMessages addObject:message];
    }
    NSLog(@"combineCurrentMessagesArrays returned: %@", self.combinedMessages);
    [self combineContactMessagesArrays];
}

-(void)combineContactMessagesArrays
{
    NSLog(@"Should be called 4");
    for (Message *message in self.allContactUserMessages) {
        [self.combinedMessages addObject:message];
    }
    NSLog(@"combineContactMessagesArrays returned: %@", self.combinedMessages);
    [self orderCombinedArray];
}

-(void)orderCombinedArray //create and add my own time to messages - use that - it isn't ordering them right now
{
    NSLog(@"Should be called 5");
    self.combinedAndOrderedMessages = [NSMutableArray array];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];

    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.combinedMessages sortedArrayUsingDescriptors:sortDescriptors];

    for (Message *message in sortedArray) {
        [self.combinedAndOrderedMessages addObject:message];
    }
    NSLog(@"orderCombinedArray returned: %@", self.combinedAndOrderedMessages);
    [self reloadMessageTableView];
}

-(void)reloadMessageTableView
{
    NSLog(@"reloadMessageTableView called");
    [self.tableView reloadData];
}

- (IBAction)onRefreshTapped:(id)sender {
    [self queryCurrentUserMessagesFromParse];
}


#pragma mark UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.combinedAndOrderedMessages.count;
}

//add an if else statement here to determine which user is saying what - show differently based on that
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCellID"];
    Message *message = [self.combinedAndOrderedMessages objectAtIndex:indexPath.row];

    NSLog(@"Message from cellForRow... : %@", message);
    cell.textLabel.text = message.message;
    return cell;
}

#pragma mark UITextField Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self addMessageToParse:textField];
    [textField resignFirstResponder];
    self.messageTextField.text = @"";

    return YES;
}

#pragma mark Save To Parse

-(void)addMessageToParse:(UITextField *)textField
{
    Message *message = [Message object];

    message.message = textField.text;
    message.userCurrent = [PFUser currentUser];
    message.userContact = self.selectedUser;
    message.date = [NSDate date];

    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error userInfo]);
        }
        else {
            [self queryCurrentUserMessagesFromParse];
        }
    }];
}

@end
