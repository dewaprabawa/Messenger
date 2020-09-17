//
//  NewChatViewController.swift
//  Messenger
//
//  Created by Dewa Prabawa on 01/09/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import UIKit
import JGProgressHUD

class NewChatViewController: UIViewController {

    public var completion: (([String:String]) -> Void)?
    
    private let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD(style: .dark)
        return spinner
    }()
    
    private let noChatLabel: UILabel = {
         let label = UILabel()
         label.text = "No Result!"
         label.textAlignment = .center
         label.textColor = .gray
         label.font = .systemFont(ofSize: 21, weight: .medium)
         label.isHidden = true
         return label
     }()
     
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()
    
    private var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var users = [[String:String]]()
    private var result = [[String:String]]()
    private var hasFetched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target:self, action: #selector(dismissSelf))
        navigationController?.navigationBar.topItem?.titleView = searchBar
        view.backgroundColor = .white
        tableviewSetups()
        searchBar.becomeFirstResponder()
    }
    
    private func tableviewSetups(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    @objc private func dismissSelf(){
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Search bar extension
extension NewChatViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        spinner.show(in: view)
        result.removeAll()
        searchQueries(with: text)
    }
    
    ///Check whether user Array has the data from firebase
    private func searchQueries(with query: String){
        
        // if it already has the data in Array from firebase
        if hasFetched {
            // do filter
            filterUsers(with: query)
            spinner.dismiss()
        }else{
            
        // if not then fetch and then filter
            DatabaseManager.shared.downloadUserCollection { [weak self] result in
                
                guard let strongSelf = self else {
                    return
                }
                switch(result){
                case .success(let usersCollection):
                    strongSelf.hasFetched = true
                    strongSelf.users = usersCollection
                    strongSelf.filterUsers(with: query)
                case .failure(let err):
                    strongSelf.spinner.dismiss()
                    print(err)
                }
            }
        }
    }
    
    /// Update the UI whether it has fetched data from firebase or just no result label
   private func filterUsers(with query: String){
        guard hasFetched else {
            return
        }
        
        self.spinner.dismiss()
      
        let result:[[String:String]] = users.filter({
            guard let username = $0["username"]?.lowercased() else {
                return false
            }
            
            return username.hasPrefix(query.lowercased())
        })
        
        self.result = result
        updateUI()
    }
    
    private func updateUI(){
        if result.isEmpty {
            noChatLabel.isHidden = false
            tableView.isHidden = true
        }else{
           noChatLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    
}

//MARK:- New Chat Table view Extension
extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        result.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = result[indexPath.row]["username"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chats = result[indexPath.row]
        dismiss(animated: true, completion: {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.completion?(chats)
        })
    }
    
}
