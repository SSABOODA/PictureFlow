//
//  FollowViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/13/23.
//

import UIKit
import RxSwift
import RxCocoa

final class FollowViewController: UIViewController {
    
    let mainView = FollowView()
    let viewModel = FollowViewModel()
    var disposeBag = DisposeBag()
    
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        self.viewModel.fetchProfilData()
    }
    
    private func bind() {
        let input = FollowViewModel.Input(
            followButtonTap: mainView.followButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.isFollow
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isFollow in
                let followButton = owner.mainView.followButton
                owner.configureFollowButton(isFollow: isFollow, followButton: followButton)
            }
            .disposed(by: disposeBag)
        
        output.userProfileObservableData
            .subscribe(with: self) { owner, profileData in
                let mv = owner.mainView
                
                let isFollow = profileData.followers
                    .map { $0._id == UserDefaultsManager.userID }
                    .isEmpty ? false : true

                print("init isFollow: \(isFollow)")
                owner.viewModel.isFollow.accept(isFollow)
                
                mv.nickNameLabel.text = profileData.nick
                mv.followerLabel.text = "팔로워 \(profileData.followers.count)명"
                
                if let profileImageURL = profileData.profile {
                    profileImageURL.loadImageByKingfisher(imageView: mv.profileImageView)
                }

                for (idx, follwer) in profileData.followers.enumerated() {
                    if let followerProfileURL = follwer.profile {
                        if idx == 0 {
                            followerProfileURL.loadImageByKingfisher(imageView: mv.followerUserProfileImageView1)
                        } else if idx == 1 {
                            followerProfileURL.loadImageByKingfisher(imageView: mv.followerUserProfileImageView2)
                        } else if idx == 2 {
                            followerProfileURL.loadImageByKingfisher(imageView: mv.followerUserProfileImageView3)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
    }
    
    private func configureFollowButton(isFollow: Bool, followButton: UIButton) {
        if !isFollow {
            followButton.setTitle("팔로우", for: .normal)
            followButton.setImage(nil, for: .normal)
            followButton.setTitleColor(UIColor(resource: .text), for: .normal)
        } else {
            followButton.setTitle("팔로잉", for: .normal)
            followButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            followButton.setTitleColor(.darkGray, for: .normal)
            followButton.tintColor = .darkGray
        }
    }
    
}
