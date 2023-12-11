//
//  ProfileViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileViewController: UIViewController {
    let mainView = ProfileView()
    var disposeBag = DisposeBag()
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        makeContainerViewController()
        
        bind()
    }
    
    private func bind() {
        guard let profileUpdateBarButton = navigationItem.rightBarButtonItems?[1] else { return }
        profileUpdateBarButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = ProfileUpdateViewController()
                owner.transition(viewController: vc, style: .presentNavigation)
            }
            .disposed(by: disposeBag)
    }
    
    
}

extension ProfileViewController {
    func makeContainerViewController() {
        let childViewController = ProfileChildViewController()
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
            action: nil
        )
        
        let profileUpdateButton = UIBarButtonItem(
            image: UIImage(named: "profile-update"),
            style: .plain,
            target: self,
            action: nil
        )
        
        navigationItem.rightBarButtonItems = [
            settingButton,
            profileUpdateButton,
        ]
        navigationItem.rightBarButtonItems?.forEach({ item in
            item.tintColor = UIColor(resource: .tint)
        })
    }
}
