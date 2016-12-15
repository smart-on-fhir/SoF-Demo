//
//  EndpointProvider.swift
//  SoF-MedList
//
//  Created by Pascal Pfiffner on 12/3/16.
//  Copyright © 2016 SMART Platforms. All rights reserved.
//

import Foundation
import SMART


public class EndpointProvider {
	
	public var endpoints: [Endpoint]? {
		didSet {
			if nil == activeEndpoint, endpoints?.count ?? 0 > 0 {
				activeEndpoint = endpoints![0]
			}
		}
	}
	
	public private(set) var activeEndpoint: Endpoint?
	
	public func activate(endpoint: Endpoint) {
		if let active = activeEndpoint?.client {
			active.abort()
		}
		activeEndpoint = endpoint
	}
	
	/**
	Forwards to the active endpoint's client instance's `authorize()` method. If the endpoint defines a manual patient selection block,
	takes care of executing the manual selection if `authorize()` does not come back with a patient.
	
	- parameter callback: The block to execute once authorization and patient selection have finished
	*/
	public func selectPatient(callback: @escaping (_ patient: Patient?, _ error: Error?) -> Void) {
		guard let endpoint = activeEndpoint, let smart = endpoint.client else {
			callback(nil, AppError.noActiveEndpoint)
			return
		}
		smart.authorize() { patient, error in
			if nil == error, nil == patient, let manual = endpoint.manualPatientSelect {
				fhir_logIfDebug("Endpoint \(endpoint) did not return a patient after authorization, executing `manualPatientSelect`")
				manual(smart.server, { patient, error in
					callback(patient as? Patient, error)
				})
			}
			else {
				callback(patient, error)
			}
		}
	}
	
	public func cancelPatientSelect() {
		guard let smart = activeEndpoint?.client else {
			return
		}
		smart.abort()
	}
	
	public func availableResourceTypes(for endpoint: Endpoint) -> [Resource.Type] {
		return [
			AllergyIntolerance.self,
			CarePlan.self,
			Condition.self,
			DocumentReference.self,
			Immunization.self,
			MedicationRequest.self,
			//Observation.self,
			Procedure.self,
		]
	}
}


public class Endpoint {
	
	public var client: Client?
	
	public var name: String?
	
	public var manualPatientSelect: ((FHIRServer, @escaping FHIRResourceErrorCallback) -> Void)?
	
	init(client: Client?, name: String? = nil) {
		self.client = client
		self.name = name
	}
}

