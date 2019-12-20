//
//  CountryListController.swift
//  NewStartPart
//
//  Created by tongyi on 7/9/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit
import PhoneNumberKit

class CountryListController: UITableViewController {
    
    var countries: [Country] = []
    var phoneNumberKit = PhoneNumberKit()
    var input: TYInput!
    
    init(from input: TYInput) {
        super.init(nibName: nil, bundle: nil)
        self.input = input
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        setup()
    }
    
    private func setup() {
        title = "Country List"
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "arrow_back"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.setLeftBarButton(leftBarButton, animated: false)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CountryCell")
        
        fillCountries()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        let country = countries[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = country.fullNameAndCodeString()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        let country = countries[indexPath.row]
        input.country = country
    }
    
    private func fillCountries() {
        let pairs = getCountryShortAndFullNamePairs()
        
        for (fullName, shortName) in pairs {
            if let code = phoneNumberKit.countryCode(for: shortName) {
                countries.append(Country(code: Int(code), fullName: fullName, shortName: shortName))
            }
        }
    }
    
    private func getCountryShortAndFullNamePairs() -> [(String, String)] {
        
        guard let path = Bundle.main.path(forResource: "countries", ofType: nil) else {
            return []
        }
        
        var countryPair: [(String, String)] = []
        
        if let contents = try? String(contentsOfFile: path, encoding: .utf8) {
            let countries = contents.components(separatedBy: .newlines)
            
            for country in countries {
                let countryItem = country.components(separatedBy: "----")
                if countryItem.count == 2 {
                    countryPair.append((countryItem[0], countryItem[1]))
                }
            }
        }
        
        return countryPair
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print(#function)
    }
}
