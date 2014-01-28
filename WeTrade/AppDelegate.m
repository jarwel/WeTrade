//
//  AppDelegate.m
//  WeTrade
//
//  Created by Jason Wells on 1/22/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "HomeViewController.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController *mainNavigationController;
@property (nonatomic, strong) UINavigationController *homeNavigationController;
@property (nonatomic, strong) UIViewController *currentViewController;

//- (void)updateRootViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"UNHnBc0u6JDIJWWoD3BhcyWoRHv8vwLxq8RMtaee" clientKey:@"bHDHQsHitqfTVJzuEUC22roOU6At1XfUoc1XAxAd"];
    //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.window.rootViewController = self.currentViewController;
    
    return YES;
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

- (UIViewController *)currentViewController {
    if ([PFUser currentUser]) {
        return self.homeNavigationController;
    }
    return self.mainNavigationController;
}

- (UINavigationController *)mainNavigationController {
    if (! _mainNavigationController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainViewController *mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"Main"];
        _mainNavigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    }
    return _mainNavigationController;
}

- (UINavigationController *)homeNavigationController {
    if (! _homeNavigationController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
        HomeViewController *homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Home"];
        _homeNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    }
    return _homeNavigationController;
}

@end
