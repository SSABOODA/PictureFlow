//
//  Extension+UIViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit

extension UIViewController {
    enum TransitionStyle {
        case present
        case presentNavigation
        case presentFullNavigation
        case push
    }
    
    func transition<T: UIViewController>(viewController: T, style: TransitionStyle) {
        let vc = viewController
        switch style {
        case .present:
            present(vc, animated: true)
        case .presentNavigation:
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true)
        case .presentFullNavigation:
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .push:
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
