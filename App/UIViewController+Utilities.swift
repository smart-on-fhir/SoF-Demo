//
//  UIViewController+Utilities.swift
//  C-Tracker-SCCS
//
//  Created by Pascal Pfiffner on 25.11.16.
//  Copyright © 2016 SCCS. All rights reserved.
//

import UIKit


extension UIViewController {
	
	func show(error: Error, title: String) {
		let msg = (NSCocoaErrorDomain == error._domain) ? error.localizedDescription : "\(error)"
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		present(alert, animated: true)
	}
}
