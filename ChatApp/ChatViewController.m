//
//  ChatViewController.m
//  ChatApp
//
//  Created by S on 11/10/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"

@interface ChatViewController () <UITextFieldDelegate>
@property AppDelegate *appDelegate;
-(void)sendmyMessages;
-(void)didReceiveDataWithNotification:(NSNotification *)notification;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.chatTextField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.topConstraint.constant = 40;
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

- (IBAction)sendMyMSGS:(id)sender {
    [self sendmyMessages];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendmyMessages];
    return YES;

}

- (IBAction)cancelMSGs:(id)sender {
    [self.chatTextField resignFirstResponder];

}
-(void)sendmyMessages{
    NSData *dataSend = [self.chatTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allConnected = self.appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    [self.appDelegate.mcManager.session sendData:dataSend toPeers:allConnected withMode:MCSessionSendDataReliable error:&error];
    if (error) {
        NSLog(@"OH NO! %@", [error localizedDescription]);
    }
    [self.chatWindowTextView setText:[self.chatWindowTextView.text stringByAppendingString:[NSString stringWithFormat:@"I said:\n%@\n\n", self.chatTextField.text]]];
    [self.chatTextField setText:@""];
    [self.chatTextField resignFirstResponder];

}
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };

    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dict];
}
-(void)didReceiveDataWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;

    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

    [self.chatWindowTextView performSelectorOnMainThread:@selector(setText:) withObject:[self.chatWindowTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@ said:\n%@\n\n", peerDisplayName, receivedText]] waitUntilDone:NO];
}


#pragma keyboard showed


-(void)keyboardWillShow:(NSNotification*)notification {


    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];

    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    keyboardFrameBeginRect = [self.view convertRect:keyboardFrameBeginRect fromView:nil];

    NSLog(@"%@", NSStringFromCGRect(keyboardFrameBeginRect));
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectMake(0, -(keyboardFrameBeginRect.size.height - 50), self.view.frame.size.width, self.view.frame.size.height);

        self.topConstraint.constant = (keyboardFrameBeginRect.size.height - 30);


    }];
}
-(void)keyboardWillHide {
    // Animate the current view back to its original position
    [UIView animateWithDuration:0.3f animations:^ {

        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
       // self.topConstraint.constant = 17;
    }];
}

@end