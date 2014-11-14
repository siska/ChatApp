//
//  ViewController.m
//  ChatApp
//
//  Created by S on 11/4/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "RootViewController.h"
#import "Friend.h"
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

    if (![PFUser currentUser]) //&& ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {

        [self addFacebookLoginButton];
    }
    else
    {
        [self performSegueWithIdentifier:@"FromLogIn" sender:self];
    }
}

-(void)addFacebookLoginButton{
    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), (self.view.center.y - (loginView.frame.size.height / 2)));
    [loginView setDelegate:self];
    [self.view addSubview:loginView];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setTintColor:[UIColor blackColor]];
    [indicator startAnimating];
    [self.view addSubview:indicator];
    [self loggedInSendFBinfoToParse];

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
        } 






        else {
            
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




-(void)requestForFBFriends
{   NSLog(@"requestForFBFriends received request");
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
    {
        if (!error)
        {   // result will contain an array with your user's friends in the "data" key
            NSArray *friendsObjects = [result objectForKey:@"data"];
            for (NSDictionary *friend in friendsObjects)
            {
                PFQuery *queryForUser = [PFQuery queryWithClassName:@"_User"];
                [queryForUser whereKey:@"FacebookID" equalTo:[friend objectForKey:@"id"]];
                [queryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                 {
                     if (error)
                     {
                         NSLog(@"Error: %@", error.userInfo);
                     }
                     else
                     {
                         PFRelation *relationship = [[PFUser currentUser] relationForKey:@"friends"];
                         for (PFUser *friendInArray in objects)
                         {
                             [relationship addObject:friendInArray];
                         }
                         [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                          {
                              if (error)
                              {
                                  NSLog(@"Error: %@", [error userInfo]);
                              }
                          }];
                     }
                     //[self saveAllContactsForUserToParse];
                 }];
            }
        }
    }];
}


//                -(void)saveAllContactsForUserToParse
//                {
//                    PFRelation *relationship = [[PFUser currentUser] relationForKey:@"friends"];
//
//                    for (PFObject *contact in self.allUsers)
//                    {
//                        [relationship addObject:contact];
//                    }
//
//                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//                     {
//                         if (error)
//                         {
//                             NSLog(@"Error: %@", [error userInfo]);
//                         }
//                     }];
//                    self.currentUserWithRelations = [PFUser currentUser];
//                    [self queryForContacts];
//                }
//
//
//                Contact *friend = [Contact object];
//                friend.name = [friendObject objectForKey:@"name"];
//                friend.fbID = [friendObject objectForKey:@"id"];
//                friend.lastName = [friendObject objectForKey:@"last_name"];
//                friend.firstName = [friendObject objectForKey:@"first_name"];
//                friend.email = [[Contact object ]objectForKey:@"email"];
//                friend.friendOf.username = [[PFUser currentUser]objectForKey:@"name"];
//
//
//
//                PFQuery *friendQuery = [PFUser query];
//                [friendQuery whereKey:@"id" containedIn:friendsObjects];
//                NSLog(@"QUACK: %@", friendsObjects);
//                self.friendsObjectArray = [NSArray arrayWithObject:friendsObjects];
//                NSString *userID = [[friendsObjects firstObject] objectForKey:@"id"];
////                NSString *userURL = [[NSString stringWithFormat:@"/%@/friends",userID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//                NSLog(@"Hello: %@",userID);
//              //  PFRelation *relationship = [[PFUser currentUser] relationForKey:@"contacts"];
//
//                [friend saveInBackground];
//            }
//            
//        }
//    }];
//}


#pragma mark - Delegate Methods
-(void)facebookLoginViewController:(PFLogInViewController *)facebookLoginController didLogInUser:(PFUser *)user{
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"FromLogIn" sender:self];
    }];

}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"FromLogIn" sender:self];
    }];
}


- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}
//
//- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
//    [self dismissViewControllerAnimated:YES completion:^{
//        [self performSegueWithIdentifier:@"FromLogIn" sender:self];
//    }]; // Dismiss the PFSignUpViewController
//

@end
