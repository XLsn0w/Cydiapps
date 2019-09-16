//
//  StatusAlertDark
//  Copyright © 2017-2018 Yegor Miroshnichenko. Licensed under the MIT license.
//

// swiftlint:disable all

import UIKit

// swiftlint:disable:next type_body_length
@objc public final class StatusAlertDark: UIView {
    
    // MARK: - Public fields -
    
    /// - Note: Do not change to save system look
    /// - Note: Changes while showing will have no effect
    @objc public var appearance: Appearance = Appearance.copyCommon()
    
    /// - Note: Do not change to save system look
    /// - Note: Changes while showing will have no effect
    @objc public var sizesAndDistances: SizesAndDistances = SizesAndDistances.copyCommon()
    
    /// Announced to VoiceOver when the alert gets presented
    @objc public var accessibilityAnnouncement: String? = nil
    
    /// How long StatusAlertDark should be on screen.
    ///
    /// - Note: This time should include fade animation duration (which is `NavigationControllerHideShowBarDuration`)
    /// - Note: Changes while showing will have no effect
    @objc public var alertShowingDuration: TimeInterval = 2
    
    /// Multiple presentation requests behavior
    @objc public static var multiplePresentationsBehavior: MultiplePresentationsBehavior = .ignoreIfAlreadyPresenting
    
    /// @1x should be 90*90 by default
    @objc public var image: UIImage?
    
    @objc public var title: String?
    
    @objc public var message: String?
    
    /// Determines whether `StatusAlertDark` can be picked or dismissed by tap
    @objc public var canBePickedOrDismissed: Bool {
        get { return self.contentView.isUserInteractionEnabled }
        set { self.contentView.isUserInteractionEnabled = newValue }
    }
    
    // MARK: - Private fields -
    
    /// Used to present only one `StatusAlertDark` at once if `multiplePresentationsBehavior` is `ignoreIfAlreadyPresenting`
    /// or to dismiss currently presented alerts if `multiplePresentationsBehavior` is `dismissCurrentlyPresented`
    private static var currentlyPresentedStatusAlertDarks: [StatusAlertDark] = []
    
    private static var alertToPresent: StatusAlertDark? = nil
    private static var dismissing: Bool {
        return alertToPresent != nil
    }
    
    private let defaultFadeAnimationDuration: TimeInterval = TimeInterval(NavigationControllerHideShowBarDuration)
    private lazy var blurEffect: UIBlurEffect = {
        return UIBlurEffect(style: self.appearance.blurStyle)
    }()
    
    private let contentView: UIVisualEffectView = UIVisualEffectView()
    private let contentStackView: UIStackView = UIStackView()
    
    private var imageView: UIImageView? = nil
    private var titleLabel: UILabel? = nil
    private var messageLabel: UILabel? = nil
    
    private var contentStackViewConstraints: [NSLayoutConstraint] = []
    private var reusableObjectsConstraints: [NSLayoutConstraint] = []
    
    private var timer: Timer?
    
    /// Determines whether `StatusAlertDark` has at least one item to show
    private var isContentEmpty: Bool {
        return self.image == nil
            && self.title == nil
            && self.message == nil
    }
    
    /// Determines whether blur is available
    private var isBlurAvailable: Bool {
        return true
    }
    
    private var pickGesture: UILongPressGestureRecognizer?
    
    // MARK: - Interaction methods
    
    @objc private func pick() {
        guard self.canBePickedOrDismissed else {
            return
        }
        if self.pickGesture?.state == .cancelled
            || self.pickGesture?.state == .ended
            || self.pickGesture?.state == .failed {
            
            self.dismiss(completion: nil)
        }
    }
    
