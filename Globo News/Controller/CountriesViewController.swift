//
//  CountriesViewController.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/8/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import FlagKit
import CoreData
import ViewAnimator

class CountriesViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Countries and loaded countries arrays
    var countries = [Country]()
    var loadedCountries = [Country]()
    
    // Core data shared data controller
    var dataController = DataController.shared
    
    // Display animations
    let animations = [AnimationType.from(direction: .bottom, offset: 100.0)]
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the navigation bar buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "addCountryIcon"), style: .plain, target: self, action: #selector(addCountry))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit" , style: .plain, target: self, action: #selector(editCountries))
        
    }
    
    // MARK: View will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableCountries()
    }
    
    // handle editing countries presented in the table
    @objc func editCountries() {
        if self.tableView.isEditing != true {
            changeTableEditingState(state: true, title: "Done")
        }
        else {
            changeTableEditingState(state: false, title: "Edit")
        }
    }
    
    // Present the Country selection view data controller
    @objc func addCountry() {
        var controller = CountrySelectionViewController()
        controller = storyboard?.instantiateViewController(withIdentifier: "CountrySelectionController") as! CountrySelectionViewController
        controller.isEditingCountries = true
        present(controller,animated: true,completion: nil)
    }
    
    // MARK: Helper methods
    
    // change table editing mode and left button title
    func changeTableEditingState(state: Bool,title: String){
        self.tableView.isEditing = state
        self.navigationItem.leftBarButtonItem?.title = title
    }
    
    // Reloads the saved countries from core data to the table and refresh the table data
    func reloadTableCountries() {
        let fetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
        fetchRequest.sortDescriptors = []
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            countries = result
        }
        self.tableView.reloadData()
        UIView.animate(views: tableView.visibleCells, animations: animations, completion: {
            self.tableView.reloadData()
        })
    }
}

// An extention that handles the countries table behavior
extension CountriesViewController: UITableViewDelegate , UITableViewDataSource {
    
    // MARK: Delegate Methods
    
    // Number of table rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let countryCell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) 
        
        let countryName = countries[indexPath.row]
        countryCell.textLabel?.text = countryName.country
        countryCell.imageView?.image = Flag(countryCode: "\(Countries(rawValue: countryName.country!)!)".uppercased())?.image(style: .circle)
        countryCell.selectionStyle = UITableViewCell.SelectionStyle.none
        return countryCell
    }
    
    // Handle table editing style
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    
    // Handle when a country is deleted and save changes
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if countries.count > 1 {
                let countryToDelete = countries[indexPath.row]
                dataController.viewContext.delete(countryToDelete)
                if dataController.viewContext.hasChanges {
                    try? dataController.viewContext.save()
                }
                countries.remove(at: indexPath.row)
                tableView.reloadData()
            } else {
                showError(controller: self, title: "", message: "You must have at least 1 Country Selected")
                changeTableEditingState(state: false, title: "Edit")
            }
        }
    }
}
