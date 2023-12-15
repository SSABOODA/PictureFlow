//
//  PostListCollectionViewCell.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/19/23.
//

import UIKit
import RxSwift


final class PostListImageCancelCollectionViewCell: BasePostListImageCollectionViewCell {
    let cancelButtonView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.clipsToBounds = true
        return view
    }()
    
    let cancelButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cancelButtonView.layer.cornerRadius = cancelButtonView.frame.width / 2
    }
    
    private func configureHierarchy() {
        postImageView.addSubview(cancelButtonView)
        cancelButtonView.addSubview(cancelButton)
    }
    
    private func configureLayout() {
        cancelButtonView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
            make.size.equalTo(25)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }
}


class BasePostListImageCollectionViewCell: UICollectionViewCell {
    var imageTappedHandler: (() -> Void)?
    
    let postImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        return view
    }()

    var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        postImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageTapped() {
        imageTappedHandler?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        postImageView.image = nil
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        contentView.addSubview(postImageView)
        
    }
    
    private func configureLayout() {
        postImageView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func configureCell(with item: String) {
    }   
}
