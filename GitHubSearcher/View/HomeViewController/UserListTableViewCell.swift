//
//  UserListTableViewCell.swift
//  GitHubSearcher
//
//  Created by Peter on 4/18/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import UIKit

final class UserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var repoCountLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        repoCountLabel.text = nil
    }
}
