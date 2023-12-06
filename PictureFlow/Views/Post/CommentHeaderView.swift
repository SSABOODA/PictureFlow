//
//  CommentTableViewHeaderView.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/24/23.
//

import UIKit
import RxSwift

final class CommentCollectionReusableHeaderView: UICollectionReusableView {
    
    let profileImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "person")
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.backgroundColor = UIColor(resource: .tint)
        view.tintColor = UIColor(resource: .background)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let nicknameLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        label.textColor = UIColor(resource: .text)
        return label
    }()
    
    let postCreatedTimeLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor(resource: .text)
        return label
    }()
    
    let contentLabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textColor = UIColor(resource: .text)
        return label
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        collectionView.register(
            PostListCollectionViewCell.self,
            forCellWithReuseIdentifier: PostListCollectionViewCell.description()
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor(resource: .background).withAlphaComponent(0)
        return collectionView
    }()
    
    let likeButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let commentButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bubble"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let bookmarkButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let shareButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    lazy var functionButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            likeButton,
            commentButton,
            bookmarkButton,
            shareButton,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let commentCountButton = {
        let button = UIButton()
        button.setTitle("91 답글", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        return button
    }()
    
    let likeCountButton = {
        let button = UIButton()
        button.setTitle("141 좋아요", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        return button
    }()
    
    lazy var countButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            commentCountButton,
            likeCountButton
        ])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(postCreatedTimeLabel)
        addSubview(contentLabel)
        addSubview(collectionView)
        addSubview(functionButtonStackView)
        addSubview(countButtonStackView)
    }
    
    func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalToSuperview().inset(15)
            make.size.equalTo(35)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        postCreatedTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.leading.equalTo(profileImageView.snp.leading)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(5)
            make.leading.equalTo(safeAreaLayoutGuide)
            make.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(0)
        }
        
        functionButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.leading.equalTo(profileImageView.snp.leading)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        
        countButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(functionButtonStackView.snp.bottom).offset(5)
            make.leading.equalTo(profileImageView.snp.leading)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.bottom.equalToSuperview().inset(15)
        }
        
    }
    
    static func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10)
        return layout
    }
}


final class EmptyCommentCollectionReusableHeaderView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
