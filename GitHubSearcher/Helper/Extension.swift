//
//  Extension.swift
//  GitHubSearcher
//
//  Created by Peter on 4/20/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(error: DataTaskError) {
        DispatchQueue.main.async {
            var message = ""
            switch error {
            case .dataTaskError:
                message = ""
            default:
                message = ConstantValue.defaultErrorMsg
            }
            if !message.isEmpty {
                let title = GSTitle.naviTitle
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let yesButton = UIAlertAction(title: ConstantValue.ok, style: .default)
                alert.addAction(yesButton)
                self.present(alert, animated: true)
            }
        }
    }
}
