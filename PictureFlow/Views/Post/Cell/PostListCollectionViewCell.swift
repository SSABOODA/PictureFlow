//
//  PostListCollectionViewCell.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/19/23.
//

import UIKit

final class PostListCollectionViewCell: UICollectionViewCell {
    let postImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        view.contentMode = .scaleAspectFill
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
    }
    
    @objc func imageTapped() {
        // 이미지를 탭했을 때 실행되는 코드
        // 전체 화면으로 전환하는 코드를 여기에 추가
        toggleFullScreen()
    }
    
    func toggleFullScreen() {
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        contentView.addSubview(postImageView)
        postImageView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func configureCell(with item: String) {
        
    }   
}