    // MARK: - Initialization -
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.enqueueReusableObjects()
    }
    
    // MARK: - Show methods -
    
    /// Shows `StatusAlertDark` in the center of the `keyWindow`
    /// - Note: must be called from the main thread only
    @objc public func showInKeyWindow() {
        
        self.show()
    }
    
    /// Shows `StatusAlertDark` in the center of `presenter`
    ///
    /// - Parameters:
    ///   - presenter: view present `StatusAlertDark` in
    /// - Note: must be called from the main thread only
    @objc(showInView:)
    public func show(in presenter: UIView) {
        
        self.show(inPresenter: presenter)
    }
    
    /// Shows `StatusAlertDark` in `keyWindow`
    ///
    /// - Parameters:
    ///   - verticalPosition: `StatusAlertDark` position in `keyWindow`
    /// - Note: must be called from the main thread only
    @objc(showWithVerticalPosition:)
    public func show(withVerticalPosition verticalPosition: VerticalPosition) {
        
        self.show(with: verticalPosition, offset: 0)
    }
    
    /// Shows `StatusAlertDark` in the center of `keyWindow` with `offset`
    ///
    /// - Parameters:
    ///   - offset: offset from center of `keyWindow`
    /// - Note: must be called from the main thread only
    @objc(showWithOffset:)
    public func show(withOffset offset: CGFloat) {
        
        self.show(offset: offset)
    }
    
    /// Shows `StatusAlertDark` in `presenter`
    ///
    /// - Parameters:
    ///   - presenter: view present `StatusAlertDark` in
    ///   - verticalPosition: `StatusAlertDark` position in `presenter`
    /// - Note: must be called from the main thread only
    @objc(showInView:withVerticalPosition:)
    public func show(
        in presenter: UIView,
        withVerticalPosition verticalPosition: VerticalPosition
        ) {
        
        self.show(inPresenter: presenter, with: verticalPosition)
    }
    
    /// Shows `StatusAlertDark` in the center of `presenter`
    ///
    /// - Parameters:
    ///   - presenter: view present `StatusAlertDark` in
    ///   - offset: offset from center in `presenter`
    /// - Note: must be called from the main thread only
    @objc(showInView:withOffset:)
    public func show(
        in presenter: UIView,
        withOffset offset: CGFloat
        ) {
        
        self.show(inPresenter: presenter, offset: offset)
    }
    
    /// Shows `StatusAlertDark` in `keyWindow`
    ///
    /// - Parameters:
    ///   - verticalPosition: `StatusAlertDark` position in `keyWindow`
    ///   - offset: offset for `verticalPosition` in `keyWindow`
    /// - Note: must be called from the main thread only
    @objc(showWithVerticalPosition:offset:)
    public func show(
        withVerticalPosition verticalPosition: VerticalPosition,
        offset: CGFloat
        ) {
        
        self.show(with: verticalPosition, offset: offset)
    }
    
    /// Shows `StatusAlertDark` in `presenter`
    ///
    /// - Parameters:
    ///   - presenter: view present `StatusAlertDark` in
    ///   - verticalPosition: `StatusAlertDark` position in `presenter`
    ///   - offset: offset for `verticalPosition` in `presenter`. To use default offset see the same method but without offset parameter.
    /// - Note: must be called from the main thread only
    @objc(showInView:withVerticalPosition:offset:)
    public func show(
        in presenter: UIView,
        withVerticalPosition verticalPosition: VerticalPosition,
        offset: CGFloat
        ) {
        
        self.show(
            inPresenter: presenter,
            with: verticalPosition,
            offset: offset
        )
    }
    
    // MARK: - Private methods -
    
    private func show(
        inPresenter presenter: UIView = UIApplication.shared.keyWindow ?? UIView(),
        with verticalPosition: VerticalPosition = .center,
        offset: CGFloat? = nil
        ) {
        
        self.assertIsMainThread()
        guard !self.isContentEmpty else { return }
        
        self.prepareForPresentation { [weak self] in
            self?.prepareContent()
            self?.positionAlert(
                inPresenter: presenter,
                withVerticalPosition: verticalPosition,
                offset: offset
            )
            self?.setupContentViewBackground()
            self?.observeReduceTransparencyStatus()
            self?.performPresentation()
        }
    }
    
    private func commonInit() {
        self.setupView()
        self.setupContentView()
        self.setupContentStackView()
        
        self.layoutViews()
        
        self.setupPickGestureRecognizer()
        self.setupAccessibilityProperties()
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupContentView() {
        if self.isBlurAvailable {
            if #available(iOS 11, *) {
                self.alpha = 0
            } else {
                self.contentView.contentView.alpha = 0
            }
        } else {
            self.alpha = 0
        }
        
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = self.sizesAndDistances.cornerRadius
    }
    
    private func setupContentStackView() {
        self.contentStackView.axis = .vertical
        self.contentStackView.distribution = .fill
        self.contentStackView.alignment = .center
        self.contentStackView.spacing = 0
    }
    
    private func layoutViews() {
        self.addSubview(self.contentView)
        self.contentView.contentView.addSubview(self.contentStackView)
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.leftAnchor.constraint(
            equalTo: self.contentView.leftAnchor,
            constant: self.sizesAndDistances.stackViewSideSpace
            ).isActive = true
        self.contentStackView.rightAnchor.constraint(
            equalTo: self.contentView.rightAnchor,
            constant: -self.sizesAndDistances.stackViewSideSpace
            ).isActive = true
        self.contentStackView.bottomAnchor.constraint(
            greaterThanOrEqualTo: self.contentView.bottomAnchor,
            constant: -self.sizesAndDistances.minimumStackViewBottomSpace
            ).isActive = true
        self.contentStackView.bottomAnchor.constraint(
            lessThanOrEqualTo: self.contentView.bottomAnchor
            ).isActive = true
        self.contentStackView.centerXAnchor.constraint(
            equalTo: self.contentView.centerXAnchor
            ).isActive = true
    }
    
    private func setupPickGestureRecognizer() {
        self.pickGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.pick))
        if let gesture = self.pickGesture {
            gesture.allowableMovement = CGFloat.greatestFiniteMagnitude
            gesture.minimumPressDuration = 0
            gesture.cancelsTouchesInView = true
            self.contentView.addGestureRecognizer(gesture)
        }
    }
    
    private func observeReduceTransparencyStatus() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reduceTransparencyStatusDidChange),
            name: AccessibilityReduceTransparencyStatusDidChangeNotificationName,
            object: nil
        )
    }
    
    private func setupAccessibilityProperties() {
        self.isAccessibilityElement = false
        self.accessibilityElementsHidden = true
        self.accessibilityTraits = AccessibilityTraitNone
    }
    
    private func resetView() {
        self.deactivateConstraints(&self.contentStackViewConstraints)
        
        self.enqueueReusableObjects()
    }
    
    private func enqueueReusableObjects() {
        self.deactivateConstraints(&self.reusableObjectsConstraints)
        if let imageView = self.imageView {
            imageView.removeFromSuperview()
            StatusAlertDark.reusableImageViewsManager.enqueueReusable(imageView)
            self.imageView = nil
        }
        if let titleLabel = self.titleLabel {
            titleLabel.removeFromSuperview()
            StatusAlertDark.reusableLabelsManager.enqueueReusable(titleLabel)
            self.titleLabel = nil
        }
        if let messageLabel = self.messageLabel {
            messageLabel.removeFromSuperview()
            StatusAlertDark.reusableLabelsManager.enqueueReusable(messageLabel)
            self.messageLabel = nil
        }
    }
    
    private func deactivateConstraints(_ array: inout [NSLayoutConstraint]) {
        NSLayoutConstraint.deactivate(array)
        array = []
    }
    
    // MARK: Creation methods
    
    /// Must be called before the `StatusAlertDark` presenting
    private func prepareContent() {
        self.completeContentStackViewConstraints()
        
        self.imageView = self.createImageViewIfNeeded()
        if let imageView = self.imageView {
            let customSpace: CGFloat
            
            if self.title != nil && self.message != nil {
                customSpace = self.sizesAndDistances.imageBottomSpace
            } else if self.title == nil {
                customSpace = self.sizesAndDistances.imageToMessageSpace
            } else {
                customSpace = self.sizesAndDistances.titleBottomSpace
            }
            
            self.contentStackView.addArrangedSubview(imageView)
            if #available(iOS 11.0, *) {
                self.contentStackView.setCustomSpacing(customSpace, after: imageView)
            } else if self.title != nil || self.message != nil {
                let spaceView = self.createSpaceView(withHeight: customSpace)
                self.contentStackView.addArrangedSubview(spaceView)
            }
        }
        
        self.titleLabel = self.createTitleLabelIfNeeded()
        if let titleLabel = self.titleLabel {
            self.contentStackView.addArrangedSubview(titleLabel)
            if #available(iOS 11.0, *) {
                self.contentStackView.setCustomSpacing(self.sizesAndDistances.titleBottomSpace, after: titleLabel)
            } else if self.message != nil {
                let spaceView = self.createSpaceView(withHeight: self.sizesAndDistances.titleBottomSpace)
                self.contentStackView.addArrangedSubview(spaceView)
            }
        }
        
        self.messageLabel = self.createMessageLabelIfNeeded()
        if let messageLabel = self.messageLabel {
            self.contentStackView.addArrangedSubview(messageLabel)
        }
        
        NSLayoutConstraint.activate(self.reusableObjectsConstraints)
    }
    
    private func positionAlert(
        inPresenter presenter: UIView,
        withVerticalPosition verticalPosition: VerticalPosition,
        offset: CGFloat?
        ) {
        
        presenter.addSubview(self)
        
        self.centerXAnchor.constraint(equalTo: presenter.centerXAnchor).isActive = true
        
        switch verticalPosition {
        case .center:
            self.centerYAnchor.constraint(
                equalTo: presenter.centerYAnchor,
                constant: offset ?? 0
                ).isActive = true
        case .top:
            if #available(iOS 11, *) {
                self.topAnchor.constraint(
                    equalTo: presenter.safeAreaLayoutGuide.topAnchor,
                    constant: offset ?? self.sizesAndDistances.topOffset
                    ).isActive = true
            } else {
                self.topAnchor.constraint(
                    equalTo: presenter.topAnchor,
                    constant: offset ?? self.sizesAndDistances.topOffset
                    ).isActive = true
            }
        case .bottom:
            if #available(iOS 11, *) {
                self.bottomAnchor.constraint(
                    equalTo: presenter.safeAreaLayoutGuide.bottomAnchor,
                    constant: offset ?? -self.sizesAndDistances.bottomOffset
                    ).isActive = true
            } else {
                self.bottomAnchor.constraint(
                    equalTo: presenter.bottomAnchor,
                    constant: offset ?? -self.sizesAndDistances.bottomOffset
                    ).isActive = true
            }
        }
    }
    
    private func completeContentStackViewConstraints() {
        var constraints: [NSLayoutConstraint] = []
        if self.image != nil
            && (self.title != nil || self.message != nil) {
            
            constraints.append(self.contentView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: self.sizesAndDistances.minimumAlertHeight
            ))
            constraints.append(self.contentView.widthAnchor.constraint(
                equalToConstant: self.sizesAndDistances.alertWidth
            ))
            constraints.append(self.contentStackView.topAnchor.constraint(
                greaterThanOrEqualTo: self.contentView.topAnchor,
                constant: self.sizesAndDistances.minimumStackViewTopSpace
            ))
            constraints.append(self.contentStackView.centerYAnchor.constraint(
                equalTo: self.contentView.centerYAnchor,
                constant: (self.sizesAndDistances.minimumStackViewTopSpace - self.sizesAndDistances.minimumStackViewBottomSpace) / 2
            ))
        } else {
            if self.image == nil {
                constraints.append(self.contentView.widthAnchor.constraint(
                    equalToConstant: self.sizesAndDistances.alertWidth
                ))
            }
            constraints.append(self.contentStackView.topAnchor.constraint(
                greaterThanOrEqualTo: self.contentView.topAnchor,
                constant: self.sizesAndDistances.minimumStackViewBottomSpace
            ))
            constraints.append(self.contentStackView.centerYAnchor.constraint(
                equalTo: self.contentView.centerYAnchor
            ))
        }
        
        self.contentStackViewConstraints.append(contentsOf: constraints)
        NSLayoutConstraint.activate(self.contentStackViewConstraints)
    }
    
    @objc private func reduceTransparencyStatusDidChange() {
        self.setupContentViewBackground()
    }
    
    private func setupContentViewBackground() {
        if self.isBlurAvailable {
            self.contentView.backgroundColor = nil
            if #available(iOS 11, *) {
                self.contentView.effect = self.blurEffect
            } else if StatusAlertDark.currentlyPresentedStatusAlertDarks.contains(self) {
                self.contentView.effect = self.blurEffect
            }
        } else {
            self.contentView.effect = nil
            self.contentView.backgroundColor = self.appearance.backgroundColor
        }
    }
    
    private func createSpaceView(
        withHeight height: CGFloat
        ) -> UIView {
        
        let spaceView = StatusAlertDark.reusableSpaceViewsManager.dequeueReusable()
        let constraint = spaceView.heightAnchor.constraint(equalToConstant: height)
        self.reusableObjectsConstraints.append(constraint)
        return spaceView
    }
    
    private func createImageViewIfNeeded() -> UIImageView? {
        guard let image = self.image else { return nil }
        
        let imageView = StatusAlertDark.reusableImageViewsManager.dequeueReusable()
        imageView.image = image
        imageView.tintColor = self.appearance.tintColor
        let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: sizesAndDistances.imageWidth)
        self.reusableObjectsConstraints.append(widthConstraint)
        let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: sizesAndDistances.imageWidth)
        self.reusableObjectsConstraints.append(heightConstraint)
        
        return imageView
    }
    
    private func createTitleLabelIfNeeded() -> UILabel? {
        guard let title = self.title else { return nil }
        
        let titleLabel = self.createBaseLabel()
        titleLabel.font = self.appearance.titleFont
        
        let attributedText = NSAttributedString(
            string: title,
            attributes: [KernAttributeName: 0.01]
        )
        titleLabel.attributedText = attributedText
        
        return titleLabel
    }
    
    private func createMessageLabelIfNeeded() -> UILabel? {
        guard let message = self.message else { return nil }
        
        let messageLabel = self.createBaseLabel()
        messageLabel.font = self.appearance.messageFont
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.alignment = .center
        let attributedText = NSAttributedString(
            string: message,
            attributes: [
                KernAttributeName: 0.01,
                ParagraphStyleAttributeName: paragraphStyle
            ]
        )
        messageLabel.attributedText = attributedText
        
        return messageLabel
    }
    
    private func createBaseLabel() -> UILabel {
        let label = StatusAlertDark.reusableLabelsManager.dequeueReusable()
        label.textColor = self.appearance.tintColor
        return label
    }
    
    // MARK: Presentation methods
    
    private func prepareForPresentation(
        onPrepared: @escaping () -> Void
        ) {
        
        switch StatusAlertDark.multiplePresentationsBehavior {
        case .ignoreIfAlreadyPresenting:
            guard StatusAlertDark.currentlyPresentedStatusAlertDarks.isEmpty else { return }
            onPrepared()
        case .showMultiple:
            guard !StatusAlertDark.currentlyPresentedStatusAlertDarks.contains(self) else { return }
            onPrepared()
        case .dismissCurrentlyPresented:
            guard !StatusAlertDark.dismissing else { return }
            if !StatusAlertDark.currentlyPresentedStatusAlertDarks.isEmpty {
                StatusAlertDark.alertToPresent = self
                let group = DispatchGroup()
                for alert in StatusAlertDark.currentlyPresentedStatusAlertDarks {
                    group.enter()
                    alert.dismiss {
                        group.leave()
                    }
                }
                group.notify(queue: DispatchQueue.main) {
                    onPrepared()
                    StatusAlertDark.alertToPresent = nil
                }
            } else {
                onPrepared()
            }
        }
    }
    
    private func performPresentation() {
        StatusAlertDark.currentlyPresentedStatusAlertDarks.append(self)
        
        let scale: CGFloat = self.sizesAndDistances.initialScale
        let timer = Timer.scheduledTimer(
            timeInterval: self.alertShowingDuration - self.defaultFadeAnimationDuration,
            target: self,
            selector: #selector(self.dismissByTimer),
            userInfo: nil,
            repeats: false)
        RunLoop.main.add(
            timer,
            forMode: RunLoopCommonMode
        )
        self.timer = timer
        self.contentView.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
        
        UIView.animate(
            withDuration: self.defaultFadeAnimationDuration,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                if self.isBlurAvailable {
                    if #available(iOS 11, *) {
                        self.alpha = 1
                    } else {
                        self.contentView.contentView.alpha = 1
                        self.contentView.effect = self.blurEffect
                    }
                } else {
                    self.alpha = 1
                }
                self.contentView.transform = CGAffineTransform.identity
        },
            completion: { [weak self] (_) in
                self?.postAccessibilityAnnouncement()
        })
    }

    private func postAccessibilityAnnouncement() {
        let announcement = self.accessibilityAnnouncement
        #if swift(>=4.2)
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcement)
        #else
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, announcement)
        #endif
    }
    
    @objc private func dismissByTimer() {
        self.dismiss(completion: nil)
    }
    
    private func dismiss(completion: (() -> Void)?) {
        let scale: CGFloat = self.sizesAndDistances.initialScale
        self.timer?.invalidate()
        
        if self.pickGesture?.state != .changed
            && self.pickGesture?.state != .began {
            
            self.isUserInteractionEnabled = false
            UIView.animate(
                withDuration: self.defaultFadeAnimationDuration,
                delay: 0,
                options: [.curveEaseOut, .beginFromCurrentState],
                animations: {
                    if self.isBlurAvailable {
                        if #available(iOS 11, *) {
                            self.alpha = 0
                        } else {
                            self.alpha = 0
                            self.contentView.contentView.alpha = 0
                        }
                    } else {
                        self.alpha = 0
                    }
                    self.contentView.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            },
                completion: { [weak self] (_) in
                    if let strongSelf = self,
                        let index = StatusAlertDark.currentlyPresentedStatusAlertDarks.firstIndex(of: strongSelf) {
                        StatusAlertDark.currentlyPresentedStatusAlertDarks.remove(at: index)
                    }
                    self?.removeFromSuperview()
                    self?.resetView()
                    completion?()
            })
        }
    }
    
    // MARK: Utils
    
    private func assertIsMainThread() {
        precondition(Thread.isMainThread, "`StatusAlertDark` must only be used from the main thread.")
    }
    
    // MARK: - Reusable elements -
    
    // MARK: UIImageView
    
    private static let reusableImageViewsManager: ReusablesManager<UIImageView> = ReusablesManager(
        createReusableClosure: { () -> UIImageView in
            return StatusAlertDark.reusableImageView()
    },
        prepareForReuseClosure: nil,
        maximumReusablesNumber: 5
    )
    
    private static func reusableImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false
        imageView.accessibilityTraits = AccessibilityTraitNone
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    // MARK: UILabel
    
    private static let reusableLabelsManager: ReusablesManager<UILabel> = ReusablesManager(
        createReusableClosure: { () -> UILabel in
            return StatusAlertDark.reusableLabel()
    },
        prepareForReuseClosure: nil,
        maximumReusablesNumber: 5
    )
    
    private static func reusableLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isAccessibilityElement = false
        label.accessibilityTraits = AccessibilityTraitNone
        return label
    }
    
    // MARK: - SpaceView
    
    private static let reusableSpaceViewsManager: ReusablesManager<UIView> = ReusablesManager(
        createReusableClosure: { () -> UIView in
            return StatusAlertDark.reusableSpaceView()
    },
        prepareForReuseClosure: nil,
        maximumReusablesNumber: 10
    )
    
    private static func reusableSpaceView() -> UIView {
        let spaceView = UIView()
        spaceView.backgroundColor = UIColor.clear
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        return spaceView
    }
}

