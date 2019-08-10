//
//  MasterViewController.swift
//  SoF-MedList
//
//  Created by Pascal Pfiffner on 6/20/14.
//  Copyright (c) 2014 SMART Platforms. All rights reserved.
//

import UIKit
import SMART


class ResourceType {
	let type: Resource.Type
	var resources: [Resource]?
	var error: Error?
	
	init(type: Resource.Type) {
		self.type = type
	}
}


class MasterViewController: UITableViewController {
	
	var endpointProvider: EndpointProvider?
	
	var patient: Patient? {
		didSet {
			if (patient?.name?[0].given?.count ?? 0) > 0 {
				self.connectButtonTitle = patient!.name![0].given![0].string
			}
			else {
				self.connectButtonTitle = (nil == patient) ? nil : "Unnamed"
			}
		}
	}
	
	var resourceTypes: [ResourceType] = [] {
		didSet {
			if isViewLoaded { tableView.reloadData() }
		}
	}
	
	var previousConnectButtonTitle: String?
	var detailViewController: DetailViewController?
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		if UIDevice.current.userInterfaceIdiom == .pad {
			self.clearsSelectionOnViewWillAppear = false
			self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		didSelectEndpoint()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Clear the detail view for iPad when no longer in context
		detailViewController?.detailDescriptionLabel?.text = nil
	}
	
	
	// MARK: - Custom UI
	
	var connectButtonTitle: String? {
		get { return navigationItem.leftBarButtonItem?.title }
		set {
			let btn = UIBarButtonItem(title: (newValue ?? "Connect"), style: .plain, target: self, action: #selector(MasterViewController.selectPatient(_:)))
			btn.isEnabled = (nil != endpointProvider?.activeEndpoint?.client)
			navigationItem.leftBarButtonItem = btn
			previousConnectButtonTitle = btn.title
		}
	}
	
	func spinningBarButtonItem() -> UIBarButtonItem {
		let activity = spinningSpinner()
		let button = UIButton(frame: activity.bounds)
		button.addSubview(activity)
		button.addConstraint(NSLayoutConstraint(item: activity, attribute: .centerX, relatedBy: .equal, toItem: button, attribute: .centerX, multiplier: 1.0, constant: 0.0))
		button.addConstraint(NSLayoutConstraint(item: activity, attribute: .centerY, relatedBy: .equal, toItem: button, attribute: .centerY, multiplier: 1.0, constant: 0.0))
		button.addTarget(self, action: #selector(MasterViewController.cancelPatientSelection), for: .touchUpInside)
		
		return UIBarButtonItem(customView: button)
	}
	
	func spinningSpinner() -> UIActivityIndicatorView {
		let activity = UIActivityIndicatorView(style: .gray)
		activity.isUserInteractionEnabled = false
		activity.startAnimating()
		return activity
	}
	
	
	// MARK: - Endpoint Handling
	
	@IBAction
	func selectEndpoint(_ sender: AnyObject?) {
		guard let provider = endpointProvider else {
			show(error: AppError.noEndpointProvider, title: "No Endpoint Provider")
			return
		}
		
		let vc = EndpointListViewController()
		vc.endpoints = provider.endpoints
		vc.onEndpointSelect = { endpoint in
			DispatchQueue.main.async() {
				if let endpoint = endpoint {
					provider.activate(endpoint: endpoint)
					self.didSelectEndpoint()
				}
				self.navigationItem.leftBarButtonItem?.isEnabled = (nil != provider.activeEndpoint?.client)
				self.dismissModal()
			}
		}
		
		let navi = UINavigationController(rootViewController: vc)
		navi.modalPresentationStyle = UIModalPresentationStyle.formSheet
		vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MasterViewController.dismissModal))
		present(navi, animated: true)
	}
	
	func didSelectEndpoint() {
		patient = nil
		guard let endpoint = endpointProvider?.activeEndpoint else {
			title = "No Endpoint"
			return
		}
		title = endpoint.name ?? "Unnamed Endpoint"
		resourceTypes = endpointProvider?.availableResourceTypes(for: endpoint).map() { return ResourceType(type: $0) } ?? []
	}
	
	
	// MARK: - Patient Handling
	
