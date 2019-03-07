//
//  EndpointListViewController.swift
//  SoF-MedList
//
//  Created by Pascal Pfiffner on 12/3/16.
//  Copyright © 2016 SMART Platforms. All rights reserved.
//

import UIKit
import SMART


class EndpointListViewController: UITableViewController {
	
	var endpoints: [Endpoint]?
	
	var onEndpointSelect: ((Endpoint?) -> Void)?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Endpoints"
		self.tableView.register(EndpointCell.self, forCellReuseIdentifier: "Endpoint")
	}
	
	
	// MARK: - UITableViewDataSource
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return endpoints?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Endpoint", for: indexPath)
		if indexPath.row < endpoints?.count ?? 0 {
			let endpoint = endpoints![indexPath.row]
			cell.textLabel?.text = endpoint.name ?? "Unnamed"
			cell.detailTextLabel?.text = endpoint.client?.server.baseURL.absoluteString
            //cell.imageView?.image = UIImage(named: endpoint.name!)
		}
		return cell
	}
	
	
	// MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard indexPath.row < endpoints?.count ?? 0 else {
			return
		}
		let endpoint = endpoints![indexPath.row]
		onEndpointSelect?(endpoint)
	}
}


class EndpointCell: UITableViewCell {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

