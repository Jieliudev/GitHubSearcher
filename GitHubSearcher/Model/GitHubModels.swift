//
//  GitHubModels.swift
//  GitHubSearcher
//
//  Created by Peter on 4/19/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import Foundation

class UserSearchResult {
    var user: User?
    var userInfo: UserInfo?
    var imageData: Data?
}

struct Users: Codable {
    var totalCount: Int?
    var items: [User]?

    init(totalCount: Int? = nil,
         items: [User]? = nil) {
        self.totalCount = totalCount
        self.items = items
    }

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

struct User: Codable {
    var login: String?
    var avatarUrl: String?
    var reposUrl: String?

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
        case reposUrl = "repos_url"
    }
}

struct UserInfo: Codable {
    var login: String?
    var email: String?
    var location: String?
    var createdAt: String?
    var followers: Int?
    var following: Int?
    var bio: String?
    var publicRepos: Int?

    enum CodingKeys: String, CodingKey {
        case login, email, location
        case followers, following, bio
        case createdAt = "created_at"
        case publicRepos = "public_repos"
    }
}

struct Repositories: Codable {
    var items: [Repository]?

    enum CodingKeys: String, CodingKey {
        case items
    }
}

struct Repository: Codable {
    var htmlUrl: String?
    var forks: Int?
    var stargazersCount: Int?
    var name: String?

    enum CodingKeys: String, CodingKey {
        case forks, name
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
    }
}

struct RepoDetails: Codable {
    var name: String?
}
