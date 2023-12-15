//
//  FullScreenImageViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/15/23.
//

import UIKit

final class FullScreenImageView: UIView {
    var imageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let cancelButtonView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .darkGray
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
        backgroundColor = .black
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cancelButtonView.layer.cornerRadius = cancelButtonView.frame.width / 2
        cancelButtonView.layoutIfNeeded()
    }
    
    private func configureHierarchy() {
        addSubview(imageView)
        addSubview(cancelButtonView)
    }

    private func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cancelButtonView.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.size.equalTo(35)
        }
        
        cancelButtonView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }
}

final class FullScreenImageViewController: UIViewController {
    
    let mainView = FullScreenImageView()

    override func loadView() {
        view = mainView
    }

    init(image: UIImage?) {
        self.mainView.imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.cancelButton.addTarget(
            self,
            action: #selector(closeFullScreen),
            for: .touchUpInside
        )
        
        // 탭 제스처를 추가하여 전체 화면에서 이미지를 탭하면 화면 닫히도록
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(closeFullScreen)
        )
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func closeFullScreen() {
        dismiss(animated: true, completion: nil)
    }
}
