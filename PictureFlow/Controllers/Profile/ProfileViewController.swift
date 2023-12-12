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
    let viewModel = ProfileViewModel()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchProfileData()
    }
    
    private func bind() {
        barButtonBind()
        
        let input = ProfileViewModel.Input(
        )
        let output = viewModel.transform(input: input)
        
        viewModel.fetchProfileData()
        
        output.myProfileData
            .subscribe(with: self) { owner, data in
                
                let profile = UserProfileDomainData(
                    posts: data.posts,
                    followers: data.followers,
                    following: data.following,
                    _id: data._id,
                    email: data.email,
                    nick: data.nick,
                    phoneNum: data.phoneNum,
                    birthDay: data.birthDay,
                    profile: data.profile
                )
                owner.configureView(view: owner.mainView, data: profile)
                
            }
            .disposed(by: disposeBag)
    }
    
    private func barButtonBind() {
        guard let profileUpdateBarButton = navigationItem.rightBarButtonItems?[1] else { return }
        profileUpdateBarButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = ProfileUpdateViewController()
                vc.viewModel.profile = owner.viewModel.UserProfile
                vc.completionHandler = { data in
                    print("성공했냐?")
                    let profile = UserProfileDomainData(
                        posts: data.posts,
                        followers: data.followers,
                        following: data.following,
                        _id: data._id,
                        email: data.email,
                        nick: data.nick,
                        phoneNum: data.phoneNum,
                        birthDay: data.birthDay,
                        profile: data.profile
                    )
                    owner.configureView(view: owner.mainView, data: profile)
                }
                owner.transition(viewController: vc, style: .presentNavigation)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureView(view: ProfileView, data: UserProfileDomainData) {
        view.nickNameLabel.text = data.nick
        view.followerLabel.text = "팔로워 \(data.followers.count)명"
        
        if let profile = data.profile {
            "\(BaseURL.baseURL)/\(profile)".loadImageByKingfisher(imageView: view.profileImageView)
        }
        
        for (idx, follwer) in data.followers.enumerated() {
            if let followerProfile = follwer.profile {
                let imageURL = "\(BaseURL.baseURL)/\(followerProfile)"
                if idx == 0 {
                    imageURL.loadImageByKingfisher(imageView: view.followerUserProfileImageView1)
                } else if idx == 1 {
                    imageURL.loadImageByKingfisher(imageView: view.followerUserProfileImageView2)
                } else if idx == 2 {
                    imageURL.loadImageByKingfisher(imageView: view.followerUserProfileImageView3)
                }
            }
        }
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
        navigationItem.title = "프로필"
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
