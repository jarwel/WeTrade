//
//  AppDelegate.m
//  WeTrade
//
//  Created by Jason Wells on 1/22/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "IIViewDeckController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "HomeViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"UNHnBc0u6JDIJWWoD3BhcyWoRHv8vwLxq8RMtaee" clientKey:@"bHDHQsHitqfTVJzuEUC22roOU6At1XfUoc1XAxAd"];
    //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.window.rootViewController = self.currentViewController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signIn) name:LoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOut) name:LogoutNotification object:nil];
    return YES;
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    
    if (username && password && username.length != 0 && password.length != 0) {
        return YES;
    }
    
    NSString *title = @"Log In Error";
    NSString *message = @"Please fill out all of the information.";
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    return NO;
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        NSString *title = @"Log In Error";
        NSString *message = @"Please fill out all of the information.";
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginNotification object:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginNotification object:nil];
    [user setObject:[user.username lowercaseString] forKey:@"canonicalUsername"];
    [user saveInBackground];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSString *title = @"Log In Error";
    NSString *message = @"The username or password you provided is not correct.";
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)signIn {
    self.window.rootViewController = self.currentViewController;
}

- (void)signOut {
    [PFUser logOut];
    self.window.rootViewController = self.currentViewController;
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
}

- (UIViewController *)currentViewController {
    if (![PFUser currentUser]) {
        return self.signInViewController;
    }
    return self.homeViewController;
}

- (UIViewController *)signInViewController {
    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    [signUpViewController setDelegate:self];
        
    SignInViewController *signInViewController = [[SignInViewController alloc] init];
    [signInViewController setDelegate:self];
    [signInViewController setSignUpController:signUpViewController];
    return signInViewController;
}

- (UIViewController *)homeViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HomeViewController *homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Home"];
        
    UINavigationController *center = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    UIViewController *left = [storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    UIViewController *right = [storyboard instantiateViewControllerWithIdentifier:@"Following"];
    
    IIViewDeckController *viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController:center leftViewController:left rightViewController:right];
        [viewDeckController setCenterhiddenInteractivity:IIViewDeckCenterHiddenNotUserInteractive];
    homeViewController.viewDeckController = viewDeckController;
    return viewDeckController;
}

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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
