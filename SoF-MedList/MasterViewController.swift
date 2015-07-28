//
//  MasterViewController.swift
//  SoF-MedList
//
//  Created by Pascal Pfiffner on 6/20/14.
//  Copyright (c) 2014 SMART Platforms. All rights reserved.
//

import UIKit
import SMART


class MasterViewController: UITableViewController
{
	var patient: Patient?
	var previousConnectButtonTitle: String?
	
	var detailViewController: DetailViewController? = nil
	var medications: [MedicationPrescription] = []
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
		    self.clearsSelectionOnViewWillAppear = false
		    self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		connectButtonTitle = nil
		
		if let split = self.splitViewController {
			detailViewController = (split.viewControllers.last as? UINavigationController)?.topViewController as? DetailViewController
		}
	}
	
	
	// MARK: - Custom UI
	
	var connectButtonTitle: String? {
		get { return navigationItem.leftBarButtonItem?.title }
		set {
			let btn = UIBarButtonItem(title: (newValue ?? "Connect"), style: .Plain, target: self, action: "selectPatient:")
			navigationItem.leftBarButtonItem = btn
			previousConnectButtonTitle = btn.title
		}
	}
	
	
	// MARK: - Patient Handling
	@IBAction
	func selectPatient(sender: AnyObject?) {
		if navigationItem.leftBarButtonItem === sender {
			let activity = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
			let barbutton = UIBarButtonItem(customView: activity)		// TODO: doesn't send action!
			barbutton.target = self
			barbutton.action = "cancelPatientSelection:"
			
//			let barbutton = UIBarButtonItem(title: "Abort", style: .Plain, target: self, action: "cancelPatientSelection:")
			navigationItem.leftBarButtonItem = barbutton
			activity.startAnimating()
		}
		
		let app = UIApplication.sharedApplication().delegate as! AppDelegate
		app.selectPatient { patient, error in
			self.patient = patient
			
			if nil != error {
				if NSURLErrorDomain != error!.domain || NSURLErrorCancelled != error!.code {
					UIAlertView(title: "Patient Selection Failed", message: error!.localizedDescription, delegate: self, cancelButtonTitle: "OK").show()
				}
				self.connectButtonTitle = nil
			}
			else if let pat = patient {
				
				// fetch patient's medications
				app.findMeds(pat) { meds, error in
					if nil != error {
						UIAlertView(title: "Error Fetching Meds", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
					}
					else {
						self.medications = meds ?? []
						self.tableView.reloadData()
					}
					
					// finally, change the "connect" button
					if pat.name?.count > 0 && pat.name![0].given?.count > 0 {
						self.connectButtonTitle = pat.name![0].given![0]
					}
					else {
						self.connectButtonTitle = "Unnamed"
					}
				}
			}
			
			// no error and no patient: cancelled
			else {
				self.connectButtonTitle = self.previousConnectButtonTitle
			}
		}
	}
	
	func cancelPatientSelection(sender: AnyObject?) {
		let app = UIApplication.sharedApplication().delegate as! AppDelegate
		app.cancelRecordSelection()
		
		connectButtonTitle = previousConnectButtonTitle
	}
	
	
	// MARK: - Medication Handling
	
	func medicationName(med: MedicationPrescription) -> String {
		if let medname = med.medication?.resolved(Medication)?.name {
			return medname
		}
		if let html = med.text?.div {
			do {
				let stripTags = try NSRegularExpression(pattern: "(<[^>]+>\\s*)|(\\r?\\n)", options: .CaseInsensitive)
				return stripTags.stringByReplacingMatchesInString(html, options: [], range: NSMakeRange(0, html.characters.count), withTemplate: "")
			}
			catch {}
		}
		if let display = med.medication?.display {
			return display
		}
		return "No medication and no narrative"
	}
	
	
	// MARK: - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
		    let indexPath = self.tableView.indexPathForSelectedRow
			if nil != indexPath && indexPath!.row < medications.count {
				((segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController).prescription = medications[indexPath!.row]
			}
		}
	}
	
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return max(1, medications.count)
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
		
		if indexPath.row < medications.count {
			let med = medications[indexPath.row]
			cell.textLabel?.text = medicationName(med)
			cell.textLabel?.textColor = UIColor.blackColor()
			cell.userInteractionEnabled = true
		}
		else {
			cell.textLabel?.text = (nil == patient) ? "" : "(no medications)"
			cell.textLabel?.textColor = UIColor.grayColor()
			cell.userInteractionEnabled = false
		}
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
		    self.detailViewController!.prescription = medications[indexPath.row]
		}
	}
}

