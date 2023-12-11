//
//  ProfileChildViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit
import Tabman
import Pageboy

final class ProfileChildViewController: TabmanViewController {
    
    private var viewControllers: Array<UIViewController> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        
        configureTabViewController()
    }
    
    private func configureTabViewController() {
        let vc1 = ProfileChileMyPostListViewController()
        let vc2 = ProfileChileMaPostCommentListViewController()
        viewControllers.append(vc1)
        viewControllers.append(vc2)
        
        self.dataSource = self
        
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap // Customize
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        bar.buttons.customize { button in
            button.tintColor = .lightGray
            button.selectedTintColor = UIColor(resource: .text)
        }
        bar.indicator.tintColor = UIColor(resource: .tint)
        bar.indicator.overscrollBehavior = .compress
        bar.backgroundView.style = .clear
        addBar(bar, dataSource: self, at: .top)
    }
}

extension ProfileChildViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
        let item = TMBarItem(title: "")
        
        if index == 0 {
            item.title = "게시글"
        } else if index == 1 {
            item.title = "답글"
        } else {
            item.title = "기타"
        }
    
        item.image = UIImage(named: "image.png")
        return item
    }
    
    func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: Pageboy.PageboyViewController, at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
        return nil
    }
}
