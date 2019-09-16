//
//  ResourceListViewController.swift
//  SoF-MedList
//
//  Created by Pascal Pfiffner on 12/3/16.
//  Copyright © 2016 SMART Platforms. All rights reserved.
//

import UIKit
import SMART


class ResourceListViewController: UITableViewController {
	
	var resources: [Resource]? {
		didSet {
			if let first = resources?.first {
				self.title = type(of: first).resourceType
			}
		}
	}
	
	var detailViewController: DetailViewController? = nil
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(ResourceCell.self, forCellReuseIdentifier: "ResourceCell")
	}
	
	
	// MARK: - UITableViewDataSource
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return resources?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell", for: indexPath)
		let resource = resources![indexPath.row]
		
		if let allergyInstance = resource as? AllergyIntolerance {
			if let allergyName: String = allergyInstance.code?.displayString() {
				cell.textLabel?.text = allergyName
			} else {
				cell.textLabel?.text = "Allergy"
			}
			
			if let allergyReaction: String = allergyInstance.reaction?.first?.manifestation?.first?.displayString() {
				cell.detailTextLabel?.text = "Reaction: " + allergyReaction
			} else {
				cell.detailTextLabel?.text = "Reaction Type Unknown"
			}
		}
			
		else if let conditionInstance = resource as? Condition {
			if let conditionName: String = conditionInstance.code?.displayString() {
				cell.textLabel?.text = conditionName
			} else {
				cell.textLabel?.text = "Condition"
			}
			
			if let conditionDate: DateTime = conditionInstance.onsetDateTime {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .none
				cell.detailTextLabel?.text = "Date of onset: " + dateFormatter.string(from: conditionDate.nsDate)
			} else {
				cell.detailTextLabel?.text = "Date of onset: Unknown"
			}
		}
			
		else if let carePlanInstance = resource as? CarePlan {
			// TODO: in STU3 final, use .title
			if let displayName: String = carePlanInstance.description_fhir?.string {
				cell.textLabel?.text = displayName
			} else {
				cell.textLabel?.text = "Care Plan"
			}
			
			if let period = carePlanInstance.period {
				cell.detailTextLabel?.text = period.displayString()
			}
		}
			
		else if let careTeamInstance = resource as? CareTeam {
			if let displayName: String = careTeamInstance.name?.string {
				cell.textLabel?.text = displayName
			} else {
				cell.textLabel?.text = "Care Team"
			}
			
			if let participants = careTeamInstance.participant {
				cell.detailTextLabel?.text = participants.count.description + " participants"
			}
		}
			
		else if let diagnosticReportInstance = resource as? DiagnosticReport {
			if let displayName: String = diagnosticReportInstance.code?.displayString() {
				cell.textLabel?.text = displayName
			} else {
				cell.textLabel?.text = "Diagnostic Report"
			}
			
			if let effectiveDate: DateTime = diagnosticReportInstance.effectiveDateTime {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .none
				cell.detailTextLabel?.text = "Effective date: " + dateFormatter.string(from: effectiveDate.nsDate)
			} else {
				cell.detailTextLabel?.text = "Effective date: Unknown"
			}
		}
			
		else if let documentInstance = resource as? DocumentReference {
			if let documentName: String = documentInstance.type?.displayString() {
				cell.textLabel?.text = documentName
			} else if let documentName: String = documentInstance.description_fhir?.string {
				cell.textLabel?.text = documentName // For Cerner
			} else {
				cell.textLabel?.text = "Document"
			}
			
			if let documentDate: FHIRDate = documentInstance.date?.date {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .none
				cell.detailTextLabel?.text = "Document date: " + dateFormatter.string(from: documentDate.nsDate)
			} else {
				cell.detailTextLabel?.text = "Document Date Unknown"
			}
		}
			
		else if let goalInstance = resource as? Goal {
			if let displayName: String = goalInstance.description_fhir?.displayString() {
				cell.textLabel?.text = displayName
			} else {
				cell.textLabel?.text = "Goal"
			}
			
			if let goalDate: FHIRDate = goalInstance.startDate {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .none
				cell.detailTextLabel?.text = "Achieve by: " + dateFormatter.string(from: goalDate.nsDate)
			}
			else {
				cell.detailTextLabel?.text = "Unknown Target Date"
			}
		}
			
		else if let immunizationInstance = resource as? Immunization {
			if let immunizationName: String = immunizationInstance.vaccineCode?.displayString() {
				cell.textLabel?.text = immunizationName
			} else if let immunizationName: String = immunizationInstance.vaccineCode?.text?.string {
				cell.textLabel?.text = immunizationName
			} else {
				cell.textLabel?.text = "Immunization"
			}
			
			if let immunizationDate: DateTime = immunizationInstance.occurrenceDateTime {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .none
				cell.detailTextLabel?.text = "Performed on: " + dateFormatter.string(from: immunizationDate.nsDate)
			} else {
				cell.detailTextLabel?.text = "Performed: Unknown Date"
			}
		}
			
		else if let medRequest = resource as? MedicationRequest {
			if let medName: String = medRequest.medicationCodeableConcept?.displayString() {
				cell.textLabel?.text = medName
			} else if let medName: String = medRequest.medicationReference?.display?.string { // For Epic
				cell.textLabel?.text = medName
			} else {
				cell.textLabel?.text = "Medication"
			}
			
			if let medStatus: String = medRequest.status?.rawValue {
				cell.detailTextLabel?.text = "Status: " + medStatus
			} else {
				cell.detailTextLabel?.text = "Status Not Available"
			}
		}
			
		else if let observationInstance = resource as? Observation {
			if let observationValue: String = observationInstance.valueQuantity?.value?.description {
				let units = observationInstance.valueQuantity?.unit?.string ?? "(no units)"
				cell.textLabel?.text = "\(observationValue) \(units)"
			} else if let observationValue: String = observationInstance.valueString?.string {
				cell.textLabel?.text = observationValue
			} else {
				cell.textLabel?.text = "Value Not Available"
			}
			
			if let observationName: String = observationInstance.code?.displayString() {
				cell.detailTextLabel?.text = observationName
			} else {
				cell.detailTextLabel?.text = "Observation"
			}
		}
			
		else if let procedureInstance = resource as? Procedure {
			if let procedureName: String = procedureInstance.code?.displayString() {
				cell.textLabel?.text = procedureName
			} else {
				cell.textLabel?.text = "Procedure"
			}
			
			if let procedureDate: DateTime = procedureInstance.performedDateTime {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .short
				cell.detailTextLabel?.text = "Performed: " + dateFormatter.string(from: procedureDate.nsDate)
			} else {
				cell.detailTextLabel?.text = "Performed: Unknown Date"
			}
		}
			
		else if let serviceRequestInstance = resource as? ServiceRequest {
			if let displayName: String = serviceRequestInstance.code?.displayString() {
				cell.textLabel?.text = displayName
			} else {
				cell.textLabel?.text = "Service Request"
			}
			
			if let requestStatus: String = serviceRequestInstance.status?.rawValue {
				cell.detailTextLabel?.text = "Status: " + requestStatus
			} else {
				cell.detailTextLabel?.text = "Status Not Available"
			}
		}
			
		else {
			cell.textLabel?.text = "\(type(of: resource).resourceType) \(indexPath.row)"
			cell.detailTextLabel?.text = try? resource.relativeURLPath()
		}
		
		return cell
	}
	
	
	// MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let detailViewController = detailViewController {
			detailViewController.resource = resources?[indexPath.row]
			if splitViewController?.isCollapsed ?? true {
				navigationController?.pushViewController(detailViewController, animated: true)
			}
		}
	}
}


class ResourceCell: UITableViewCell {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

