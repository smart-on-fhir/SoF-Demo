//
//  MasterViewController.swift
//  SoF-MedList
//
//  Created by Pascal Pfiffner on 6/20/14.
//  Copyright (c) 2014 SMART Platforms. All rights reserved.
//

import UIKit


class MasterViewController: UITableViewController {
	
	var patient: AnyObject?
	
	var detailViewController: DetailViewController? = nil
	var medications = NSMutableArray()


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
		    let controllers = split.viewControllers
		    self.detailViewController = controllers[controllers.endIndex-1].topViewController as? DetailViewController
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertNewObject(sender: AnyObject) {
		if nil == medications {
		    medications = NSMutableArray()
		}
		medications.insertObject(NSDate.date(), atIndex: 0)
		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
		self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
	}
	
	
	// MARK: - Custom UI
	
	var connectButtonTitle: String? {
	get {
		return navigationItem.leftBarButtonItem?.title
	}
	set(title) {
		let btn = UIBarButtonItem(title: title ? title! : "Connect", style: .Plain, target: self, action: "selectPatient:")
		navigationItem.leftBarButtonItem = btn
	}
	}
	
	
	// MARK: - Patient Handling
	@IBAction
	func selectPatient(sender: AnyObject?) {
		if navigationItem.leftBarButtonItem === sender {
			let activity = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
			let barbutton = UIBarButtonItem(title: "Abort", style: .Plain, target: self, action: "cancelPatientSelect:")
//			let barbutton = UIBarButtonItem(customView: activity)
//			barbutton.target = self
//			barbutton.action = "cancelPatientSelect:"		// TODO: doesn't work?
			navigationItem.leftBarButtonItem = barbutton
			activity.startAnimating()
		}
		
		let app = UIApplication.sharedApplication().delegate as AppDelegate
		app.selectRecord { patient, error in
			if error {
				println(error)
				if NSURLErrorDomain != error!.domain || NSURLErrorCancelled != error!.code {
//					let alert = UIAlertView(title: "Record Selection Failed", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")	// crashes
					let alert = UIAlertView()
					alert.title = "Record Selection Failed"
					alert.message = error!.localizedDescription
					alert.addButtonWithTitle("OK")
					alert.show()
				}
				self.connectButtonTitle = nil
			}
			else if let pat = patient {
				if pat.name?.count > 0 && pat.name![0].given?.count > 0 {
					self.connectButtonTitle = pat.name![0].given![0]
				}
				else {
					self.connectButtonTitle = "Unnamed"
				}
			}
			else {
				let alert = UIAlertView()
				alert.title = "Record Selection Failed"
				alert.message = "Did not receive a record"
				alert.addButtonWithTitle("OK")
				alert.show()
				self.connectButtonTitle = nil
			}
		}
	}
	
	func cancelPatientSelect(sender: AnyObject?) {
		let app = UIApplication.sharedApplication().delegate as AppDelegate
		app.cancelRecordSelection()
		
		connectButtonTitle = nil
	}
	
	
	// #pragma mark - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
		    let indexPath = self.tableView.indexPathForSelectedRow()
		    let object = medications[indexPath.row] as NSDate
		    ((segue.destinationViewController as UINavigationController).topViewController as DetailViewController).detailItem = object
		}
	}
	
	// #pragma mark - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return medications.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

		let object = medications[indexPath.row] as NSDate
		cell.textLabel.text = object.description
		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
		    let object = medications[indexPath.row] as NSDate
		    self.detailViewController!.detailItem = object
		}
	}
}

