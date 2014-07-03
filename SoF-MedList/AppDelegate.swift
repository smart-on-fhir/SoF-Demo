//
//  AppDelegate.swift
//  SoF-MedList
//
//  Created by Pascal Pfiffner on 6/20/14.
//  Copyright (c) 2014 SMART Platforms. All rights reserved.
//

import UIKit
import SMART


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
	var window: UIWindow?
	
	@lazy var smart = Client(
		serverURL: "https://fhir-api.smartplatforms.org",
		clientId: "my_mobile_app",
		redirect: "smartapp://callback"
	)
	
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
		// Override point for customization after application launch.
		let splitViewController = self.window!.rootViewController as UISplitViewController
		let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.endIndex-1] as UINavigationController
		splitViewController.delegate = navigationController.topViewController as DetailViewController
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	
	// MARK: - SMART Tasks
	
	func selectRecord(callback: (record: Patient?, error: NSError?) -> ()) {
		smart.authorize(callback)
	}
	
	func cancelRecordSelection() {
		smart.abort()
	}
	
	func application(application: UIApplication!, openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {
		if smart.authorizing {
			return smart.didRedirect(url)
		}
		return false
	}
}

