//
//  HashtagTextView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/16/23.
//

import UIKit

final class HashtagTextView: UITextView {
    var hashtagArr: [String]?
    
    func resolveHashTags() {
        self.isEditable = false
        self.isSelectable = true
        
        let nsText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string: nsText as String)
        let hashtagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let results = hashtagDetector?.matches(in: self.text,
                                               options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                               range: NSMakeRange(0, self.text.utf16.count))
        
        
        let hashtagAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.systemBlue
        ]
        
        let regularTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor(resource: .text)
        ]
        
        // 기존 속성 초기화
        attrString.removeAttribute(.foregroundColor, range: NSRange(location: 0, length: attrString.length))
        attrString.addAttributes(regularTextAttributes, range: NSRange(location: 0, length: attrString.length))

        hashtagArr = results?.map { (self.text as NSString).substring(with: $0.range(at: 1)) }
        if hashtagArr?.count != 0 {
            var i = 0
            for var word in hashtagArr! {
                word = "#" + word
                if word.hasPrefix("#") {
                    let matchRange:NSRange = nsText.range(of: word as String, options: [.caseInsensitive, .backwards])
                                                                
                    attrString.addAttribute(NSAttributedString.Key.link, value: "\(i)", range: matchRange)
                    attrString.addAttributes(hashtagAttributes, range: matchRange)
                    i += 1
                }
            }
        }

        self.attributedText = attrString
    }
}
