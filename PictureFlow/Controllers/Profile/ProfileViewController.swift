//
//  ProfileViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit
import Tabman
import Pageboy

final class ProfileViewController: UIViewController {
    let mainView = ProfileView()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        makeContainerViewController()
    }
    
    func makeContainerViewController() {
        let childViewController = ChildViewController()
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        
        childViewController.view.snp.makeConstraints { make in
            make.top.equalTo(mainView.profileInfoView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view)
        }
    }
}

extension ProfileViewController {
    private func configureNavigationBar() {
        let settingButton = UIBarButtonItem(
            image: UIImage(named: "setting"),
            style: .plain,
            target: self,
            action: #selector(settingButtonClicked)
        )
        
        let profileUpdateButton = UIBarButtonItem(
            image: UIImage(named: "profile-update"),
            style: .plain,
            target: self,
            action: #selector(settingButtonClicked)
        )
        
        navigationItem.rightBarButtonItems = [
            settingButton,
            profileUpdateButton,
        ]
        navigationItem.rightBarButtonItems?.forEach({ item in
            item.tintColor = UIColor(resource: .tint)
        })
    }
    
    @objc func settingButtonClicked() {
        print("setting button did tap")
    }
}


class ChildViewController: TabmanViewController, PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
        let item = TMBarItem(title: "")
        item.title = "Page \(index)"
        item.image = UIImage(named: "image.png")
        // ↑↑ 이미지는 이따가 탭바 형식으로 보여줄 때 사용할 것이니 "이미지가 왜 있지?" 하지말고 넘어가주세요.
        
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
    
    private var viewControllers: Array<UIViewController> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        
        configureTabViewController()
    }
    
    private func configureTabViewController() {
        let vc1 = ViewController1()
        let vc2 = ViewController2()
        viewControllers.append(vc1)
        viewControllers.append(vc2)
        
        self.dataSource = self
        
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap // Customize
        
        // Add to view
        addBar(bar, dataSource: self, at: .top)
    }
}

class ViewController1: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
    }
}


class ViewController2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
    }
}


