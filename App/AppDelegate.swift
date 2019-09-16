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
	
	var endpointProvider = EndpointProvider()
	
	func application(_ app: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		let splitViewController = self.window!.rootViewController as! UISplitViewController
		let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.endIndex-1] as! UINavigationController
		splitViewController.delegate = navigationController.topViewController as! DetailViewController
		
		// SMART tint color
		window?.tintColor = UIColor(red:0.41, green:0.14, blue:0.44, alpha:1.0)
		
		// configured endpoints
		endpointProvider.endpoints = configuredEndpoints()
		
		let masterNavi = splitViewController.viewControllers[splitViewController.viewControllers.startIndex] as! UINavigationController 
		let master = masterNavi.topViewController as! MasterViewController
		master.endpointProvider = endpointProvider
		master.detailViewController = navigationController.topViewController as? DetailViewController
		
		return true
	}
	
	// You need this for Safari and Safari Web View Controller to work
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		guard let smart = endpointProvider.activeEndpoint?.client else {
			window?.rootViewController?.show(error: AppError.noActiveEndpoint, title: "Not Set Up")
			return false
		}
		if smart.awaitingAuthCallback {
			return smart.didRedirect(to: url)
		}
		return false
	}
}


enum AppError: Error, CustomStringConvertible {
	case noEndpointProvider
	case noActiveEndpoint
	case noPatientSelected
	
	var description: String {
		switch self {
		case .noEndpointProvider:
			return "No endpoint provider is present, cannot continue"
		case .noActiveEndpoint:
			return "No endpoint (server) has been selected yet, please do that first"
		case .noPatientSelected:
			return "No patient has been selected, please do that first"
		}
	}
}

