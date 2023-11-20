//
//  Extension+URL.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/20/23.
//

import UIKit
import Kingfisher

extension URL {
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
}
