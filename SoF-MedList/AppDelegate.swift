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
class AppDelegate: UIResponder, UIApplicationDelegate
{
	var window: UIWindow?
	
	lazy var smart: Client = Client(
		baseURL: "https://fhir-api-dstu2.smarthealthit.org",
		settings: [
//			"client_id": "my_mobile_app",
			"client_name": "SMART on FHIR iOS Medication Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
//			"keychain": false,
		]
	)
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
		if NSString(string: UIDevice.currentDevice().systemVersion).doubleValue >= 8.0 {			// there is `UISplitViewController` on iOS 7 but not for iPhone
			let splitViewController = self.window!.rootViewController as! UISplitViewController
			let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.endIndex-1] as! UINavigationController
			splitViewController.delegate = navigationController.topViewController as! DetailViewController
		}
		return true
	}
	
	
	// MARK: - SMART Tasks
	
	func selectPatient(callback: (patient: Patient?, error: ErrorType?) -> Void) {
		smart.authProperties.embedded = true
//		smart.authProperties.granularity = .PatientSelectWeb
		smart.authProperties.granularity = .PatientSelectNative
		smart.authorize(callback)
	}
	
	func cancelRecordSelection() {
		smart.abort()
	}
	
	func findMeds(patient: Patient, callback: ((meds: [MedicationOrder]?, error: FHIRError?) -> Void)) {
		if let id = patient.id {
			MedicationOrder.search(["patient": id]).perform(smart.server) { bundle, error in
				if nil != error {
					dispatch_async(dispatch_get_main_queue()) {
						callback(meds: nil, error: error)
					}
				}
				else {
					let meds = bundle?.entry?
						.filter() { return $0.resource is MedicationOrder }
						.map() { return $0.resource as! MedicationOrder }
					dispatch_async(dispatch_get_main_queue()) {
						callback(meds: meds, error: nil)
					}
				}
			}
		}
		else {
			callback(meds: nil, error: FHIRError.Error("Patient does not have a local id"))
		}
	}
	
	// You would need this if you were opting to not use an embedded web view
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		if smart.awaitingAuthCallback {
			return smart.didRedirect(url)
		}
		return false
	}
}

