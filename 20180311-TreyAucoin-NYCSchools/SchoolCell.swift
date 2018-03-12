//
//  SchoolCell.swift
//  20180311-TreyAucoin-NYCSchools
//
//  Created by Trey Aucoin on 3/11/18.
//  Copyright © 2018 Trey Aucoin. All rights reserved.
//

import UIKit

class SchoolCell: UITableViewCell {

    @IBOutlet private weak var schoolNameLabel: UILabel!
    
    func setSchoolName(_ name: String) {
        schoolNameLabel.text = name
    }
    
}
