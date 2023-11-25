//
//  PostDetailView2.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/24/23.
//

import UIKit

final class PostDetailView: UIView {
    
    lazy var commentTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
//        view.register(
//            CommentTableViewCell.self,
//            forCellReuseIdentifier: CommentTableViewCell.description()
//        )
//        view.register(
//            CommentHeaderView.self, forHeaderFooterViewReuseIdentifier:
//                CommentHeaderView.description()
//        )
        view.rowHeight = UITableView.automaticDimension
        view.backgroundColor = UIColor(resource: .backgorund)
        return view
    }()
    
    
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
//        profileImageView.layoutIfNeeded()
//        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    private func configureHierarchy() {
        addSubview(commentTableView)
    }
    
    private func configureLayout() {
        commentTableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    static func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.sectionInset = UIEdgeInsets(
            top: 10,
            left: 15,
            bottom: 10,
            right: 10
        )
        return layout
    }
}
