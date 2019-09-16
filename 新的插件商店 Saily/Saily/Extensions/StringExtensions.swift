//
//  String+Extension.swift
//  Saily
//
//  Created by mac on 2019/5/11.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import Foundation

extension String {
    
    func readClipBoard() -> String {
        let pasteboardString: String? = UIPasteboard.general.string
        if let theString = pasteboardString {
            return theString
        }
        return ""
    }
    
    func pushClipBoard() {
        UIPasteboard.general.string = self
    }
    
    func share(from_view: UIView? = nil) {
        let textToShare = [self]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
        var some = UIViewController()
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            some = topController
        }
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = from_view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        
        some.present(activityViewController, animated: true, completion: nil)
    }
    
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func drop_space() -> String {
        var ret = self
        while ret.hasPrefix(" ") {
            ret = ret.dropFirst().to_String()
        }
        while ret.hasSuffix(" ") {
            ret = ret.dropLast().to_String()
        }
        return ret
    }
    
    func drop_comment() -> String {
        if !self.contains("#") {
            return self
        }
        if self.hasPrefix("#") {
            return ""
        }
        return self.split(separator: "#").first?.to_String() ?? ""
    }
    
    func returnUIHeight(font: UIFont, widthOfView: CGFloat) -> CGFloat {
        let frame = NSString(string: self).boundingRect(
            with: CGSize(width: widthOfView, height: .infinity),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            attributes: [.font : font],
            context: nil)
        return frame.size.height
    }
    
    func cleanRN() -> String {
        var newString = self.replacingOccurrences(of: "\r\n", with: "\n", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "\r", with: "\n", options: .literal, range: nil)
        return newString
    }
    
    func readAllFiles() -> [String] {
        var ret = [String]()
        var isDir : ObjCBool = false
        if FileManager.default.fileExists(atPath: self, isDirectory: &isDir) {
            if isDir.boolValue {
                if let list = try? FileManager.default.contentsOfDirectory(atPath: self) {
                    for object in list {
                        let FP: String
                        if self.hasSuffix("/") {
                            FP = self + object
                        } else {
                            FP = self + "/" + object
                        }
                        for mybaby in FP.readAllFiles() {
                            ret.append(mybaby)
                        }
                    }
                }
            } else {
                ret.append(self)
            }
        }
        return ret
    }
    
}

extension Substring {
    
    func to_String() -> String {
        return String(self)
    }
    
}

extension Collection where Element: Equatable {
    
    func indexDistance(of element: Element) -> Int? {
        guard let index = firstIndex(of: element) else { return nil }
        return distance(from: startIndex, to: index)
    }
    
}
extension StringProtocol {
    
    func indexDistance(of string: Self) -> Int? {
        guard let index = range(of: string)?.lowerBound else { return nil }
        return distance(from: startIndex, to: index)
    }
    
}

extension NSMutableAttributedString {

    func setFontFace(font: UIFont, color: UIColor? = nil) {
        beginEditing()
        self.enumerateAttribute(
            .font,
            in: NSRange(location: 0, length: self.length)
        ) { (value, range, _) in
            
            if let f = value as? UIFont,
                let newFontDescriptor = f.fontDescriptor
                    .withFamily(font.familyName)
                    .withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                
                let newFont = UIFont(
                    descriptor: newFontDescriptor,
                    size: font.pointSize
                )
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                if let color = color {
                    removeAttribute(
                        .foregroundColor,
                        range: range
                    )
                    addAttribute(
                        .foregroundColor,
                        value: color,
                        range: range
                    )
                }
            }
        }
        endEditing()
    }
    
}

extension NSAttributedString {
    convenience init(data: Data, documentType: DocumentType, encoding: String.Encoding = .utf8) throws {
        try self.init(data: data,
                      options: [.documentType: documentType,
                                .characterEncoding: encoding.rawValue],
                      documentAttributes: nil)
    }
    convenience init(html data: Data) throws {
        try self.init(data: data, documentType: .html)
    }
    convenience init(txt data: Data) throws {
        try self.init(data: data, documentType: .plain)
    }
    convenience init(rtf data: Data) throws {
        try self.init(data: data, documentType: .rtf)
    }
    convenience init(rtfd data: Data) throws {
        try self.init(data: data, documentType: .rtfd)
    }
}

extension StringProtocol {
    var data: Data { return Data(utf8) }
    var htmlToAttributedString: NSAttributedString? {
        do {
            return try .init(html: data)
        } catch {
            print("[E] Extension StringProtocol: html err:", error)
            return nil
        }
    }
    var htmlDataToString: String? {
        return htmlToAttributedString?.string
    }
}

extension String {
    
    func returnQRCode() -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
}

extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
