//
//  StatusAlert
//  Copyright © 2017-2018 Yegor Miroshnichenko. Licensed under the MIT license.
//

// swiftlint:disable all

import UIKit

@objc extension StatusAlertDark {

    @objc(StatusAlertMultiplePresentationsBehavior)
    public enum MultiplePresentationsBehavior: Int {

        /// Not more than one StatusAlert will be shown at once
        case ignoreIfAlreadyPresenting

        /// Currently presented StatusAlerts will be dismissed before presenting another one
        case dismissCurrentlyPresented

        /// All requested StatusAlerts will be shown
        case showMultiple
    }
    
//    @objc(StatusAlertAppearance)
    public final class Appearance: NSObject {
        
        @objc public static let common: Appearance = Appearance()
        
        /// - Note: Do not change to save system look
        @objc public var titleFont: UIFont = UIFont.systemFont(ofSize: 23, weight: FontWeightSemibold)
        
        /// - Note: Do not change to save system look
        @objc public var messageFont: UIFont = UIFont.systemFont(ofSize: 16, weight: FontWeightRegular)
        
        /// - Note: Do not change to save system look
        @objc public var tintColor: UIColor = UIColor.white
        
        /// Used if device does not support blur or if `Reduce Transparency` toggle
        /// in `General->Accessibility->Increase Contrast` is on
        ///
        /// - Note: Do not change to save system look
        @objc public var backgroundColor: UIColor = UIColor.groupTableViewBackground

        /// - Note: Do not change to save system look
        @objc public var blurStyle: UIBlurEffect.Style = .dark
        
        @objc public static func copyCommon() -> Appearance {
            let common = Appearance.common
            let copy = Appearance()
            copy.titleFont          = common.titleFont
            copy.messageFont        = common.messageFont
            copy.tintColor          = common.tintColor
            copy.backgroundColor    = common.backgroundColor
            copy.blurStyle          = common.blurStyle
            return copy
        }
    }
    
    @objc(StatusAlertVerticalPosition)
    public enum VerticalPosition: Int {
        
        /// Position in the center of the view
        case center
        
        /// Position on the top of the view
        case top
        
        /// Position at the bottom of the view
        case bottom
    }
    
//    @objc (StatusAlertSizesAndDistances)
    public final class SizesAndDistances: NSObject {
        
        @objc public static let common: SizesAndDistances = SizesAndDistances()

        @available(*, deprecated, renamed: "initialScale")
        @objc public var defaultInitialScale: CGFloat {
            get { return self.initialScale }
            set { self.initialScale = newValue }
        }
        @available(*, deprecated, renamed: "cornerRadius")
        @objc public var defaultCornerRadius: CGFloat {
            get { return self.cornerRadius }
            set { self.cornerRadius = newValue }
        }
        @available(*, deprecated, renamed: "topOffset")
        @objc public var defaultTopOffset: CGFloat {
            get { return self.topOffset }
            set { self.topOffset = newValue }
        }
        @available(*, deprecated, renamed: "bottomOffset")
        @objc public var defaultBottomOffset: CGFloat {
            get { return self.bottomOffset }
            set { self.bottomOffset = newValue }
        }
        @available(*, deprecated, renamed: "imageWidth")
        @objc public var defaultImageWidth: CGFloat {
            get { return self.imageWidth }
            set { self.imageWidth = newValue }
        }
        @available(*, deprecated, renamed: "alertWidth")
        @objc public var defaultAlertWidth: CGFloat {
            get { return self.alertWidth }
            set { self.alertWidth = newValue }
        }
        @available(*, deprecated, renamed: "imageBottomSpace")
        @objc public var defaultImageBottomSpace: CGFloat {
            get { return self.imageBottomSpace }
            set { self.imageBottomSpace = newValue }
        }
        @available(*, deprecated, renamed: "titleBottomSpace")
        @objc public var defaultTitleBottomSpace: CGFloat {
            get { return self.titleBottomSpace }
            set { self.titleBottomSpace = newValue }
        }
        @available(*, deprecated, renamed: "imageToMessageSpace")
        @objc public var defaultImageToMessageSpace: CGFloat {
            get { return self.imageToMessageSpace }
            set { self.imageToMessageSpace = newValue }
        }

        @objc public var initialScale: CGFloat = 0.9
        @objc public var cornerRadius: CGFloat = 10

        @objc public var topOffset: CGFloat = 32
        @objc public var bottomOffset: CGFloat = 32

        @objc public var imageWidth: CGFloat = 90
        @objc public var alertWidth: CGFloat = 258
        @objc public var minimumAlertHeight: CGFloat = 240
        
        @objc public var minimumStackViewTopSpace: CGFloat = 44
        @objc public var minimumStackViewBottomSpace: CGFloat = 24
        @objc public var stackViewSideSpace: CGFloat = 24
        
        @objc public var imageBottomSpace: CGFloat = 30
        @objc public var titleBottomSpace: CGFloat = 5
        @objc public var imageToMessageSpace: CGFloat = 24
        
        @objc public static func copyCommon() -> SizesAndDistances {
            let common = SizesAndDistances.common
            let copy = SizesAndDistances()
            
            copy.initialScale                   = common.initialScale
            copy.cornerRadius                   = common.cornerRadius
            copy.topOffset                      = common.topOffset
            copy.bottomOffset                   = common.bottomOffset
            copy.imageWidth                     = common.imageWidth
            copy.alertWidth                     = common.alertWidth
            copy.minimumAlertHeight             = common.minimumAlertHeight
            copy.minimumStackViewTopSpace       = common.minimumStackViewTopSpace
            copy.minimumStackViewBottomSpace    = common.minimumStackViewBottomSpace
            copy.stackViewSideSpace             = common.stackViewSideSpace
            copy.imageBottomSpace               = common.imageBottomSpace
            copy.titleBottomSpace               = common.titleBottomSpace
            copy.imageToMessageSpace            = common.imageToMessageSpace
            return copy
        }
    }
}

internal class ReusablesManager<Reusable: Any> {
    typealias PrepareForReuse = (Reusable) -> Void
    typealias CreateReusableClosure = () -> Reusable

    private var reusables: [Reusable] = []
    private let maximumReusablesNumber: Int
    private let createReusableClosure: CreateReusableClosure
    private let prepareForReuseClosure: PrepareForReuse?

    init(
        createReusableClosure: @escaping CreateReusableClosure,
        prepareForReuseClosure: PrepareForReuse?,
        maximumReusablesNumber: Int
        ) {

        self.createReusableClosure = createReusableClosure
        self.prepareForReuseClosure = prepareForReuseClosure
        self.maximumReusablesNumber = maximumReusablesNumber
    }

    func dequeueReusable() -> Reusable {
        if let reusable = self.reusables.first {
            self.reusables.removeFirst()
            self.prepareForReuseClosure?(reusable)
            return reusable
        }
        let reusable = self.createReusableClosure()
        self.enqueueReusable(reusable)
        return self.dequeueReusable()
    }

    func enqueueReusable(_ object: Reusable) {
        guard self.reusables.count < self.maximumReusablesNumber else { return }
        self.reusables.append(object)
    }
}

// Compatibility

#if swift(>=4.0)
private let FontWeightSemibold = UIFont.Weight.semibold
private let FontWeightRegular = UIFont.Weight.regular
#else
private let FontWeightSemibold = UIFontWeightSemibold
private let FontWeightRegular = UIFontWeightRegular
#endif
