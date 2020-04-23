//
//  DetailViewController.swift
//  GitHubSearcher
//
//  Created by Peter on 4/18/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var joinDateLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var repoSearchBar: UISearchBar!
    @IBOutlet weak var repoListTableView: UITableView!
    
    var viewModel: DetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupUserInfoView()
        title = GSTitle.naviTitle
    }
    
    func setupTableView() {
        repoListTableView.delegate = self
        repoListTableView.dataSource = self
    }
    
    func setupSearchBar() {
        repoSearchBar.delegate = self
        repoSearchBar.placeholder = GSTitle.repoSearchBarPlaceHolder
    }
    
    func bindViewModel(_ viewModel: DetailViewModel) {
        self.viewModel = viewModel
    }
    
    func setupUserInfoView() {
        guard let viewModel = viewModel else { return }
        let userResult = viewModel.getUserResult()
        let userInfo = userResult?.userInfo
        usernameLabel.text = ConstantValue.userName + (userInfo?.login ?? "")
        emailLabel.text = ConstantValue.email + (userInfo?.email ?? "")
        locationLabel.text = ConstantValue.location + (userInfo?.location ?? "")
        joinDateLabel.text = ConstantValue.joinDate + ( userInfo?.createdAt ?? "")
        followersLabel.text = ConstantValue.followers + ("\(userInfo?.followers ?? 0)")
        followingLabel.text = ConstantValue.following + ("\(userInfo?.following ?? 0)")
        bioLabel.text = ConstantValue.bio + (userInfo?.bio ?? "")
        if let data = userResult?.imageData {
            avatarImageView.image = UIImage(data: data)
        }
        
        viewModel.getNetworkManager().makeRepoSearchCall(searchText: "", userName: userResult?.user?.login, handler: {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let repositories):
                viewModel.setRepoArray(repositories)
                DispatchQueue.main.async {
                    self.repoListTableView.reloadData()
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
                self.showAlert(error: error)
            }
        })
    }
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getRepoArray()?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.cell, for: indexPath) as? RepoListTableViewCell else {
            return UITableViewCell()
        }
        
        let repoItem = viewModel?.getRepoArray()?.items?[indexPath.row]
        
        cell.repoNameLabel.text = repoItem?.name
        cell.forksCountLabel.text = "\(repoItem?.forks ?? 0)" + ConstantValue.forks
        cell.starsCountLabel.text = "\(repoItem?.stargazersCount ?? 0)" + ConstantValue.stars
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: ConstantValue.main, bundle: nil)
        let webViewController = storyboard.instantiateViewController(identifier: ConstantValue.webViewController) as WebViewController
        webViewController.urlString = viewModel?.getRepoArray()?.items?[indexPath.row].htmlUrl
        webViewController.title = viewModel?.getRepoArray()?.items?[indexPath.row].name
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        repoSearchBar.endEditing(true)
    }
    
}

extension DetailViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let viewModel = viewModel, !searchText.isEmpty else { return }
        viewModel.getNetworkManager().cancelRepoListRequest()
        let userName = viewModel.getUserResult()?.user?.login
        viewModel.getNetworkManager().makeRepoSearchCall(searchText: searchText, userName: userName) {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let repositories):
                viewModel.setRepoArray(repositories)
                DispatchQueue.main.async {
                    self.repoListTableView.reloadData()
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
                self.showAlert(error: error)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        repoSearchBar.endEditing(true)
    }
}
