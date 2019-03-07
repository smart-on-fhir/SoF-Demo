//
//  Bundle+Utilities.swift
//  SoF-MedList
//
//  Created by Pascal Pfiffner on 12/3/16.
//  Copyright © 2016 SMART Platforms. All rights reserved.
//

import SMART


extension SMART.Bundle {
	
	/**
	Loop over the Bundle's `entry` and return all resources of the desired type.
	
	Note: This does only work when passing in hardcoded types, if passing in `T.Type` from some other classes' property always simply checks
	against `Resource`.
	*/
	func entries<T: Resource>(ofType type: T.Type) -> [T]? {
		//print("===>  Filtering for type \(T.self) [\(T.resourceType)]")
		return entry?.filter() { return $0.resource is T }.map() { return $0.resource as! T }
	}
	
	/**
	Workaround for the issue mentioned in `entries(ofType:)` - checks against the string representation in `T.Type.resourceType`.
	*/
	func entries<T: Resource>(ofType type: T.Type, typeName name: String) -> [Resource]? {
		//print("===>  Filtering for type \(T.self) [\(name)]")
		return entry?.filter() { return nil != $0.resource && Swift.type(of: $0.resource!).resourceType == name }.map() { return $0.resource! }
	}
}
