//
//  AddressesTableViewController.swift
//  UsandoMapKit
//
//  Created by Ana Geórgia Gama on 04/05/21.
//

import UIKit

class AddressesTableViewController: UITableViewController {
    
    var addresses      : [Address] = []
    var selectedAddress: ((Address) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell    = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath)
        let address = addresses[indexPath.row]
        
        cell.textLabel?.text = address.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = addresses[indexPath.row]
        
        selectedAddress!(address)
        
        self.navigationController?.popViewController(animated: true)
    }
}


