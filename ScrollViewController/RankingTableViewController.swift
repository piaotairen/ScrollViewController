//
//  RankingTableViewController.swift
//  ScrollViewController
//
//  Created by Cobb on 2018/5/3.
//  Copyright © 2018年 Cobb. All rights reserved.
//

import UIKit

class RankingTableViewController: UIViewController {
    
    let headerView = ClearHeaderView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kTotalHeaderHeight))
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        tableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.tableHeaderView = headerView
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Table view data source

extension RankingTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = "排行---->>>\(indexPath.row)"
        // Configure the cell...
        
        return cell
    }
}

extension RankingTableViewController: UIScrollViewDelegate {
}
