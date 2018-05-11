//
//  ClearHeaderView.swift
//  ScrollViewController
//
//  Created by Cobb on 2018/5/10.
//  Copyright © 2018年 Cobb. All rights reserved.
//

import UIKit

class ClearHeaderView: UIView {

    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    deinit {
        print("...deinit...")
    }

}
