//
//  AppDelegate.m
//  WeTrade
//
//  Created by Jason Wells on 1/22/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "Constants.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "HomeViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) SignInViewController *signInViewController;
@property (nonatomic, strong) IIViewDeckController *homeNavigationController;

@end

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
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
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
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginNotification object:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginNotification object:nil];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

- (void)signIn {
    self.window.rootViewController = self.currentViewController;
}

- (void)signOut {
    [PFUser logOut];
    self.window.rootViewController = self.currentViewController;
}

- (UIViewController *)currentViewController {
    if (![PFUser currentUser]) {
        return self.signInViewController;
    }
    return self.homeNavigationController;
}

- (UIViewController *)signInViewController {
    if (!_signInViewController) {
        SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        
        _signInViewController = [[SignInViewController alloc] init];
        [_signInViewController setDelegate:self];
        [_signInViewController setSignUpController:signUpViewController];
    }
    return _signInViewController;
}

- (UIViewController *)homeNavigationController {
    if (!_homeNavigationController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
        
        HomeViewController *homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Home"];
        UIViewController* leftViewController = [storyboard instantiateViewControllerWithIdentifier:@"Settings"];
        UIViewController* rightViewController = [storyboard instantiateViewControllerWithIdentifier:@"Favorites"];
        
        UINavigationController *centerViewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        
        _homeNavigationController = [[IIViewDeckController alloc] initWithCenterViewController:centerViewController leftViewController:leftViewController rightViewController:rightViewController];
    }
    return _homeNavigationController;
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
