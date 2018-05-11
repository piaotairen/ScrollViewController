//
//  ViewController.swift
//  ScrollViewController
//
//  Created by Cobb on 2018/5/2.
//  Copyright © 2018年 Cobb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let delegate = InteractiveTransitionMaker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        
        let vc1 = storyBoard.instantiateViewController(withIdentifier: "RankingTableViewController") as! RankingTableViewController
        let vc2 = storyBoard.instantiateViewController(withIdentifier: "RankingTableViewController") as! RankingTableViewController
        let vc3 = storyBoard.instantiateViewController(withIdentifier: "RankingTableViewController") as! RankingTableViewController
        let rootViewController = ScrollTabBarViewController(viewControllers: [vc1, vc2, vc3], titles: ["昨日排行", "月排行", "总排行"], icons: ["icon_down_arrow", "icon_down_arrow", ""], selectedIcons: ["icon_up_arrow", "icon_up_arrow", ""])
        rootViewController.containerTransitionDelegate = delegate
        rootViewController.view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        rootViewController.view.backgroundColor = .white
        view.addSubview(rootViewController.view)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

