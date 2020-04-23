//
//  HomeViewController.swift
//  GitHubSearcher
//
//  Created by Peter on 4/18/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import UIKit

final class HomeViewController: UIViewController {
    @IBOutlet weak var userNameSearchBar: UISearchBar!
    @IBOutlet weak var userListTableView: UITableView!
    
    var viewModel: HomeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = HomeViewModel()
        setupUserListTableView()
        setupSearchBar()
        title = GSTitle.naviTitle
    }

    func setupUserListTableView() {
        userListTableView.delegate = self
        userListTableView.dataSource = self
    }
    
    func setupSearchBar() {
        userNameSearchBar.placeholder = GSTitle.userSearchBarPlaceHolder
        userNameSearchBar.delegate = self
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getUserResults()?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.cell, for: indexPath) as? UserListTableViewCell,
            let viewModel = viewModel
            else { return UITableViewCell() }
        cell.selectionStyle = .none
        let userResult = viewModel.getUserResult(at: indexPath.row)
        let username = userResult?.user?.login
        let avatarUrl = userResult?.user?.avatarUrl

        cell.usernameLabel.text = username
        viewModel.getNetworkManager().loadImages(urlString: avatarUrl, handler: { data in
            guard let data = data else { return }
            userResult?.imageData = data
            DispatchQueue.main.async {
                cell.avatarImageView.image = UIImage(data: data)
            }
        })
        
        if userResult?.userInfo != nil {
            cell.repoCountLabel.text = ConstantValue.repo + "\(userResult?.userInfo?.publicRepos ?? 0)"
        } else {
            viewModel.getNetworkManager().makeUserInfoCall(username: username ?? "") { (result) in
                switch result {
                case .success(let userInfo):
                    userResult?.userInfo = userInfo
                    DispatchQueue.main.async {
                        cell.repoCountLabel.text = ConstantValue.repo + "\(userInfo.publicRepos ?? 0)"
                    }
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    self.showAlert(error: error)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: ConstantValue.main, bundle: nil)
        let detailViewController = storyboard.instantiateViewController(identifier: ConstantValue.detailViewController) as DetailViewController
        let userResult = viewModel?.getUserResult(at: indexPath.row)
        let detailViewModel = DetailViewModel(userResult: userResult)
        detailViewController.bindViewModel(detailViewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        let currentPage = viewModel.getCurrentPage()
        if indexPath.row == (ConstantValue.pageNumber - 1) * currentPage {
            let searchUserName = viewModel.getCurrentSearchUserName()
            viewModel.setCurrentPage(currentPage + 1)
            let pageNumber = "\(currentPage + 1)"
            
            viewModel.getNetworkManager().makeUserListCall(searchText: searchUserName, page: pageNumber) { (result) in
                switch result {
                case .success(let userReuslts):
                    viewModel.addUserResults(newResult: userReuslts)
                    DispatchQueue.main.async {
                        tableView.performBatchUpdates({
                            let newIndexPath = (indexPath.row + 1 ... indexPath.row + userReuslts.count).map { (row) -> IndexPath in
                                return IndexPath(row: row, section: 0)
                            }
                            tableView.insertRows(at: newIndexPath, with: .automatic)
                        }, completion: nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        userNameSearchBar.endEditing(true)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        guard let viewModel = viewModel else { return }
        viewModel.setCurrentSearchUserName(searchText)
        viewModel.setCurrentPage(1)
        viewModel.resetUserResults()
        userListTableView.reloadData()
        viewModel.getNetworkManager().cancelUserListRequest()
        viewModel.getNetworkManager().cancelUserInfoRequest()
        
        guard !searchText.isEmpty else { return }
        
        viewModel.getNetworkManager().makeUserListCall(searchText: searchText, page: nil) {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let userResults):
                viewModel.addUserResults(newResult: userResults)
                DispatchQueue.main.async {
                    self.userListTableView.reloadData()
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
                self.showAlert(error: error)
            }
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
        }
    }
}


