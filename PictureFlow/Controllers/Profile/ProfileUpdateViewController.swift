//
//  ProfileUpdateViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa


final class ProfileUpdateViewController: UIViewController {
    let mainView = ProfileUpdateView()
    let viewModel = ProfileUpdateViewModel()
    var disposeBag = DisposeBag()
    var completionHandler: ((UserProfileUpdateResponse) -> Void)?
    private var diaryDate: Date?
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePicker()
        configureNavigationBar()
        configureTextField()
        configureView()
        setupTapGestures()
        bind()
    }
    
    @objc func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        self.diaryDate = datePicker.date
        self.mainView.birthdayTextField.text = datePicker.date.convertDateToString(
            format: .compact,
            localeType: .ko_KR
        )
    }
    
    private func configureDatePicker() {
        mainView.datePicker.addTarget(
            self,
            action: #selector(datePickerValueDidChange(_:)),
            for: .valueChanged
        )
    }
    
    private func configureView() {
        guard let profile = viewModel.profile else { return }
        if let profileURL = profile.profile {
            profileURL.loadProfileImageByKingfisher(imageView: mainView.profileImageView)
            viewModel.profileImage.onNext(mainView.profileImageView.image ?? UIImage())
        }
        mainView.nicknameTextField.text = profile.nick
        mainView.phoneNumberTextField.text = profile.phoneNum
        mainView.birthdayTextField.text = profile.birthDay
    }
    
    private func bind() {
        barButtonBind()
        guard let successBarButton = navigationItem.rightBarButtonItem else { return }
        let input = ProfileUpdateViewModel.Input(
            nicknameTextFieldText: mainView.nicknameTextField.rx.text.orEmpty,
            phoneNumberTextFieldText: mainView.phoneNumberTextField.rx.text.orEmpty,
            birthDayTextFieldText: mainView.birthdayTextField.rx.text.orEmpty,
            updateSuccessBarButtonTap: successBarButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.profileUpdateResponseObservable
            .subscribe(with: self) { owner, profile in
                NotificationCenter.default.post(
                    name: NSNotification.Name("updateDataSource"),
                    object: nil,
                    userInfo: ["isUpdate": true]
                )
                owner.completionHandler?(profile)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func barButtonBind() {
        guard let cancelBarButton = navigationItem.leftBarButtonItem else { return }
        cancelBarButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureTextField() {
        mainView.nicknameTextField.becomeFirstResponder()
    }
}

extension ProfileUpdateViewController: PHPickerViewControllerDelegate {
    
    func setupTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchUpImageView))
        mainView.profileImageView.addGestureRecognizer(tapGesture)
        mainView.profileImageView.isUserInteractionEnabled = true
    }
    
    @objc func touchUpImageView() {
        print("이미지 뷰 터치")
        
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let library = UIAlertAction(title: "라이브러리에서 선택", style: .default) { [weak self] _ in
            self?.setupImagePicker()
        }
        let remove = UIAlertAction(title: "현재 사진 삭제", style: .destructive) { [weak self] _ in
            self?.mainView.profileImageView.image = UIImage(named: "empty-user")
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in }
        
        alert.addAction(library)
        alert.addAction(remove)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func setupImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        
        // 기본 설정을 가지고, 피커뷰컨트롤러 생성
        let picker = PHPickerViewController(configuration: configuration)
        
        // 피커뷰 컨트롤러의 대리자 설정
        picker.delegate = self
        
        // 피커뷰 띄우기
        self.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // PickerView dismiss
        picker.dismiss(animated: true)
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    guard let applyImage = image as? UIImage else { return }
                    self.mainView.profileImageView.image = applyImage
                    self.viewModel.profileImage.onNext(applyImage)
                }
            }
        } else {
            print("이미지 불러오기 실패")
        }
    }
}

extension ProfileUpdateViewController {
    private func configureNavigationBar() {
        navigationItem.title = "프로필 편집"
        
        let updateCancelButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: nil
        )
        
        navigationItem.leftBarButtonItem = updateCancelButton
        navigationItem.leftBarButtonItem?.tintColor = UIColor(resource: .tint)
        
        let updateSuccessButton = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: nil
        )
        
        navigationItem.rightBarButtonItem = updateSuccessButton
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }
}
