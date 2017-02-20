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
    
    let careplan1 = Client(
        baseURL: URL(string: "https://api3.hspconsortium.org/careplan1/open")!,
        settings: [
            "client_name": "SMART on FHIR iOS Sample App",
            "redirect": "smartapp://callback",
            "logo_uri": "https://avatars1.githubusercontent.com/u/7401080",
            ])
    careplan1.authProperties.granularity = .patientSelectNative
    careplan1.authProperties.embedded = true
    endpoints.append(Endpoint(client: careplan1, name: "HSPC Care Plan"))
    
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
	
	return endpoints
}

