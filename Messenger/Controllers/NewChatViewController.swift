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

    private let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD(style: .dark)
        return spinner
    }()
    
    private let noChatLabel: UILabel = {
         let label = UILabel()
         label.text = "No Chat!"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target:self, action: #selector(dismissSelf))
        navigationController?.navigationBar.topItem?.titleView = searchBar
        // Do any additional setup after loading the view.
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

extension NewChatViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}


extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    
}
