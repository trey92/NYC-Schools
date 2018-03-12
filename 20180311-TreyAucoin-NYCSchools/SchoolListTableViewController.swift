//
//  ViewController.swift
//  20180311-TreyAucoin-NYCSchools
//
//  Created by Trey Aucoin on 3/11/18.
//  Copyright © 2018 Trey Aucoin. All rights reserved.
//

import UIKit

class SchoolListTableViewController: UITableViewController {
    
    private struct SchoolsResponse: Decodable {
        let dbn: String
        let school_name: String
    }
    
    private var schools: [SchoolsResponse] = []
    private var activityIndicator: UIActivityIndicatorView!
    private var activityBackgroundView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        createAndShowActivityIndicator()
        getSchools()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "schoolCell") as? SchoolCell else {
            return UITableViewCell()
        }
        
        let school = schools[indexPath.row]
        
        cell.setSchoolName(school.school_name)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSchool = schools[indexPath.row]
        let schoolDetailsVC = SchoolDetailsViewController(dbn: selectedSchool.dbn, schoolName: selectedSchool.school_name)
        
        navigationController?.pushViewController(schoolDetailsVC, animated: true)
    }

    private func getSchools() {
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        if var urlComponents = URLComponents(string: "https://data.cityofnewyork.us/resource/97mf-9njv.json") {
            urlComponents.query = "$select=dbn,school_name"
            
            guard let url = urlComponents.url else { return }
            
            let appToken = "hLpYpOa5cWqJ7fibrDEBmSZWO"
            var request = URLRequest(url: url)
            request.setValue(appToken, forHTTPHeaderField: "X-App-Token")
            
            dataTask = defaultSession.dataTask(with: request) { data, response, error in
                defer { dataTask = nil }
                
                if let data = data {
                    do {
                        let jsonDecoder = JSONDecoder()
                        self.schools = try jsonDecoder.decode([SchoolsResponse].self, from: data)
                        
                        OperationQueue.main.addOperation {
                            self.tableView.reloadData()
                            self.hideActivityIndicator()
                        }
                    
                    } catch { self.displayErrorAlert() }
                    
                } else {
                    self.displayErrorAlert()
                }
            }
            
            dataTask?.resume()
        }
    }
    
    private func displayErrorAlert() {
        let title = "There was an error getting the list of schools in NYC."
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { _ in
            self.showActivityIndicator()
            self.getSchools()
        }
        alert.addAction(tryAgainAction)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true, completion: nil)
            self.hideActivityIndicator()
        }
    }

    private func createAndShowActivityIndicator() {
        activityBackgroundView = UIView(frame: tableView.frame)
        activityBackgroundView.backgroundColor = UIColor.gray
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.center = activityBackgroundView.center
        
        view.addSubview(activityBackgroundView)
        activityBackgroundView.addSubview(activityIndicator)
        
        showActivityIndicator()
    }
    
    private func showActivityIndicator() {
        activityIndicator.startAnimating()
        activityBackgroundView.isHidden = false
    }
    
    private func hideActivityIndicator() {
        activityBackgroundView.isHidden = true
        activityIndicator.stopAnimating()
    }

}

