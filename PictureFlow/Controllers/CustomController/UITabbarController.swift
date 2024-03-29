//
//  UITabbarController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit

final class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        self.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.tintColor = UIColor(resource: .tint)
        tabBar.layer.masksToBounds = true
        tabBar.layer.cornerRadius = 20
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow" }) {
            shadowView.frame = tabBar.frame
        } else {
            let shadowView = UIView(frame: .zero)
            shadowView.frame = tabBar.frame
            shadowView.accessibilityIdentifier = "TabBarShadow"
            shadowView.backgroundColor = UIColor(resource: .background)
            shadowView.layer.cornerRadius = tabBar.layer.cornerRadius
            shadowView.layer.maskedCorners = tabBar.layer.maskedCorners
            shadowView.layer.masksToBounds = false
//            shadowView.layer.shadowColor = UIColor.black.cgColor
//            shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//            shadowView.layer.shadowOpacity = 0.1
//            shadowView.layer.shadowRadius = 1
            view.addSubview(shadowView)
            view.bringSubviewToFront(tabBar)
        }
    }
    
    private func configureViewController() {
        let PostListVC = UINavigationController(rootViewController: PostListViewController())
        let SearchVC = UINavigationController(rootViewController: SearchViewController())
        let PostWriteVC = UINavigationController(rootViewController: NewPostWriteViewController())
        let LikeVC = UINavigationController(rootViewController: LikeViewController())
        let ProfileVC = UINavigationController(rootViewController: ProfileViewController())
        
        setViewControllers(
            [
                PostListVC,
                SearchVC,
                PostWriteVC,
                LikeVC,
                ProfileVC
            ], animated: true
        )

        createTabBarItem(viewContoller: PostListVC, imageString: "home", selectedImageString: "home-select")
        createTabBarItem(viewContoller: SearchVC, imageString: "search", selectedImageString: "search-select")
        createTabBarItem(viewContoller: PostWriteVC, imageString: "post")
        createTabBarItem(viewContoller: LikeVC, imageString: "heart", selectedImageString: "heart-select")
        createTabBarItem(viewContoller: ProfileVC, imageString: "person", selectedImageString: "person-select")
        
        PostListVC.tabBarItem.tag = 0
        SearchVC.tabBarItem.tag = 1
        PostWriteVC.tabBarItem.tag = 2
        LikeVC.tabBarItem.tag = 3
        ProfileVC.tabBarItem.tag = 4
    }
}

extension CustomTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 2 {
            let vc = NewPostWriteViewController()
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true)
            return false
        } else {
            return true
        }
    }
    
    func createTabBarItem(
        viewContoller: UIViewController,
        titleString: String? = nil,
        imageString: String,
        selectedImageString: String = ""
    ) {
        
        viewContoller.tabBarItem = UITabBarItem(
            title: titleString,
            image: UIImage(named: imageString),
            selectedImage: UIImage(named: selectedImageString)
        )
    }
}


