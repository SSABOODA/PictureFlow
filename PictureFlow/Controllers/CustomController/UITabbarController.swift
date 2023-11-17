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
        configureTabBarLayout()
        configureTabBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.tintColor = .black
        tabBar.layer.masksToBounds = true
        tabBar.layer.cornerRadius = 20
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow" }) {
            shadowView.frame = tabBar.frame
        } else {
            let shadowView = UIView(frame: .zero)
            shadowView.frame = tabBar.frame
            shadowView.accessibilityIdentifier = "TabBarShadow"
            shadowView.backgroundColor = UIColor.white
            shadowView.layer.cornerRadius = tabBar.layer.cornerRadius
            shadowView.layer.maskedCorners = tabBar.layer.maskedCorners
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            shadowView.layer.shadowOpacity = 0.1
            shadowView.layer.shadowRadius = 1
            view.addSubview(shadowView)
            view.bringSubviewToFront(tabBar)
        }
    }
    
    private func configureViewController() {
        let HomeVC = UINavigationController(rootViewController: HomeViewController())
        let SearchVC = UINavigationController(rootViewController: SearchViewController())
        let PostVC = UINavigationController(rootViewController: PostViewController())
        let LikeVC = UINavigationController(rootViewController: PostViewController())
        let ProfileVC = UINavigationController(rootViewController: PostViewController())
        
        
        setViewControllers(
            [
                HomeVC,
                SearchVC,
                PostVC,
                LikeVC,
                ProfileVC
            ], animated: true
        )

        createTabBarItem(
            viewContoller: HomeVC,
            imageString: "house",
            selectedImageString: "house.fill"
        )

        createTabBarItem(
            viewContoller: SearchVC,
            imageString: "magnifyingglass"
        )

        createTabBarItem(
            viewContoller: PostVC,
            imageString: "square.and.pencil"
        )
        
        createTabBarItem(
            viewContoller: LikeVC,
            imageString: "heart",
            selectedImageString: "heart.fill"
        )
        
        createTabBarItem(
            viewContoller: ProfileVC,
            imageString: "person",
            selectedImageString: "person.fill"
        )
        modalPresentationStyle = .fullScreen
    }
    
    private func configureTabBarLayout() {}
    
    private func configureTabBar() {
//        self.selectedIndex = Constant.TabBarSetting.selectedIndex
    }
    
}

extension UITabBarController {
    func createTabBarItem(
        viewContoller: UIViewController,
        titleString: String? = nil,
        imageString: String,
        selectedImageString: String = ""
    ) {

        viewContoller.tabBarItem = UITabBarItem(
            title: titleString,
            image: UIImage(systemName: imageString),
            selectedImage: UIImage(systemName: selectedImageString)
        )
    }
}
