//
//  SettingDetailTableViewCell.swift
//  Todo
//
//  Created by 김지훈 on 2022/04/26.
//

import UIKit

class SettingDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .appRegularFont(14)
        settingSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
}
