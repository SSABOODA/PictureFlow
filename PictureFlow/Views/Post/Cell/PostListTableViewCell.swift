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
        let view = UIImageView()
        view.image = UIImage(systemName: "person")
//        view.contentMode = .scaleToFill
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.backgroundColor = .black
        view.tintColor = .white
        view.contentMode = .scaleAspectFit
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
        label.text = "ssaboo99"
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        return label
    }()
    
    let postCreatedTimeLabel = {
        let label = UILabel()
        label.text = "18시간전"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .lightGray
        return label
    }()
    
    let contentLabel = {
        let label = UILabel()
        label.text = "애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%애들아 적금하러 가야지?? 연이율 15%"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(PostListCollectionViewCell.self, forCellWithReuseIdentifier: PostListCollectionViewCell.description())
        collectionView.backgroundColor = .orange
        return collectionView
    }()
    
    let likeButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let commentButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bubble"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let bookmarkButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let shareButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = .black
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print(#function)
        configureHierarchy()
        backgroundColor = .white
//        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    private func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(postCreatedTimeLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(leftDividLineView)
        
        contentView.addSubview(collectionView)
        contentView.addSubview(functionButtonStackView)
        contentView.addSubview(countButtonStackView)
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalToSuperview().inset(10)
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
            make.top.equalTo(nicknameLabel.snp.top)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(5)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(100)
            
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
    
    func configure(with items: [String]) {
        print(#function, "===")
//        let dataSource = createCollectionViewDataSource()
        
        // CollectionView에 바인딩
//        Observable.just([SectionModel(header: "", items: items)])
//            .bind(to: collectionView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
//
//        collectionView.rx.itemSelected
//            .subscribe(onNext: { indexPath in
//                print("Selected item at indexPath: \(indexPath)")
//            })
//            .disposed(by: disposeBag)
    }
    
//    private func createCollectionViewDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionModel> {
//        print(#function)
//        return RxCollectionViewSectionedReloadDataSource<SectionModel>(
//            configureCell: { (_, collectionView, indexPath, item) in
//                print("RxCollectionViewSectionedReloadDataSource")
//                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostListCollectionViewCell.description(), for: indexPath) as? PostListCollectionViewCell else { return PostListCollectionViewCell() }
//                cell.configure(with: item)
//                return cell
//            }
//        )
//    }
    
    static func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let size = UIScreen.main.bounds.width - 40
        layout.itemSize = CGSize(width: size/2, height: size/2)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return layout
    }
}
