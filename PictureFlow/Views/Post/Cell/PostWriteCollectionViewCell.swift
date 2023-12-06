//
//  PostWriteView.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/25/23.
//

import UIKit
import PhotosUI
import RxSwift

final class PostWriteCollectionViewCell: UICollectionViewCell {

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
        label.text = "ssabooda"
        return label
    }()
    
    let cancelButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let contentAllDeleteButton = {
        let button = UIButton()
        return button
    }()
    
    let postContentTextField = {
        let tf = UITextView()
        tf.text = "이야기를 시작해보세요..."
        tf.font = .systemFont(ofSize: 15)
        return tf
    }()
    
    let addImageButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let addGIFButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "doc"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let addVoiceRecordButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "waveform"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let addSurveyButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    lazy var functionButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            addImageButton,
            addGIFButton,
            addVoiceRecordButton,
            addSurveyButton,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
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
    
    let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
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
        addSubview(leftDividLineView)
        addSubview(nicknameLabel)
        addSubview(postContentTextField)
        addSubview(functionButtonStackView)
        addSubview(collectionView)

    }
    
    func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.leading.equalTo(safeAreaLayoutGuide).inset(5)
            make.size.equalTo(35)
        }
        
        leftDividLineView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalTo(profileImageView.snp.centerX)
            make.bottom.equalToSuperview().inset(5)
            make.width.equalTo(2)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
//        postContentTextField.backgroundColor = .orange
        postContentTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-5)
            make.height.equalTo(100)
        }
        
//        collectionView.backgroundColor = .red
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(postContentTextField.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(200)
        }
        
        functionButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.bottom.equalToSuperview().offset(-5)
        }
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
