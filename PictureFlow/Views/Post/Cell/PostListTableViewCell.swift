//
//  PostListTableViewCell.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/19/23.
//

import UIKit
import RxSwift
import RxDataSources

final class PostListTableViewCell: UITableViewCell {
    
    let profileImageView = {
        let view = ProfileImageView(frame: .zero)
        return view
    }()
    
    let leftDividLineView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
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
    
    let moreInfoButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor(resource: .text)
        return button
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
            BasePostListImageCollectionViewCell.self,
            forCellWithReuseIdentifier: BasePostListImageCollectionViewCell.description()
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
        let stackView = UIStackView(
            arrangedSubviews: [
                commentCountButton,
                likeCountButton
            ])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(resource: .background)
        selectionStyle = .none
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    private func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(leftDividLineView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(postCreatedTimeLabel)
        contentView.addSubview(moreInfoButton)
        contentView.addSubview(contentLabel)
        
        contentView.addSubview(collectionView)
        contentView.addSubview(functionButtonStackView)
        contentView.addSubview(countButtonStackView)
    }
    
    private func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalTo(nicknameLabel.snp.leading).offset(-10)
            make.size.equalTo(30)
        }
        
        leftDividLineView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalTo(profileImageView.snp.centerX)
            make.bottom.equalToSuperview().inset(15)
            make.width.equalTo(2)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
    
        postCreatedTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameLabel.snp.centerY)
            make.trailing.equalTo(moreInfoButton.snp.leading).offset(-10)
        }

        moreInfoButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.top)
            make.trailing.equalToSuperview().offset(-15)
            make.size.equalTo(25)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(5)
            make.leading.equalTo(safeAreaLayoutGuide)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(200)
        }
        
        functionButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        
        countButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(functionButtonStackView.snp.bottom).offset(5)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.bottom.equalToSuperview().inset(15)
        }
    }
    
    func configureCell(with elements: PostList) {
        updateCollectionViewHeight(isEmpty: elements.image.isEmpty)
        
        // Profile Image
        if let profileImageURL = elements.creator.profile {
            let imageURL = "\(BaseURL.baseURL)/\(profileImageURL)"
            imageURL.loadImageByKingfisher(imageView: profileImageView)
        } else {
            profileImageView.image = UIImage(named: "user")
        }

        // 시간 작업
        let timeContent = DateTimeInterval.shared.calculateDateTimeInterval(createdTime: elements.time)
        
        nicknameLabel.text = elements.creator.nick
        postCreatedTimeLabel.text = timeContent
        contentLabel.text = elements.content

        commentCountButton.setTitle("\(elements.comments.count) 답글", for: .normal)
        likeCountButton.setTitle("\(elements.likes.count) 좋아요", for: .normal)
        
        let userId = UserDefaultsManager.userID
        if elements.likes.contains(userId) {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .red
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = UIColor(resource: .tint)
        }
        
        // 컬렉션 뷰 구성
        configureCollectionView(with: elements.image)
    }
    
    private func updateCollectionViewHeight(isEmpty: Bool) {
        let height = isEmpty ? 0 : 200
        self.collectionView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        self.collectionView.layoutIfNeeded()
    }
    
    private func configureCollectionView(with imageList: [String]) {
        Observable.just(imageList)
            .bind(
                to: collectionView.rx.items(
                    cellIdentifier: BasePostListImageCollectionViewCell.description(),
                    cellType: BasePostListImageCollectionViewCell.self)
            ) { (row, element, cell) in
                let imageURL = "\(BaseURL.baseURL)/\(element)"
                imageURL.loadImageByKingfisher(imageView: cell.postImageView)
            }
            .disposed(by: disposeBag)
    }

    static func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 10)
        return layout
    }
}

