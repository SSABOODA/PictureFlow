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
        profileImageTapGesture()
    }
    
    private func profileImageTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        mainView.profileImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageTapped() {
        let fullScreenViewController = FullScreenImageViewController(image: mainView.profileImageView.image)
        fullScreenViewController.modalPresentationStyle = .fullScreen
        self.present(fullScreenViewController, animated: true, completion: nil)
    }
    
    private func bind() {
        let input = FollowViewModel.Input(
            followButtonTap: mainView.followButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.errorObservable
            .subscribe(with: self) { owner, error in
                owner.showAlertAction1(message: error.message)
            }
            .disposed(by: disposeBag)
        
        output.isFollow
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isFollow in
                let followButton = owner.mainView.followButton
                
                owner.configureFollowButton(
                    isFollow: isFollow,
                    followButton: followButton
                )

                if isFollow {
                    owner.viewModel.follwerCount += 1
                } else {
                    if owner.viewModel.follwerCount > 0 {
                        owner.viewModel.follwerCount -= 1
                    }
                }
                
                owner.mainView.followerLabel.text = "팔로워 \(owner.viewModel.follwerCount)명"
            }
            .disposed(by: disposeBag)
        
        output.userProfileObservableData
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, profileData in
                let mv = owner.mainView
                
                let isFollow = profileData.followers
                    .filter { $0._id == UserDefaultsManager.userID }
                    .isEmpty ? false : true

                owner.viewModel.follwerCount = isFollow ? (owner.viewModel.follwerCount - 1) : (owner.viewModel.follwerCount + 1)
                
                owner.viewModel.isFollow.accept(isFollow)
                
                mv.nickNameLabel.text = profileData.nick
                mv.followerLabel.text = "팔로워 \(profileData.followers.count)명"
                
                if let profileImageURL = profileData.profile {
                    profileImageURL.loadProfileImageByKingfisher(imageView: mv.profileImageView)
                }

                for (idx, follwer) in profileData.followers.enumerated() {
                    if let followerProfileURL = follwer.profile {
                        if idx == 0 {
                            followerProfileURL.loadProfileImageByKingfisher(imageView: mv.followerUserProfileImageView1)
                        } else if idx == 1 {
                            followerProfileURL.loadProfileImageByKingfisher(imageView: mv.followerUserProfileImageView2)
                        } else if idx == 2 {
                            followerProfileURL.loadProfileImageByKingfisher(imageView: mv.followerUserProfileImageView3)
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
