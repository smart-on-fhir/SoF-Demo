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
	
	lazy var smart = Client(
		baseURL: "https://fhir-api-dstu2.smarthealthit.org",
		settings: [
			"client_id": "my_mobile_app",
			"redirect": "smartapp://callback",
		]
	)
	
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
		if NSString(string: UIDevice.currentDevice().systemVersion).doubleValue >= 8.0 {			// there is `UISplitViewController` on iOS 7 but not for iPhone
			let splitViewController = self.window!.rootViewController as UISplitViewController
			let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.endIndex-1] as UINavigationController
			splitViewController.delegate = navigationController.topViewController as DetailViewController
		}
		return true
	}
	
	
	// MARK: - SMART Tasks
	
	func selectPatient(callback: (patient: Patient?, error: NSError?) -> Void) {
		smart.authProperties.embedded = true
		smart.authProperties.granularity = .PatientSelectNative
		smart.authorize(callback)
	}
	
	func cancelRecordSelection() {
		smart.abort()
	}
	
	func findMeds(patient: Patient, callback: ((meds: [MedicationPrescription]?, error: NSError?) -> Void)) {
		if let id = patient.id {
			MedicationPrescription.search(["patient": id]).perform(smart.server) { bundle, error in
				if nil != error {
					callback(meds: nil, error: error)
				}
				else {
					var meds = [MedicationPrescription]()
					if let entries = bundle?.entry {
						for entry in entries {
							if let med = entry.resource as? MedicationPrescription {
								meds.append(med)
							}
						}
					}
					callback(meds: meds, error: nil)
				}
			}
		}
		else {
			callback(meds: nil, error: genSMARTError("Patient does not have a local id"))
		}
	}
	
	/*/ You would need this if you were opting to not use an embedded web view
	func application(application: UIApplication!, openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {
		if smart.awaitingAuthCallback {
			return smart.didRedirect(url)
		}
		return false
	}	//	*/
}