	@IBAction
	func selectPatient(_ sender: AnyObject?) {
		guard let provider = endpointProvider else {
			show(error: AppError.noActiveEndpoint, title: "Not Set Up Yet")
			return
		}
		if navigationItem.leftBarButtonItem === sender {
			navigationItem.leftBarButtonItem = spinningBarButtonItem()
		}
		
		provider.selectPatient() { patient, error in
			DispatchQueue.main.async() {
				if let error = error {
					switch error {
					case OAuth2Error.requestCancelled:   break
					case let e where NSURLErrorDomain == e._domain && NSURLErrorCancelled == e._code:   break
					default:                             self.show(error: error, title: "Not Authorized")
					}
					self.connectButtonTitle = nil
				}
				
				// no error and a patient, perfect!
				else if let patient = patient {
					self.patient = patient
					self.loadResources()
				}
					
				// no error and no patient: cancelled
				else {
					self.connectButtonTitle = self.previousConnectButtonTitle
				}
			}
		}
	}
	
	@objc func cancelPatientSelection() {
		endpointProvider?.cancelPatientSelect()
		connectButtonTitle = previousConnectButtonTitle
	}
	
	
	// MARK: - Resource Handling
	
	func loadResources() {
		guard let endpoint = endpointProvider?.activeEndpoint, let smart = endpoint.client, let patientId = patient?.id else {
			fhir_logIfDebug("No active endpoint or no valid `patient`, cannot fetch resources")
			return
		}

		// reset resourceTypes, including error and resources for each type
		resourceTypes = endpointProvider?.availableResourceTypes(for: endpoint).map() { return ResourceType(type: $0) } ?? []
		
		// load all resources of the desired types for our patient
		var i = 0
		for resType in resourceTypes {
			let ii = i
			resType.type.search(["patient": patientId.string]).perform(smart.server) { bundle, error in
				if nil != error {
					resType.error = error
				}
				else {
					// TODO: for whatever mystic reason, simply passing "resType.type" into `entries(ofType:)` converts everything to `Resource`
					// Have experimented with making `ResourceType` a protocol with associated type, to no avail
					//print("===>  Want type \(resType.type) [\(resType.type.resourceType)]")
					resType.resources = bundle?.entries(ofType: resType.type, typeName: resType.type.resourceType) ?? []
				}
				DispatchQueue.main.async() {
					self.tableView.reloadRows(at: [IndexPath(row: ii, section: 0)], with: .none)
				}
			}
			i += 1
		}
	}
	
	
	// MARK: - Table View
	
	override func numberOfSections(in: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return resourceTypes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
		
		let resType = resourceTypes[indexPath.row]
		cell.textLabel?.text = resType.type.resourceType
		if let resources = resType.resources {
			cell.textLabel?.textColor = .black
			cell.detailTextLabel?.text = "\(resources.count)"
			cell.accessoryView = nil
			cell.accessoryType = .disclosureIndicator
			cell.selectionStyle = .default
		}
		else if let error = resType.error {
			cell.textLabel?.textColor = .red
			cell.detailTextLabel?.text = "⚠️"
			cell.accessoryView = nil
			cell.accessoryType = .none
			NSLog("Error Loading \(resType.type.resourceType): \(error)")
		}
		else {
			cell.textLabel?.textColor = .gray
			cell.detailTextLabel?.text = nil
			cell.accessoryView = (nil == patient) ? nil : spinningSpinner()
			cell.accessoryType = .none
			cell.selectionStyle = .none
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let resType = resourceTypes[indexPath.row]
		if let error = resType.error {
			show(error: error, title: "Error Loading \(resType.type.resourceType)")
		} else {
			let vc = ResourceListViewController()
			vc.detailViewController = detailViewController
			vc.resources = resourceTypes[indexPath.row].resources
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	
	// MARK: - Generic
	
	@objc func dismissModal() {
		dismiss(animated: true)
	}	
}

