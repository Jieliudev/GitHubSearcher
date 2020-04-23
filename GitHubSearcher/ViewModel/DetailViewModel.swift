//
//  DetailViewModel.swift
//  GitHubSearcher
//
//  Created by Peter on 4/19/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import Foundation

final class DetailViewModel {
    
    private let networkManager = NetworkManager()
    private var userResult: UserSearchResult?
    private var repoArray: Repositories?
    
    init(userResult: UserSearchResult?) {
        self.userResult = userResult
    }
    
    /// Get Network Manager in ViewModel
    /// - Returns: NetworkManager
    func getNetworkManager() -> NetworkManager {
        return networkManager
    }
    
    /// Get User Search Result
    /// - Returns: The User Search Reuslt
    func getUserResult() -> UserSearchResult? {
        return userResult
    }
    
    /// Set the User Search Result
    /// - Parameter newValue: The new User Search Result
    func setUserSearchResult(_ newValue: UserSearchResult?) {
        userResult = newValue
    }
    
    /// Get the Repositories Array
    /// - Returns: The Repositories Array
    func getRepoArray() -> Repositories? {
        return repoArray
    }
    
    /// Set the new  Repositories Array
    /// - Parameter newValue:  The new Repositories Array
    func setRepoArray(_ newValue: Repositories?) {
        repoArray = newValue
    }
    

}
