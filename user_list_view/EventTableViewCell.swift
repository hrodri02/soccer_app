//
//  EventTableViewCell.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/6/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    // MARK: properties
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var organizerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
