//
//  ExperienceCell.swift
//  user_list_view
//
//  Created by Eri on 11/3/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit

class ExperienceCell: UICollectionViewCell
{
    var exp: Experience? {
        didSet{
            experienceLabel.text = exp?.years
        }
    }
    
    let experienceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .superLightColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(experienceLabel)
        experienceLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        experienceLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12)
        experienceLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        experienceLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

