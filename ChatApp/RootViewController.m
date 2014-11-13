//
//  ViewController.m
//  ChatApp
//
//  Created by S on 11/4/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "RootViewController.h"
#import "FacebookFriend.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface RootViewController ()
@property NSArray *friendsObjectArray;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (![PFUser currentUser])
    {

//        // No user logged in
//        // Create the log in view controller
//        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
//        [logInViewController setDelegate:self]; // Set ourselves as the delegate
//
//        // Create the sign up view controller
//        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
//        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
//
//        [logInViewController setSignUpController:signUpViewController];
////        PFLogInViewController *facebookLoginViewController = [[PFLogInViewController alloc]init];
////        [facebookLoginViewController setDelegate:self];

        FBLoginView *loginView = [[FBLoginView alloc] init];
        loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), (self.view.center.y - (loginView.frame.size.height / 2)));
        [loginView setDelegate:self];
        [self.view addSubview:loginView];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicator setTintColor:[UIColor blackColor]];
        [indicator startAnimating];
        [self.view addSubview:indicator];
        [self loggedInSendFBinfoToParse];
//        [logInViewController setFacebookPermissions:@[ @"public_profile", @"email", @"user_location", @"user_friends"]];
//        [logInViewController setFields:PFLogInFieldsDismissButton|PFLogInFieldsDefault| PFLogInFieldsFacebook];


  //      [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    else
    {
        [self performSegueWithIdentifier:@"FromLogIn" sender:self];
    }
}

-(IBAction)unwindFromLogOut:(UIStoryboardSegue *)sender
{
    [PFUser logOut];
}
#pragma mark - Add Facebook Login

-(void)loggedInSendFBinfoToParse{
    // Align the button in the center horizontally

      // Set permissions required from the facebook user account, you can find more about facebook permissions here https://developers.facebook.com/docs/facebook-login/permissions/v2.0
    NSArray *permissionsArray = @[ @"public_profile", @"email", @"user_location", @"user_friends"];

    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {

        NSLog(@"HI: %@", error);


        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                //                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                //                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSLog(@"FOOBILES2 %@", error);
                if (!error) {
                    @try {
                        NSLog(@"Result: %@", result);
                        [[PFUser currentUser]setObject:[result objectForKey:@"id"] forKey:@"FacebookID"];
                        [[PFUser currentUser]setObject:[result objectForKey:@"name"] forKey:@"Name"];
                        [[PFUser currentUser]setObject:[result objectForKey:@"email"] forKey:@"Email"];
                        [[PFUser currentUser]setObject:[result objectForKey:@"last_name"] forKey:@"LastName"];
                        [[PFUser currentUser]setObject:[result objectForKey:@"first_name"] forKey:@"FirstName"];


                        [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"FOOBILES %@", error);
                        }];

                    [self performSegueWithIdentifier:@"FromLogIn" sender:self];
                    } @catch (id e) {
                        NSLog(@"%@", e);
                    }
                }
            }];
        }

        [self requestForFBFriends];

    }];
}




-(void)requestForFBFriends{


    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendsObjects = [result objectForKey:@"data"];

            for (NSDictionary *friendObject in friendsObjects) {
                FacebookFriend *friend = [FacebookFriend object];
                friend.name = [friendObject objectForKey:@"name"];
                friend.fbID = [friendObject objectForKey:@"id"];
                friend.lastName = [friendObject objectForKey:@"last_name"];
                friend.firstName = [friendObject objectForKey:@"first_name"];
                friend.email = [[FacebookFriend object ]objectForKey:@"email"];
                friend.friendOf.username = [[PFUser currentUser]objectForKey:@"name"];
                PFQuery *friendQuery = [PFUser query];
                [friendQuery whereKey:@"id" containedIn:friendsObjects];
                NSLog(@"QUACK: %@", friendsObjects);
                self.friendsObjectArray = [NSArray arrayWithObject:friendsObjects];
                NSString *userID = [[friendsObjects firstObject] objectForKey:@"id"];
//                NSString *userURL = [[NSString stringWithFormat:@"/%@/friends",userID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

                NSLog(@"Hello: %@",userID);
                [friend saveInBackground];
                
            }
            
        }
    }];
}



#pragma mark - Delegate Methods
-(void)facebookLoginViewController:(PFLogInViewController *)facebookLoginController didLogInUser:(PFUser *)user{
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"FromLogIn" sender:self];
    }];

}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }

    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"FromLogIn" sender:self];
    }];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

//// Sent to the delegate to determine whether the sign up request should be submitted to the server.
//- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
//    BOOL informationComplete = YES;
//
//    // loop through all of the submitted data
//    for (id key in info) {
//        NSString *field = [info objectForKey:key];
//        if (!field || field.length == 0) { // check completion
//            informationComplete = NO;
//            break;
//        }
//    }
//
//    // Display an alert if a field wasn't completed
//    if (!informationComplete) {
//        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
//                                    message:@"Make sure you fill out all of the information!"
//                                   delegate:nil
//                          cancelButtonTitle:@"ok"
//                          otherButtonTitles:nil] show];
//    }
//
//    return informationComplete;
//}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"FromLogIn" sender:self];
    }]; // Dismiss the PFSignUpViewController

}

//// Sent to the delegate when the sign up attempt fails.
//- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
//    NSLog(@"Failed to sign up...");
//}
//
//// Sent to the delegate when the sign up screen is dismissed.
//- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
//    NSLog(@"User dismissed the signUpViewController");
//}

@end
