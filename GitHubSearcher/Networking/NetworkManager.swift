//
//  NetworkManager.swift
//  GitHubSearcher
//
//  Created by Peter on 4/19/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import Foundation

enum DataTaskError: Error {
    case dataTaskError
    case urlIncorrect
    case requestIsNil
    case statusCodeError
    case decodeError
}

enum RequestUrl {
    static let githubSearchUrl = #"https://api.github.com/search/"#
    static let userProfileUrl = #"https://api.github.com/users/"#
    static let userSearchUrl = #"users?q="#
    static let repoSearchUrl = #"repositories?q="#
    static let userParameter = #"+user:"#
    static let page = #"&page="#
    static let perPage = #"&per_page="#
}

protocol GSURLSessionProtocol {
    /// Fetch Data with request
    /// - Parameters:
    ///   - request: The request which send to backend
    ///   - completionHandler: The closure with Data, URLResponse, Error
    func fetchData(with request: URLRequest,
                   completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: GSURLSessionProtocol {
    
    /// Fetch Data with dataTask
    /// - Parameters:
    ///   - request: The request which send to backend
    ///   - completionHandler: The closure with Data?, URLResponse?, Error?
    /// - Returns: URLSessionDataTask
    func fetchData(with request: URLRequest,
                   completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        let task = dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }
        task.resume()
        return task
    }
}

class NetworkManager {
    
    private let session: GSURLSessionProtocol
    private var userListCallConnection: URLSessionDataTask?
    private var userInfoCallConnection = [URLSessionDataTask?]()
    private var repoListCallConnection: URLSessionDataTask?
    
    init(session: GSURLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    /// Build the reques with URL
    /// - Parameter urlString: The URL String
    /// - Returns: The URL request
    func buildRequest(urlString: String?) -> URLRequest? {
        
        guard let urlString = urlString,
            let url = URL(string: urlString)
            else { return nil }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("token 3ebf340973568af5b06f3ec16df9b3c9f5093f33", forHTTPHeaderField: "Authorization")
        request.addValue("user, repo", forHTTPHeaderField: "scope")
        request.addValue("bearer", forHTTPHeaderField: "token_type")
        return request
    }
    
    /// Get the Model with URLRequest
    /// - Parameters:
    ///   - request: The request which send to backend
    ///   - completionHandler: The result closure with Decoded Model and Error
    /// - Returns: URLSessionDataTask
    func get<T: Codable>(request: URLRequest,
                         completionHandler: @escaping (Result<T, DataTaskError>) -> Void) -> URLSessionDataTask {
        
        let dataTask = session.fetchData(with: request) { (data, response, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                completionHandler(.failure(.dataTaskError))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    completionHandler(.failure(.statusCodeError))
                    return
            }
            
            guard let data = data,
                let result = try? JSONDecoder().decode(T.self, from: data) else {
                    completionHandler(.failure(.decodeError))
                    return
            }
            
            completionHandler(.success(result))
        }
        return dataTask
    }
    
    /// Call the User List network call
    /// - Parameters:
    ///   - searchText: The input to search user name
    ///   - page: The page number
    ///   - handler: The closure with user search result
    func makeUserListCall(searchText: String,
                          page: String?,
                          handler: @escaping (Result<[UserSearchResult], DataTaskError>) -> Void) {
        
        guard let username = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)
            else { return }
        let page = page ?? "1"
        var urlString = RequestUrl.githubSearchUrl + RequestUrl.userSearchUrl
        urlString.append(username)
        urlString.append(RequestUrl.page)
        urlString.append(page)
        urlString.append(RequestUrl.perPage)
        urlString.append("\(ConstantValue.pageNumber)")
        guard let request = buildRequest(urlString: urlString) else { return }
        let connection = get(request: request) { (result: Result<Users, DataTaskError>) in
            switch result {
            case .success(let users):
                let userSearchResults = users.items?.map({ (user) -> UserSearchResult in
                    let userSearchResults = UserSearchResult()
                    userSearchResults.user = user
                    return userSearchResults
                })
                handler(.success(userSearchResults ?? []))
            case .failure(let error):
                handler(.failure(error))
            }
        }
        userListCallConnection = connection
    }
    
    /// Make the user info network call
    /// - Parameters:
    ///   - username: The user name
    ///   - handler: The closure with user info
    func makeUserInfoCall(username: String, handler: @escaping (Result<UserInfo, DataTaskError>) -> Void) {
        var urlString = RequestUrl.userProfileUrl
        urlString.append(username)
        guard let request = buildRequest(urlString: urlString) else { return }
        let connection = get(request: request) { (result: Result<UserInfo, DataTaskError>) in
            switch result {
            case .success(let userInfo):
                handler(.success(userInfo))
            case .failure(let error):
                handler(.failure(error))
            }
        }
        userInfoCallConnection.append(connection)
    }
    
    /// Make the Repositories Search Network call
    /// - Parameters:
    ///   - searchText: The Search text
    ///   - userName: The User name
    ///   - handler: The Result Handler
    func makeRepoSearchCall(searchText: String,
                            userName: String?,
                            handler: @escaping (Result<Repositories?, DataTaskError>) -> Void) {
        guard let searchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) else { return }
        var urlString = RequestUrl.githubSearchUrl + RequestUrl.repoSearchUrl + searchText
        if let userName = userName {
            urlString += RequestUrl.userParameter + userName
        }
        
        guard let request = buildRequest(urlString: urlString) else { return }
        let connection = get(request: request) { (result: Result<Repositories?, DataTaskError>) in
            switch result {
            case .success(let repositories):
                handler(.success(repositories))
            case .failure(let error):
                handler(.failure(error))
            }
        }
        repoListCallConnection = connection
    }
    
    /// Cancel the user search request
    func cancelUserListRequest() {
        userListCallConnection?.cancel()
        userListCallConnection = nil
    }
    
    /// Cancel the User info request
    func cancelUserInfoRequest() {
        userInfoCallConnection.forEach { (dataTask) in
            dataTask?.cancel()
        }
        userInfoCallConnection = []
    }
    
    /// Cancel the repositories search request
    func cancelRepoListRequest() {
        repoListCallConnection?.cancel()
        repoListCallConnection = nil
    }
    
    /// Load the image with URL, if the image is already in the cache, it will fetch from cache
    /// - Parameters:
    ///   - urlString: The URL String
    ///   - handler: The closure with image data
    func loadImages(urlString: String?, handler: @escaping (Data?) -> Void) {
        guard let urlString = urlString else {
            handler(nil)
            return
        }
        if let data = ImageCacheManager.shared.getImageForUrl(urlString: urlString) as Data? {
            handler(data)
            return
        }
        
        if let url = URL(string: urlString) {
            let urlReuqest = URLRequest(url: url)
            _ = session.fetchData(with: urlReuqest) { (data, response, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    handler(nil)
                    return
                }
                handler(data)
            }
        }
    }
}
