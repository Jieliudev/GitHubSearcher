//
//  ConstantsHelper.swift
//  GitHubSearcher
//
//  Created by Peter on 4/19/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import Foundation

enum CellReuseIdentifier {
    static let cell = "cell"
}

enum GSTitle {
    static let naviTitle = "GitHub Searcher"
    static let userSearchBarPlaceHolder = "Search for Users"
    static let repoSearchBarPlaceHolder = "Search for User's Repositories"
}

enum ConstantValue {
    static let cellNibName = "UserTableViewCell"
    static let detailViewController = "DetailViewController"
    static let webViewController = "WebViewController"
    static let main = "Main"
    static let repo = "Repo: "
    static let forks = " Forks"
    static let stars = " Stars"
    static let userName = "UserName: "
    static let email = "Email: "
    static let location = "Location: "
    static let joinDate = "Join Date: "
    static let followers = "Followers: "
    static let following = "Following: "
    static let bio = "Bio: "
    static let ok = "OK"
    static let pageNumber = 30
    static let defaultErrorMsg = "Something Went Wrong"
    static let dataTaskErrorMsg = "Please Slow Down Typing"
}
