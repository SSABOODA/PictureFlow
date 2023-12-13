//
//  Extension+String.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import UIKit
import Kingfisher

// 정규식
extension String {
    
    // 이메일 정규식
    func validateEmail() -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        return evaluatePredicate(emailRegEx)
    }
    
    // 패스워드
    func validatePassword() -> Bool {
        let passwordRegEx = "^(?=.*[a-zA-Z0-9]).{8,}$"
        return evaluatePredicate(passwordRegEx)
    }
    
    // 전화번호
    func validatePhoneNumber() -> Bool {
        let phoneNumberRegEx = "^01[0-1, 7][0-9]{7,8}$"
        return evaluatePredicate(phoneNumberRegEx)
    }
    
    private func evaluatePredicate(_ regEx: String) -> Bool {
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with: self)
    }
}

// Kignfisher
extension String {
    func imageDownloadRequest() -> AnyModifier {
        let imageDownloadRequest = AnyModifier { request in
            var headers = request
            headers.setValue(
                KeyChain.read(key: APIConstants.accessToken),
                forHTTPHeaderField: APIConstants.authorization
            )
            headers.setValue(
                APIKey.sesacAPIKey,
                forHTTPHeaderField: APIConstants.apiKey
            )
            return headers
        }
        return imageDownloadRequest
    }
    
    func loadImageByKingfisher(imageView: UIImageView) {
        let fullImageURL = "\(BaseURL.baseURL)/\(self)"
        if let imageURL = URL(string: fullImageURL) {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: imageURL,
//                placeholder: UIImage(named: "user"),
                options: [.requestModifier(self.imageDownloadRequest())]
            )
        }
    }   
}


extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
    
    func downloadImage(urlString : String, imageCompletionHandler: @escaping (UIImage?) -> Void) {
        guard let url = URL.init(string: urlString) else { return }
        
        ImageDownloader.default.downloadImage(
            with: url,
            options: [.requestModifier(self.imageDownloadRequest())]) { result in
                switch result {
                case .success(let data):
                    imageCompletionHandler(data.image)
                case .failure:
                    imageCompletionHandler(nil)
                }
            }
    }
}

