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

        output.userProfileObservableData
            .subscribe(with: self) { owner, profileData in
                owner.mainView.nickNameLabel.text = profileData.nick
                
                if let profileImageURL = profileData.profile {
                    profileImageURL.loadImageByKingfisher(imageView: owner.mainView.profileImageView)
                }
                
                owner.mainView.followerLabel.text = "팔로워 \(profileData.followers.count)명"
                
                for (idx, follwer) in profileData.followers.enumerated() {
                    if let followerProfileURL = follwer.profile {
                        if idx == 0 {
                            followerProfileURL.loadImageByKingfisher(imageView: owner.mainView.followerUserProfileImageView1)
                        } else if idx == 1 {
                            followerProfileURL.loadImageByKingfisher(imageView: owner.mainView.followerUserProfileImageView2)
                        } else if idx == 2 {
                            followerProfileURL.loadImageByKingfisher(imageView: owner.mainView.followerUserProfileImageView3)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
    }
    
}
