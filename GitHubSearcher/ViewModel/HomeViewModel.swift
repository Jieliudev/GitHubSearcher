//
//  HomeViewModel.swift
//  GitHubSearcher
//
//  Created by Peter on 4/19/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import Foundation

final class HomeViewModel {
    
    private var userResults: [UserSearchResult]?
    private var currentSearchUserName = ""
    private var currentPage = 1
    private let networkManager = NetworkManager()
    
    /// Get Network Manager in ViewModel
    /// - Returns: NetworkManager
    func getNetworkManager() -> NetworkManager {
        return networkManager
    }
    
    /// Get the User Results Array
    /// - Returns: The User Search Result Array
    func getUserResults() -> [UserSearchResult]? {
        return userResults
    }
    
    /// Get a User Result in userResults
    /// - Parameter index: The index in the array
    /// - Returns: A single result in userResults
    func getUserResult(at index: Int) -> UserSearchResult? {
        guard index < userResults?.count ?? 0 && index >= 0 else { return nil }
        return userResults?[index]
    }
    
    /// Add User Results
    /// - Parameter newResult: The new results
    func addUserResults(newResult: [UserSearchResult]) {
        userResults?.append(contentsOf: newResult)
    }
    
    /// Get the current Search User Name
    /// - Returns: The current Search User Name
    func getCurrentSearchUserName() -> String {
        return currentSearchUserName
    }
    
    /// Set the current User Name
    /// - Parameter newValue: The new User Name
    func setCurrentSearchUserName(_ newValue: String) {
        currentSearchUserName = newValue
    }
    
    /// Get the current Search page
    /// - Returns: the current search page
    func getCurrentPage() -> Int {
        return currentPage
    }
    
    /// Set the Current Page
    /// - Parameter newValue: The new search page
    func setCurrentPage(_ newValue: Int) {
        currentPage = newValue
    }
    
    /// Make the userResults empty
    func resetUserResults() {
        userResults = []
    }
}
