//
//  Endpoints.swift
//  SoF-MedList
//
//  Created by Pascal Pfiffner on 12/5/16.
//  Copyright © 2016 SMART Platforms. All rights reserved.
//

import Foundation
import SMART


func configuredEndpoints() -> [Endpoint] {
	var endpoints = [Endpoint]()
	
	let hspc = Client(
		baseURL: URL(string: "https://api3.hspconsortium.org/fhirconnect14/open")!,
		settings: [
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			])
	hspc.authProperties.granularity = .patientSelectNative
	hspc.authProperties.embedded = true
	endpoints.append(Endpoint(client: hspc, name: "HSPC"))
	
	let hapi = Client(
		baseURL: URL(string: "https://fhirtest.uhn.ca/baseDstu3")!,
		settings: [
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			])
	hapi.authProperties.granularity = .patientSelectNative
	hapi.authProperties.embedded = true
	endpoints.append(Endpoint(client: hapi, name: "HAPI Public"))
	
	// Grahame's test server
	let grahame = Client(
		baseURL: URL(string: "http://fhir3.healthintersections.com.au/open")!,
		settings: [
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			])
	grahame.authProperties.granularity = .patientSelectNative
	grahame.authProperties.embedded = true
	endpoints.append(Endpoint(client: grahame, name: "Health Intersections"))
	
	// SMART DSTU-2!! sandbox
	// Credentials obtained by registering on the SMART website
	let smart = Client(
		baseURL: URL(string: "https://fhir-api-dstu2.smarthealthit.org")!,
		settings: [
			"client_id": "my_mobile_app",
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			])
	smart.authProperties.granularity = .patientSelectNative
	smart.authProperties.embedded = true
	endpoints.append(Endpoint(client: smart, name: "SMART"))

	return endpoints
}

