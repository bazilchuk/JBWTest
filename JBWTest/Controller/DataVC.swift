//
//  DataVC.swift
//  JBWTest
//
//  Created by Andrew on 25.04.2018.
//  Copyright © 2018 Andrew. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class DataVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func fetchTextButton(_ sender: Any) {
        
        view.addSubview(self.activityIndicator)
        
        user.fetchData { (message, success, text) in
            self.dismissActivityIndicator(activityIndicator: self.activityIndicator)
            
            if success {
                self.results = self.countChars(text: text)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        view.addSubview(self.activityIndicator)
        
        user.logout { (message, success) in
            self.dismissActivityIndicator(activityIndicator: self.activityIndicator)
            
            if success {
                KeychainWrapper.standard.removeObject(forKey: "accessToken")
                
                DispatchQueue.main.async {
                    let loginView = self.storyboard?.instantiateViewController(withIdentifier: "LoginTVC") as! LoginTVC
                    let appDelegate = UIApplication.shared.delegate
                    appDelegate?.window??.rootViewController = loginView
                }
            } else {
                self.displayAlert(message: message)
            }
        }
    }

    lazy var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    let user = APIClient()
    
    var results = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.rowHeight = 45
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = false
        activityIndicator.startAnimating()
    }

    func dismissActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    // MARK: - Working with String
    
    func countChars(text: String) -> [String] {
        let spell = text
        var frequencies: [Character: Int] = [:]
        var results: [String] = []
        let baseCounts = zip(spell.map { $0 }, repeatElement(1, count: Int.max))
        frequencies = Dictionary(baseCounts, uniquingKeysWith: +)
        for (symbol, occurace) in frequencies {
            results.append("\' \(symbol) \' - \(occurace) times")
        }
        
        return results
    }
    
    // MARK: - Alert
    
    func displayAlert(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

    // MARK: - Table View

extension DataVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! UITableViewCell
        
        cell.textLabel?.text = results[indexPath.row]
        
        return cell
    }
}

