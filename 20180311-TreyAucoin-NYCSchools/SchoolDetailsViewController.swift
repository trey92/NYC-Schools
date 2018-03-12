//
//  SchoolInfoViewController.swift
//  20180311-TreyAucoin-NYCSchools
//
//  Created by Trey Aucoin on 3/12/18.
//  Copyright © 2018 Trey Aucoin. All rights reserved.
//

import UIKit

class SchoolDetailsViewController: UIViewController {
    
    private struct SATScores: Decodable {
        let dbn: String
        let num_of_sat_test_takers: String
        let sat_critical_reading_avg_score: String
        let sat_math_avg_score: String
        let sat_writing_avg_score: String
        let school_name: String
    }
    
    @IBOutlet private weak var schoolNameLabel: UILabel!
    @IBOutlet private weak var numberOfTestersLabel: UILabel!
    @IBOutlet private weak var criticalReadingScoreLabel: UILabel!
    @IBOutlet private weak var mathScoreLabel: UILabel!
    @IBOutlet private weak var writingScoreLabel: UILabel!
    @IBOutlet weak var schoolNameActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var readingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var mathActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var writingActivityIndicator: UIActivityIndicatorView!
    
    private let dbn: String
    private let schoolName: String
    
    init(dbn: String, schoolName: String) {
        self.dbn = dbn
        self.schoolName = schoolName
        super.init(nibName: "SchoolDetailsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.dbn = ""
        self.schoolName = ""
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "SAT Scores"
        getSATScores()
    }

    private func getSATScores() {
        
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        if var urlComponents = URLComponents(string: "https://data.cityofnewyork.us/resource/734v-jeq5.json") {
            urlComponents.query = "dbn=\(dbn)"
            
            guard let url = urlComponents.url else { return }
            
            let appToken = "hLpYpOa5cWqJ7fibrDEBmSZWO"
            var request = URLRequest(url: url)
            request.setValue(appToken, forHTTPHeaderField: "X-App-Token")
            
            dataTask = defaultSession.dataTask(with: request) { data, response, error in
                defer { dataTask = nil }
                
                if let data = data {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let satScores = try jsonDecoder.decode([SATScores].self, from: data)
                        
                        guard let satDetails = satScores.first else {
                            self.displayErrorAlert()
                            return
                        }
                        
                        OperationQueue.main.addOperation {
                            self.schoolNameLabel.text = satDetails.school_name
                            self.numberOfTestersLabel.text = "\(satDetails.num_of_sat_test_takers) Test Takers"
                            self.criticalReadingScoreLabel.text = satDetails.sat_critical_reading_avg_score
                            self.mathScoreLabel.text = satDetails.sat_math_avg_score
                            self.writingScoreLabel.text = satDetails.sat_writing_avg_score
                            
                            self.hideActivityIndicators()
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
        let title = "Unable to get SAT scores for \(schoolName)."
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { _ in
                self.getSATScores()
            }
        alert.addAction(tryAgainAction)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func hideActivityIndicators() {
        schoolNameActivityIndicator.stopAnimating()
        readingActivityIndicator.stopAnimating()
        mathActivityIndicator.stopAnimating()
        writingActivityIndicator.stopAnimating()
    }
}
