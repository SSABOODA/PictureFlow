//
//  NewPostWriteViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/8/23.
//

import UIKit
import PhotosUI
import SnapKit
import RxSwift
import RxCocoa

// 정규표현식에 사용할 String 확장
extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

class NewPostWriteViewController: UIViewController {
    
    let mainView = NewPostWriteView()
    var viewModel = NewPostWriteViewModel()
    var disposeBag = DisposeBag()
    
    let maxCharacterCount = 500
    let showLimitCharacterCount = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTextView()
        bind()
        updateDataSource()
    }
    
    override func loadView() {
        view = mainView
    }
    
    private func updateDataSource() {
        viewModel.fetchProfilData()
    }
    
    private func bind() {
        mainView.addImageButton.rx.tap
            .bind(with: self) { owner, _ in
                print("addImageButton did tap")
                owner.addImageButtonClicked()
            }
            .disposed(by: disposeBag)
        
        guard let rightBarButton = navigationItem.rightBarButtonItem else { return }
        
        let input = NewPostWriteViewModel.Input(
            postCreateButtonTap: rightBarButton.rx.tap,
            postContentText: mainView.postContentTextView.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input: input)
        
        output.userProfileObservable
            .subscribe(with: self) { owner, userProfile in
                owner.mainView.nicknameLabel.text = userProfile.nick
                
                if let profileImageURL = userProfile.profile {
                    profileImageURL.loadProfileImageByKingfisher(imageView: owner.mainView.profileImageView)
                }
                
            }
            .disposed(by: disposeBag)
        
        output.photoImageObservableList
            .subscribe(with: self) { owner, imageList in
                let height = imageList.count == 0 ? 0 : 200
                
                self.mainView.collectionView.snp.updateConstraints { make in
                    make.height.equalTo(height)
                }
            }
            .disposed(by: disposeBag)
        
        output.photoImageObservableList
            .bind(to: mainView.collectionView.rx.items(
                cellIdentifier: PostListImageCancelCollectionViewCell.description(),
                cellType: PostListImageCancelCollectionViewCell.self)) { (row, element, cell) in

                    print("⭐️ rx element: \(element)")
                    cell.postImageView.image = element
                    cell.cancelButton.rx.tap
                        .bind(with: self) { owner, _ in
                            print("cancel button did tap")
                            owner.viewModel.photoImageList.remove(at: row)
                            owner.viewModel.photoImageObservableList.onNext(owner.viewModel.photoImageList)
                        }
                        .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.successPostCreate
            .bind(with: self) { owner, isCreated in
                if isCreated {
                    owner.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
    
    }
}

// PHPickerViewControllerDelegate
extension NewPostWriteViewController: PHPickerViewControllerDelegate {
    private func addImageButtonClicked() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        configuration.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        print(#function)
        
        if !results.isEmpty {
            viewModel.photoImageList.removeAll()
            for result in results {
                let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        guard let image = image as? UIImage else { return }
                        DispatchQueue.main.async {
                            self?.viewModel.photoImageList.append(image)
//                            print("🔥 self?.viewModel.photoImageList: \(self?.viewModel.photoImageList)")
                            self?.viewModel.photoImageObservableList.onNext(self?.viewModel.photoImageList ?? [])
                        }
                    }
                }
            }
        }
        
    }
}

// Configure TextView
extension NewPostWriteViewController {
    
    @objc func configureTextView() {

        textViewDynamicHeight()
        
        // UITextView의 텍스트 변경을 감지
        mainView.postContentTextView.rx.didChange
            .map { [weak self] in self?.mainView.postContentTextView.text }
            .bind { [weak self] text in
                let att = self?.processHashtags(in: text)
                self?.mainView.postContentTextView.attributedText = att
                
            }
            .disposed(by: disposeBag)
        
        mainView.postContentTextView.rx.didBeginEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.postContentTextView.text) == "이야기를 시작해보세요..." {
                    owner.mainView.postContentTextView.text = nil
                    owner.mainView.postContentTextView.textColor = UIColor(resource: .text)
                }
            }
            .disposed(by: disposeBag)
        
        mainView.postContentTextView.rx.didEndEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.postContentTextView.text) == nil ||  (owner.mainView.postContentTextView.text) == "" {
                    owner.mainView.postContentTextView.text = "이야기를 시작해보세요..."
                    owner.mainView.postContentTextView.textColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
        
        mainView.postContentTextView.rx.didChange
            .withLatestFrom(self.mainView.postContentTextView.rx.text.orEmpty) { _, text -> Bool in
                
                if text.count > self.maxCharacterCount {
                    self.mainView.postContentTextView.text = String(text.prefix(self.maxCharacterCount))
                    return false
                }
                return true
            }
            .bind(with: self) { owner, isMax in
            }
            .disposed(by: disposeBag)
        
        mainView.postContentTextView.rx.text.orEmpty
            .map { text in
                if text == "이야기를 시작해보세요..." {
                    return ""
                }
                let currentCount = text.count
                let limitCount = self.maxCharacterCount-currentCount
                if limitCount > self.showLimitCharacterCount {
                    return ""
                } else if limitCount < 0 {
                    return "0"
                } else {
                    return "\(self.maxCharacterCount-currentCount)"
                }
            }
            .bind(to: self.mainView.postContentLimitCountLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func textViewDynamicHeight() {
        mainView.postContentTextView.becomeFirstResponder()
        mainView.postContentTextView.rx.didChange
            .withLatestFrom(mainView.postContentTextView.rx.text)
            .bind(with: self) { owner, text in
                let size = CGSize(width: owner.view.frame.width, height: .infinity)
                let estimatedSize = owner.mainView.postContentTextView.sizeThatFits(size)
                
                owner.mainView.postContentTextView.constraints.forEach { (constraint) in
                    /// 180 이하일때는 더 이상 줄어들지 않게하기
                    if estimatedSize.height <= 180 {
                        
                    } else {
                        if constraint.firstAttribute == .height {
                            constraint.constant = estimatedSize.height
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    
}

// Navigation
extension NewPostWriteViewController {
    private func configureNavigationBar() {
        navigationItem.title = "새로운 글 작성"
        
        // postCancelButton
        let postCancelButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelButtonClicked)
        )
        navigationItem.leftBarButtonItem = postCancelButton
        navigationItem.leftBarButtonItem?.tintColor = UIColor(resource: .tint)
        
        // postCreateButton
        let postCreateButton = UIBarButtonItem(
            title: "게시",
            style: .plain,
            target: self,
            action: #selector(plusButtonClicked)
        )
        navigationItem.rightBarButtonItem = postCreateButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor(resource: .tint)
    }
    
    @objc func cancelButtonClicked() {
        print(#function)

        self.showAlertAction2(title: "게시글 작성을 취소하시겠습니까?") {
            print("")
        } _: {
            self.dismiss(animated: true)
        }
    }
    
    @objc func plusButtonClicked() { }
}

