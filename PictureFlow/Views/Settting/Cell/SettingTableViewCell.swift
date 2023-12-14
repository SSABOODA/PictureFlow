//
//  SettingTableViewCell.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import UIKit

final class SettingTableViewCell: UITableViewCell {
    let settingItemImage = {
        let view = UIImageView()
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor(resource: .tint)
        return view
    }()
    
    let settingItemNameLabel = {
        let label = UILabel()
        label.text = "팔로우"
        return label
    }()
    
    lazy var settingCellStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            settingItemImage,
            settingItemNameLabel,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fill
        return stackView
    }()
    
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
    
    private func configureHierarchy() {
        contentView.addSubview(settingCellStackView)
    }
    
    private func configureLayout() {
        settingItemImage.snp.makeConstraints { make in
            make.width.equalTo(30)
        }
        settingCellStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.verticalEdges.equalToSuperview().inset(10)
            make.height.equalTo(35)
        }
    }
    
    func configureCell(element: SettingItem) {
        settingItemImage.image = element.uiImage
        settingItemNameLabel.text = element.name
        
        if ["로그아웃", "회원탈퇴"].contains(element.name) {
            settingItemImage.isHidden = true
            
            if element.name == "로그아웃" {
                settingItemNameLabel.textColor = .systemBlue
            } else if element.name == "회원탈퇴" {
                settingItemNameLabel.textColor = .systemRed
            }
        }
    }
}