// Compatibility

#if swift(>=4.2)
private let KernAttributeName = NSAttributedString.Key.kern
private let ParagraphStyleAttributeName = NSAttributedString.Key.paragraphStyle
#elseif swift(>=4.0)
private let KernAttributeName = NSAttributedStringKey.kern
private let ParagraphStyleAttributeName = NSAttributedStringKey.paragraphStyle
#else
private let KernAttributeName = NSKernAttributeName
private let ParagraphStyleAttributeName = NSParagraphStyleAttributeName
#endif

#if swift(>=4.2)
private let NavigationControllerHideShowBarDuration = UINavigationController.hideShowBarDuration
private let AccessibilityReduceTransparencyStatusDidChangeNotificationName = UIAccessibility.reduceTransparencyStatusDidChangeNotification
private let AccessibilityTraitNone = UIAccessibilityTraits.none
private let RunLoopCommonMode = RunLoop.Mode.common
#else
private let NavigationControllerHideShowBarDuration = UINavigationControllerHideShowBarDuration
private let AccessibilityReduceTransparencyStatusDidChangeNotificationName = NSNotification.Name.UIAccessibilityReduceTransparencyStatusDidChange
private let AccessibilityTraitNone = UIAccessibilityTraitNone
private let RunLoopCommonMode = RunLoopMode.commonModes
#endif
