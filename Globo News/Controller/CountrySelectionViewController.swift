//
//  CountrySelectionViewController.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/13/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import FlagKit
import CoreData

class CountrySelectionViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var countrySelectionButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    // core data controller
    var dataController = DataController.shared
    
    // Countries , selected countries and loaded countries arrays
    var countries = [String]()
    var selectedCountries = [String]()
    var loadedCountries = [Country]()
    
    // Editing Flag
    var isEditingCountries = false
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSelectionTable()
    }
    
    // MARK: View will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        try? dataController.viewContext.save()
    }
    
    // Handle Done button action
    // Add selected countries to persistent store and save changes
    @IBAction func DoneSelection(_ sender: UIButton) {
        for currentCountry in selectedCountries {
            let country = Country(context: dataController.viewContext)
            country.country = currentCountry
            countries.append(country.country!)
        }
        if dataController.viewContext.hasChanges {
            try? dataController.viewContext.save()
        }
        if isEditingCountries {
            dismiss(animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "GetStarted", sender: self)
        }
    }
}

// An extention that handles the countries selection table behavior
extension CountrySelectionViewController: UITableViewDelegate , UITableViewDataSource {
    
    // MARK: Delegate Methods
    
    // Number of table rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    // Fill the table cells with the loaded country names and flag images
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let countryCell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        
        let countryName = countries[indexPath.row]
        countryCell.textLabel?.text = countryName
        countryCell.imageView?.image = Flag(countryCode: "\(Countries(rawValue: countryName)!)".uppercased())?.image(style: .circle)
        
        return countryCell
    }
    
    // Handles countries selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCountries.append(countries[indexPath.row])
        changeDoneButtonState()
    }
    
    // Handles countries deselection
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedCountries.remove(at: selectedCountries.firstIndex(of: countries[indexPath.row])!)
        changeDoneButtonState()
    }
    
    // Helper methods
    
    // A helper method that sets up the countries selection table
    func setupSelectionTable() {
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = true
        countrySelectionButton.alpha = (isEditingCountries) ? 1 : 0.5
        let fetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
        fetchRequest.sortDescriptors = []
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            loadedCountries = result
            countries = Countries.allCases.map {$0.rawValue}
            for loadedCountry in loadedCountries {
                selectedCountries.append(loadedCountry.country!)
            }
            countries = countries.filter{ !selectedCountries.contains($0)}
            selectedCountries.removeAll()
            tableView.reloadData()
        }
        
        if isEditingCountries {
            welcomeLabel.isHidden = true
            countrySelectionButton.setTitle("Done", for: .normal)
        }
    }
    
    // A helper method that change Done button state according to the editing flag
    func changeDoneButtonState() {
        if selectedCountries.count > 0 {
            countrySelectionButton.isEnabled = (isEditingCountries) ? true : true
            countrySelectionButton.alpha = (isEditingCountries) ? 1 : 1
        } else {
            countrySelectionButton.isEnabled = (isEditingCountries) ? true : false
            countrySelectionButton.alpha = (isEditingCountries) ? 1 : 0.5
        }
    }
}
