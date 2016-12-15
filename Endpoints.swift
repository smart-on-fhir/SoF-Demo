//
//  Endpoints.swift
//  SoF-MedList
//
//  Created by Pascal Pfiffner on 12/5/16.
//  Copyright © 2016 SMART Platforms. All rights reserved.
//

import SMART


func configuredEndpoints() -> [Endpoint] {
	var endpoints = [Endpoint]()
	
	// SMART sandbox
	// Credentials obtained by registering on the SMART website
	let smart = Client(
		baseURL: "https://fhir-api-dstu2.smarthealthit.org",
		settings: [
			"client_id": "my_mobile_app",
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			])
	smart.authProperties.granularity = .patientSelectNative
	smart.authProperties.embedded = true
	endpoints.append(Endpoint(client: smart, name: "SMART"))
	
	// Allscripts
	// Credentials: jmedici, password01
	let allscripts = Client(
		baseURL: "https://cloud.allscriptsunity.com/FHIRAnon",
		settings: [
			"client_id": "A648964B-7134-4A28-8B96-ECBF94FB97A7",
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"authorize_uri": "https://cloud.allscriptsunity.com/authorization/connect/authorize",
			"token_uri": "https://cloud.allscriptsunity.com/authorization/connect/token",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			])
	allscripts.authProperties.granularity = .patientSelectWeb
	allscripts.authProperties.embedded = true
	allscripts.server.logger = OAuth2DebugLogger(.trace)
	let epAllscripts = Endpoint(client: allscripts, name: "Allscripts")
	epAllscripts.manualPatientSelect = { server, callback in
		Patient.read("19", server: server, callback: callback)
	}
	endpoints.append(epAllscripts)
	
	// CareEvolution
	// Credentials: CEPatient, CEPatient2016
	let careevolution = Client(
		baseURL: "https://fhir.careevolution.com/Master.Adapter1.WebClient/api/fhir",
		settings: [
			"client_id": "AEA75A2D-82F0-415E-921F-2316B4C034AB",
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			"verbose": true,
			]
	)
	careevolution.authProperties.granularity = .patientSelectWeb
	careevolution.authProperties.embedded = true
	endpoints.append(Endpoint(client: careevolution, name: "CareEvolution"))
	
	// Cerner
	// Credentials: ??
	let cerner = Client(
		baseURL: "https://fhir-open.sandboxcernerpowerchart.com/dstu2/d075cf8b-3261-481d-97e5-ba6c48d3b41f",
		settings: [
			"client_id": "my_web_app",
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			"verbose": true,
			]
	)
	cerner.authProperties.granularity = .patientSelectWeb
	cerner.authProperties.embedded = true
	let epCerner = Endpoint(client: cerner, name: "Cerner")
	epCerner.manualPatientSelect = { server, callback in
		Patient.read("1316020", server: server, callback: callback)
	}
	endpoints.append(epCerner)
	
	// Epic (open.epic.com)
	// Credentials: fhirjason, epicepic1
	let epic = Client(
		baseURL: "https://open-ic.epic.com/Argonaut/api/FHIR/Argonaut/",
		settings: [
			"client_id": "51bb8b5f-a90d-4c5b-8313-bf295546291c", // Epic non-prod client ID
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			])
	epic.authProperties.granularity = .patientSelectWeb
	epic.authProperties.embedded = true
	endpoints.append(Endpoint(client: epic, name: "Epic"))
	
	// ONC
	// Credentials: pp:TestTest8
	// Registration token: LSXPKUEAOo3jVNiFJZuDEqHBbIE7SEHyj91aHZPnhEaL8siInAzNUCqiCijpxjxQrF8XHdDng2X6KnEQt8WhKlnC0CZrqWMJWSAeaiG-4mo4deqYAFQuLor53zKUf7qOuihNrzanpALoyYLGt8zZlEmYyx0zXvUazGOw3XJ5d8weso3lF2PL8aSWUdmtOBfKkIV9EpoknxNXNKJ91YzG6y7gtGVjd4ZDYH8ivXgpJWaNPBCiarLaB5aWzu
	let onc = Client(
		baseURL: "https://fhir.sitenv.org/secure/fhir",
		settings: [
			"client_id": "lSbGfY95XUeXrF5uSx4GbeF2708mUY",
			"client_secret": "cTlRbmFJZW9YZGF6clhFOXVCNFplSUJFVDBQRnlhano2Q2N1U3JOejR5bEJVd2I5Mm0=",
			"secret_in_body": true,
			"client_name": "SMART on FHIR iOS Sample App",
			"redirect": "smartapp://callback",
			"logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
			"scope" : "user/*.*",
			])
	onc.authProperties.granularity = .patientSelectNative
	onc.authProperties.embedded = true
	onc.server.logger = OAuth2DebugLogger(.trace)
	let oncEP = Endpoint(client: onc, name: "ONC")
//	onc.authProperties.granularity = .patientSelectWeb
//	oncEP.manualPatientSelect = { server, callback in
//		Patient.read("2", server: server, callback: callback)    // needed because the server returns the patient id as int, not string
//	}
	endpoints.append(oncEP)
	
	return endpoints
}

