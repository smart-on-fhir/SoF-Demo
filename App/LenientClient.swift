//
//  LenientClient.swift
//  CareGuide
//
//  Created by Dave Carlson on 1/14/19.
//  Copyright © 2019 Clinical Cloud Solutions, LLC. All rights reserved.
//

import Foundation
import SMART

/**
A client that defaults to lenient validation, where JSON validation errors are tolerated when receiving a response,
i.e. don't throw upon instantiation, use what's provided.
*/
public class LenientClient: Client {
	
	/// Which options to apply.
	open var options: FHIRRequestOption = .lenient
	
	public convenience init(baseURL: URL, settings: OAuth2JSON) {
		var sett = settings
		if let redirect = settings["redirect"] as? String {
			sett["redirect_uris"] = [redirect]
		}
		if nil == settings["title"] {
			sett["title"] = "SMART"
		}
		let srv = LenientServer(baseURL: baseURL, auth: sett)
		self.init(server: srv)
	}
	
	/**
	Request a JSON resource at the given path from the client's server.
	
	- parameter path:     The path relative to the server's base URL to request
	- parameter callback: The callback to execute once the request finishes
	*/
	override public func getJSON(at path: String, callback: @escaping ((_ response: FHIRServerJSONResponse) -> Void)) {
		let handler = FHIRJSONRequestHandler(.GET)
		handler.options = options
		server.performRequest(against: path, handler: handler, callback: { response in
			callback(response as! FHIRServerJSONResponse)
		})
	}
	
}

/**
A server that defaults to lenient validation, where JSON validation errors are tolerated when receiving a response,
i.e. don't throw upon instantiation, use what's provided.
*/
public class LenientServer: Server {
	
	/// Which options to apply.
	open var options: FHIRRequestOption = .lenient
	
	/**
	The server can return the appropriate request handler for the type and resource combination.
	
	Request handlers are responsible for constructing an URLRequest that correctly performs the desired REST interaction.
	
	- parameter method:   The request method (GET, PUT, POST or DELETE)
	- parameter resource: The resource to be involved in the request, if any
	
	- returns:            An appropriate `FHIRRequestHandler`, for example a _FHIRJSONRequestHandler_ if sending and receiving JSON
	*/
	override public func handlerForRequest(withMethod method: FHIRRequestMethod, resource: Resource?) -> FHIRRequestHandler? {
		let handler = FHIRJSONRequestHandler(method, resource: resource)
		handler.options = options
		return handler
	}
	
}
