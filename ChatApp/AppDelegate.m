//
//  AppDelegate.m
//  ChatApp
//
//  Created by S on 11/4/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.mcManager = [[MCManager alloc] init];
    
    [Parse setApplicationId:@"F9mKwa3Ng5enu1SvdwTaLGL3GWV1cxw2yC9VwQNE" clientKey:@"8JHfymvHKdlcCPkVGoGAg2y04ApldGqCC6WLbKQY"];
    [PFFacebookUtils initializeFacebook];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];

//    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
//
//        // If there's one, just open the session silently, without showing the user the login UI
//        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
//                                           allowLoginUI:NO
//                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//                                          // Handler for session state changes
//                                          // This method will be called EACH time the session state changes,
//                                          // also for intermediate states and NOT just when the session open
//                                          [self sessionStateChanged:session state:state error:error];
//                                      }];
//    }
    return YES;
}



-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [PFPush handlePush:userInfo];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];

    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFUser *user = [PFUser currentUser];
    NSString *userID = [NSString stringWithFormat:@"%@", user];

    [currentInstallation addUniqueObject:userID forKey:@"channels"];
     currentInstallation[@"User"] = [PFUser currentUser];
//    if ([PFUser currentUser]) //&& ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
//    {
//        currentInstallation[@"User"] = [PFUser currentUser];
//        
//    }

    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);

}

// This method will handle ALL the session state changes in the app
//- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
//{
//    // If the session was opened successfully
//    if (!error && state == FBSessionStateOpen){
//        NSLog(@"Session opened");
//        // Show the user the logged-in UI
//        [self userLoggedIn];
//        return;
//    }
//    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
//        // If the session is closed
//        NSLog(@"Session closed");
//        // Show the user the logged-out UI
//        [self userLoggedOut];
//    }
//
//    // Handle errors
//    if (error){
//        NSLog(@"Error");
//        NSString *alertText;
//        NSString *alertTitle;
//        // If the error requires people using an app to make an action outside of the app in order to recover
//        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
//            alertTitle = @"Something went wrong";
//            alertText = [FBErrorUtility userMessageForError:error];
//            [self showMessage:alertText withTitle:alertTitle];
//        } else {
//
//            // If the user cancelled login, do nothing
//            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
//                NSLog(@"User cancelled login");
//
//                // Handle session closures that happen outside of the app
//            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
//                alertTitle = @"Session Error";
//                alertText = @"Your current session is no longer valid. Please log in again.";
//                [self showMessage:alertText withTitle:alertTitle];
//
//                // Here we will handle all other errors with a generic error message.
//                // We recommend you check our Handling Errors guide for more information
//                // https://developers.facebook.com/docs/ios/errors/
//            } else {
//                //Get more error information from the error
//                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
//
//                // Show the user an error message
//                alertTitle = @"Something went wrong";
//                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
//                [self showMessage:alertText withTitle:alertTitle];
//            }
//        }
//        // Clear this token
//        [FBSession.activeSession closeAndClearTokenInformation];
//        // Show the user the logged-out UI
//        [self userLoggedOut];
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.viandryan.ChatApp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ChatApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ChatApp.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
