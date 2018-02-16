//
//  PositionCell.swift
//  user_list_view
//
//  Created by Eri on 11/2/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit

class PositionCell: UICollectionViewCell
{
    var pos: Position? {
        didSet{
            positionLabel.text = pos?.positionName
        }
    }
    
    let positionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .superLightColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(positionLabel)
        positionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        positionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12)
        positionLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        positionLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
