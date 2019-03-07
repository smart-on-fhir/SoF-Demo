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
	
	let hapi = LenientClient(
		baseURL: URL(string: "http://hapi.fhir.org/baseR4")!,
		settings: [
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			])
	hapi.authProperties.granularity = .patientSelectNative
	hapi.authProperties.embedded = true
	endpoints.append(Endpoint(client: hapi, name: "HAPI at fhir.org"))
	
	let hspc = LenientClient(
		baseURL: URL(string: "https://api-v5-r4.hspconsortium.org/testr4/open")!,
		settings: [
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			])
	hspc.authProperties.granularity = .patientSelectNative
	hspc.authProperties.embedded = true
	endpoints.append(Endpoint(client: hspc, name: "HSPC Sandbox"))
	
	let fhirorg = LenientClient(
		baseURL: URL(string: "http://test.fhir.org/r4")!,
		settings: [
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			])
	fhirorg.authProperties.granularity = .patientSelectNative
	fhirorg.authProperties.embedded = true
	endpoints.append(Endpoint(client: fhirorg, name: "Test at FHIR.org"))
	
	return endpoints
}

