//
//  ProfileChileMaPostCommentListView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/12/23.
//

import UIKit

final class ProfileChileMyPostCommentListView: UIView {
    let noCommentLabel = {
        let label = UILabel()
        label.text = "아직 답글을 게시하지 않았습니다."
        label.textColor = .lightGray
        return label
    }()
    
    let tableView = {
        let view = UITableView()
//        view.register(
//            CommentCollectionViewCell.self,
//            forCellReuseIdentifier: CommentCollectionViewCell.description()
//        )
        view.backgroundColor = UIColor(resource: .background)
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 100
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
        configureHierarchy()
        configureLayout()
    }
    //안녕
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() {
        addSubview(tableView)
        tableView.addSubview(noCommentLabel)
    }
    
    func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        noCommentLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
//돌아오세요
