import UIKit
import SnapKit
import Photos
import AVFoundation
import AVKit
import CoreText

enum Palette {
    static let purple = UIColor(hex: 0x7457C9)
    static let lime = UIColor(hex: 0xC8FF37)
    static let online = UIColor(hex: 0x73CC3C)
    static let top = UIColor(hex: 0xEAE6FC)
    static let base = UIColor(hex: 0xF7F8F5)
    static let ink = UIColor(hex: 0x111411)
    static let muted = UIColor(hex: 0x969D91)
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(red: CGFloat((hex >> 16) & 0xff) / 255, green: CGFloat((hex >> 8) & 0xff) / 255, blue: CGFloat(hex & 0xff) / 255, alpha: alpha)
    }
}

enum AppFont {
    private static let weightAxis = NSNumber(value: 2_003_265_652)

    static func nunito(_ size: CGFloat, weight: UIFont.Weight = .regular, italic: Bool = false) -> UIFont {
        variableFont(postScriptName: italic ? "Nunito-ExtraLightItalic" : "Nunito-ExtraLight", size: size, weight: axisValue(weight))
    }

    static func inter(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        variableFont(postScriptName: "Inter-Regular", size: size, weight: axisValue(weight))
    }

    static func validateRegisteredFonts() {
        ["Nunito-ExtraLight", "Nunito-ExtraLightItalic", "Inter-Regular"].forEach { name in
            precondition(UIFont(name: name, size: 14) != nil, "Required bundled font failed to load: \(name)")
        }
    }

    private static func variableFont(postScriptName: String, size: CGFloat, weight: CGFloat) -> UIFont {
        guard let base = UIFont(name: postScriptName, size: size) else {
            preconditionFailure("Required bundled font failed to load: \(postScriptName)")
        }
        let variationKey = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
        let descriptor = base.fontDescriptor.addingAttributes([variationKey: [weightAxis: weight]])
        return UIFont(descriptor: descriptor, size: size)
    }

    private static func axisValue(_ weight: UIFont.Weight) -> CGFloat {
        switch weight {
        case .black: return 900
        case .heavy: return 800
        case .bold: return 700
        case .semibold: return 600
        case .medium: return 500
        case .light: return 300
        default: return 400
        }
    }
}

final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gradient: CAGradientLayer { layer as! CAGradientLayer }
    func configureColors() {
        gradient.colors = [Palette.top.cgColor, Palette.base.cgColor]
        gradient.locations = [0, 0.3]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

final class DashedMediaButton: UIButton {
    private let dash = CAShapeLayer()
    var dashCornerRadius: CGFloat = 20 { didSet { setNeedsLayout() } }
    override func didMoveToSuperview() { super.didMoveToSuperview(); if dash.superlayer == nil { configureDash() } }
    private func configureDash() { dash.fillColor = UIColor.clear.cgColor; dash.strokeColor = Palette.purple.cgColor; dash.lineWidth = 2; dash.lineDashPattern = [6, 5]; layer.addSublayer(dash) }
    override func layoutSubviews() { super.layoutSubviews(); dash.frame = bounds; dash.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: dashCornerRadius).cgPath }
}

/// The canonical adventure feed cell used by Home, Search and theme lists.
/// Keeping the artwork and geometry here prevents those pages from drifting.
final class AdventureFeedCardView: UIView, UIGestureRecognizerDelegate {
    var onOpen: (() -> Void)?
    var onComment: (() -> Void)?
    var onLike: (() -> Void)?
    var onMore: (() -> Void)?
    private let postID: String

    init(post: AdventurePost, author: UserProfile?, heroAsset: String = "FigmaForest") {
        postID = post.id
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
        clipsToBounds = true

        let hero = UIImageView(image: PostMediaStore.previewImage(postID: post.id) ?? UIImage(named: heroAsset))
        hero.contentMode = .scaleAspectFill
        hero.clipsToBounds = true
        hero.layer.cornerRadius = 16
        hero.layer.cornerCurve = .continuous
        addSubview(hero)
        hero.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(190)
        }

        let eyebrowText = [post.location.isEmpty ? nil : post.location.uppercased(), post.duration.uppercased()].compactMap { $0 }.joined(separator: " · ")
        let eyebrow = makeLabel(eyebrowText, size: 11, weight: .heavy, color: Palette.lime)
        let title = makeLabel(post.title.uppercased(), size: 23, weight: .heavy, color: .white)
        hero.addSubview(eyebrow)
        hero.addSubview(title)
        eyebrow.snp.makeConstraints { $0.top.equalToSuperview().offset(15); $0.leading.equalToSuperview().offset(14) }
        title.snp.makeConstraints { $0.top.equalTo(eyebrow.snp.bottom).offset(1); $0.leading.equalTo(eyebrow); $0.trailing.lessThanOrEqualToSuperview().inset(12) }

        let hiking = chip(post.category, background: Palette.lime, color: Palette.ink, width: 66)
        let weekend = chip(post.duration, background: Palette.purple, color: .white, width: 74)
        let chips = UIStackView(arrangedSubviews: [hiking, weekend]); chips.spacing = 4
        hero.addSubview(chips)
        chips.snp.makeConstraints { $0.leading.equalToSuperview().offset(9); $0.bottom.equalToSuperview().inset(8); $0.height.equalTo(22) }

        let avatar = UIImageView(image: UserAvatarStore.displayImage(for: author, fallbackAsset: "Figma-256-1234-avatar-400b8f18"))
        avatar.tintColor = Palette.muted
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 20
        addSubview(avatar)
        avatar.snp.makeConstraints { $0.leading.equalToSuperview().offset(14); $0.top.equalTo(hero.snp.bottom).offset(12); $0.width.height.equalTo(40) }

        let name = makeLabel(author?.name ?? "Explorer", size: 14, weight: .bold)
        let location = makeLabel(post.location, size: 11, color: Palette.muted)
        addSubview(name); addSubview(location)
        name.snp.makeConstraints { $0.leading.equalTo(avatar.snp.trailing).offset(9); $0.top.equalTo(avatar).offset(1) }
        location.snp.makeConstraints { $0.leading.equalTo(name); $0.top.equalTo(name.snp.bottom); $0.trailing.lessThanOrEqualToSuperview().inset(12) }

        let story = makeLabel(post.story, size: 13, lines: 3)
        let paragraph = NSMutableParagraphStyle(); paragraph.lineSpacing = 2
        story.attributedText = NSAttributedString(string: post.story, attributes: [.font: story.font as Any, .foregroundColor: story.textColor as Any, .paragraphStyle: paragraph])
        addSubview(story)
        story.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(14); $0.top.equalTo(avatar.snp.bottom).offset(10) }

        let more = footerButton("··· More", action: #selector(moreTapped))
        let comment = footerButton("Comment  (\(post.comments.count))", image: "comment", action: #selector(commentTapped))
        let liked = AppRepository.shared.currentUserID.map { post.likedBy.contains($0) } == true
        let like = footerButton("\(post.likes)", image: "good", tint: liked ? Palette.purple : Palette.ink, action: #selector(likeTapped))
        addSubview(more); addSubview(comment); addSubview(like)
        more.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.top.equalTo(story.snp.bottom).offset(7)
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(20)
            $0.width.equalTo(58)
        }
        comment.snp.makeConstraints {
            $0.leading.equalTo(more.snp.trailing).offset(16)
            $0.centerY.equalTo(more)
            $0.height.equalTo(20)
        }
        like.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalTo(more)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(42)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(openTapped))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = Palette.ink, lines: Int = 1) -> UILabel {
        let label = UILabel(); label.text = text; label.font = AppFont.nunito(size, weight: weight); label.textColor = color; label.numberOfLines = lines; return label
    }
    private func chip(_ text: String, background: UIColor, color: UIColor, width: CGFloat) -> UILabel {
        let label = makeLabel(text, size: 11, weight: .bold, color: color)
        label.textAlignment = .center; label.backgroundColor = background; label.layer.cornerRadius = 11; label.clipsToBounds = true
        label.snp.makeConstraints { $0.width.equalTo(width) }
        return label
    }
    private func footerButton(_ title: String, image: String? = nil, tint: UIColor = Palette.ink, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.contentHorizontalAlignment = .leading
        let row = UIStackView(); row.alignment = .center; row.spacing = 4; row.isUserInteractionEnabled = false
        if let image { let icon = UIImageView(image: UIImage(named: image)?.withRenderingMode(.alwaysTemplate)); icon.tintColor = tint; icon.contentMode = .scaleAspectFit; icon.snp.makeConstraints { $0.width.height.equalTo(13) }; row.addArrangedSubview(icon) }
        let copy = makeLabel(title, size: 10, weight: .semibold, color: tint); row.addArrangedSubview(copy)
        button.addSubview(row); row.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.trailing.lessThanOrEqualToSuperview() }
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    @objc private func openTapped() { onOpen?() }
    @objc private func moreTapped() {
        if let onMore { onMore() }
        else { owningViewController?.presentAdventureActions(postID: postID) }
    }
    @objc private func commentTapped() { onComment?() }
    @objc private func likeTapped() { onLike?() }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var view: UIView? = touch.view
        while let current = view, current !== self {
            if current is UIControl { return false }
            view = current.superview
        }
        return true
    }
}

private extension UIView {
    var owningViewController: UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let controller = current as? UIViewController { return controller }
            responder = current.next
        }
        return nil
    }
}

extension UIViewController {
    func presentAdventureActions(postID: String, afterDelete: (() -> Void)? = nil, afterBlock: (() -> Void)? = nil) {
        let repository = AppRepository.shared
        guard repository.session == .authenticated else {
            present(WanooAlertController(titleText: "Sign In Required", messageText: "To ensure the normal operation of the function, please sign in to your account first.", secondaryTitle: "Cancel", primaryTitle: "Sign In", primaryAction: { AppRouter.showLogin(from: self) }), animated: true)
            return
        }
        guard let post = repository.post(id: postID), let currentUserID = repository.currentUserID else { return }
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if post.authorID == currentUserID {
            sheet.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let self else { return }
                let alert = WanooAlertController(
                    titleText: "Delete Adventure",
                    messageText: "Are you sure you want to delete this adventure? This action cannot be undone.",
                    secondaryTitle: "Cancel",
                    primaryTitle: "Delete",
                    primaryAction: {
                        guard repository.deletePost(postID: postID) else { return }
                        afterDelete?()
                    }
                )
                self.present(alert, animated: true)
            })
        } else {
            sheet.addAction(UIAlertAction(title: "Report", style: .default) { [weak self] _ in
                self?.navigationController?.pushViewController(ReportViewController(targetID: post.authorID), animated: true)
            })
            sheet.addAction(UIAlertAction(title: "Block", style: .destructive) { _ in
                repository.block(userID: post.authorID)
                afterBlock?()
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
}

enum PostMediaStore {
    static func records(postID: String) -> [String] {
        let modelRecords = AppRepository.shared.post(id: postID)?.mediaRecords ?? []
        return modelRecords.isEmpty ? UserDefaults.standard.stringArray(forKey: "wanoo.post.media." + postID) ?? [] : modelRecords
    }

    static func save(_ records: [String], postID: String) {
        UserDefaults.standard.set(records, forKey: "wanoo.post.media." + postID)
    }

    static func previewImage(for record: String) -> UIImage? {
        if record.hasPrefix("asset|") { return UIImage(named: String(record.dropFirst("asset|".count))) }
        if record.hasPrefix("bundle-video|") {
            guard let url = mediaURL(for: record) else { return nil }
            let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
            generator.appliesPreferredTrackTransform = true
            guard let frame = try? generator.copyCGImage(at: .zero, actualTime: nil) else { return nil }
            return UIImage(cgImage: frame)
        }
        let path = String(record.dropFirst(6))
        if record.hasPrefix("image|") { return UIImage(contentsOfFile: path) }
        guard record.hasPrefix("video|") else { return nil }
        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: URL(fileURLWithPath: path)))
        generator.appliesPreferredTrackTransform = true
        guard let frame = try? generator.copyCGImage(at: .zero, actualTime: nil) else { return nil }
        return UIImage(cgImage: frame)
    }

    static func previewImage(postID: String) -> UIImage? {
        records(postID: postID).first.flatMap(previewImage(for:))
    }

    static func present(record: String, allRecords: [String], from controller: UIViewController) {
        if isVideo(record), let url = mediaURL(for: record) {
            let player = AVPlayerViewController()
            player.player = AVPlayer(url: url)
            player.modalPresentationStyle = .fullScreen
            controller.present(player, animated: true) { player.player?.play() }
            return
        }
        let images = allRecords.filter { !isVideo($0) }.compactMap(previewImage(for:))
        guard !images.isEmpty else { return }
        controller.present(ImageGalleryViewController(images: images), animated: true)
    }

    static func isVideo(_ record: String) -> Bool { record.hasPrefix("video|") || record.hasPrefix("bundle-video|") }

    static func mediaURL(for record: String) -> URL? {
        if record.hasPrefix("video|") { return URL(fileURLWithPath: String(record.dropFirst("video|".count))) }
        guard record.hasPrefix("bundle-video|") else { return nil }
        let fileName = String(record.dropFirst("bundle-video|".count))
        let value = fileName as NSString
        return Bundle.main.url(forResource: value.deletingPathExtension, withExtension: value.pathExtension, subdirectory: "file")
            ?? Bundle.main.url(forResource: value.deletingPathExtension, withExtension: value.pathExtension)
    }
}

enum UserAvatarStore {
    static func image(userID: String?) -> UIImage? {
        guard let userID else { return nil }
        if let data = UserDefaults.standard.data(forKey: "profile-avatar-\(userID)"), let image = UIImage(data: data) { return image }
        if let asset = AppRepository.shared.user(id: userID)?.avatarAsset, !asset.isEmpty, let image = UIImage(named: asset) { return image }
        return defaultAvatar()
    }
    static func save(_ image: UIImage, userID: String?) { guard let userID, let data = image.jpegData(compressionQuality: 0.88) else { return }; UserDefaults.standard.set(data, forKey: "profile-avatar-\(userID)") }
    static func remove(userID: String) { UserDefaults.standard.removeObject(forKey: "profile-avatar-\(userID)") }
    static func defaultAvatar() -> UIImage? {
        UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 96, weight: .regular))?
            .withTintColor(Palette.muted, renderingMode: .alwaysOriginal)
    }
    static func displayImage(for user: UserProfile?, fallbackAsset: String) -> UIImage? {
        if let stored = image(userID: user?.id) { return stored }
        if let asset = user?.avatarAsset, !asset.isEmpty, let image = UIImage(named: asset) { return image }
        return defaultAvatar()
    }
}

class BaseScrollableViewController: UIViewController {
    let repository = AppRepository.shared
    let backgroundView = GradientView()
    let scrollView = UIScrollView()
    let contentView = UIView()
    let stack = UIStackView()
    private var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.configureColors()
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        view.addSubview(scrollView)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        contentView.addSubview(stack)
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.trailing.equalToSuperview().inset(18)
            $0.bottom.equalToSuperview().inset(28)
        }
        observer = NotificationCenter.default.addObserver(forName: AppRepository.changed, object: nil, queue: .main) { [weak self] _ in self?.repositoryDidChange() }
    }

    deinit { if let observer { NotificationCenter.default.removeObserver(observer) } }
    func repositoryDidChange() {}

    func configureSecondary(title: String) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = title
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goBack))
        hidesBottomBarWhenPushed = true
    }

    @objc private func goBack() { navigationController?.popViewController(animated: true) }

    func titleLabel(_ text: String, size: CGFloat = 28) -> UILabel {
        label(text, size: size, weight: .black, color: Palette.ink)
    }

    func label(_ text: String, size: CGFloat = 14, weight: UIFont.Weight = .regular, color: UIColor = Palette.ink, lines: Int = 0) -> UILabel {
        let value = UILabel()
        value.text = text
        value.font = AppFont.nunito(size, weight: weight)
        value.textColor = color
        value.numberOfLines = lines
        return value
    }

    func field(_ placeholder: String, secure: Bool = false) -> UITextField {
        let value = UITextField()
        value.placeholder = placeholder
        value.isSecureTextEntry = secure
        value.font = AppFont.nunito(14)
        value.backgroundColor = .white
        value.layer.cornerRadius = 16
        value.leftViewMode = .always
        let inset = UIView()
        inset.snp.makeConstraints { $0.width.equalTo(16) }
        value.leftView = inset
        value.snp.makeConstraints { $0.height.greaterThanOrEqualTo(52) }
        return value
    }

    func button(_ title: String, primary: Bool = true, action: Selector) -> UIButton {
        let value = UIButton(type: .system)
        value.setTitle(title, for: .normal)
        value.titleLabel?.font = AppFont.nunito(15, weight: .bold)
        value.setTitleColor(primary ? Palette.ink : Palette.purple, for: .normal)
        value.backgroundColor = primary ? Palette.lime : .white
        value.layer.cornerRadius = 22
        value.snp.makeConstraints { $0.height.greaterThanOrEqualTo(48) }
        value.addTarget(self, action: action, for: .touchUpInside)
        return value
    }

    func card() -> UIView {
        let value = UIView()
        value.backgroundColor = .white
        value.layer.cornerRadius = 24
        value.layer.shadowColor = UIColor.black.cgColor
        value.layer.shadowOpacity = 0.05
        value.layer.shadowRadius = 12
        value.layer.shadowOffset = CGSize(width: 0, height: 6)
        return value
    }

    func section(_ title: String) -> UILabel { label(title, size: 18, weight: .heavy) }

    func showMessage(_ title: String, message: String, actionTitle: String = "OK", action: (() -> Void)? = nil) {
        present(WanooAlertController(titleText: title, messageText: message, secondaryTitle: nil, primaryTitle: actionTitle, primaryAction: action), animated: true)
    }

    func requireLogin(_ proceed: @escaping () -> Void) {
        if repository.session == .authenticated { proceed(); return }
        present(WanooAlertController(titleText: "Sign In Required", messageText: "To ensure the normal operation of the function, please sign in to your account first.", secondaryTitle: "Cancel", primaryTitle: "Sign In", primaryAction: { AppRouter.showLogin(from: self) }), animated: true)
    }

    func confirmSpend(amount: Int, purpose: String, completion: @escaping () -> Void) {
        guard (repository.currentUser?.coins ?? 0) >= amount else {
            present(WanooAlertController(titleText: "Not Enough Coins", messageText: "You don't have enough coins to continue. Would you like to recharge now?", secondaryTitle: "Cancel", primaryTitle: "Confirm", primaryAction: { self.navigationController?.pushViewController(RechargeViewController(), animated: true) }), animated: true)
            return
        }
        present(WanooAlertController(titleText: "Unlock Adventure Passport", messageText: "Are you sure you want to spend \(amount) coins for \(purpose)?", secondaryTitle: "Cancel", primaryTitle: "Confirm", primaryAction: { if self.repository.spendCoins(amount) { completion() } }), animated: true)
    }

    func chooseMedia(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate, mediaTypes: [String] = ["public.image"]) {
        let sheet = UIAlertController(title: "Choose media", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            AVCaptureDevice.requestAccess(for: .video) { allowed in
                DispatchQueue.main.async {
                    guard allowed, UIImagePickerController.isSourceTypeAvailable(.camera) else { self.showPermissionSettings(message: "Allow camera access in Settings to capture media."); return }
                    let picker = UIImagePickerController(); picker.delegate = delegate; picker.sourceType = .camera; picker.mediaTypes = mediaTypes; self.present(picker, animated: true)
                }
            }
        })
        sheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    guard status == .authorized || status == .limited else { self.showPermissionSettings(message: "Allow photo access in Settings to choose media."); return }
                    let picker = UIImagePickerController(); picker.delegate = delegate; picker.sourceType = .photoLibrary; picker.mediaTypes = mediaTypes; self.present(picker, animated: true)
                }
            }
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func showPermissionSettings(message: String) {
        let alert = WanooAlertController(titleText: "Access Needed", messageText: message, secondaryTitle: "Cancel", primaryTitle: "Open Settings", primaryAction: {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        present(alert, animated: true)
    }
}

final class ChipButton: UIButton {
    override var isSelected: Bool { didSet { backgroundColor = isSelected ? Palette.lime : .white } }
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(Palette.ink, for: .normal)
        titleLabel?.font = AppFont.nunito(11, weight: .bold)
        backgroundColor = .white
        layer.cornerRadius = 14
        contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        snp.makeConstraints { $0.height.equalTo(28) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class AvatarView: UIView {
    init(name: String, size: CGFloat = 40, assetName: String = "Figma-256-1234-avatar-400b8f18") {
        super.init(frame: .zero)
        layer.cornerRadius = size / 2
        clipsToBounds = true
        let value = UIImageView(image: UIImage(named: assetName))
        value.contentMode = .scaleAspectFill
        addSubview(value)
        value.snp.makeConstraints { $0.edges.equalToSuperview() }
        snp.makeConstraints { $0.width.height.equalTo(size) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class WanooAlertController: UIViewController {
    private let titleText: String
    private let messageText: String
    private let secondaryTitle: String?
    private let primaryTitle: String
    private let primaryAction: (() -> Void)?
    private let secondaryAction: (() -> Void)?

    init(titleText: String, messageText: String, secondaryTitle: String?, primaryTitle: String, primaryAction: (() -> Void)? = nil, secondaryAction: (() -> Void)? = nil) {
        self.titleText = titleText; self.messageText = messageText; self.secondaryTitle = secondaryTitle; self.primaryTitle = primaryTitle; self.primaryAction = primaryAction; self.secondaryAction = secondaryAction
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.62)
        let card = UIView(); card.backgroundColor = .white; card.layer.cornerRadius = 20; card.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]; card.clipsToBounds = true
        view.addSubview(card); card.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview() }
        let background = UIImageView(image: UIImage(named: "alert_bg")); background.contentMode = .scaleToFill
        card.addSubview(background); background.snp.makeConstraints { $0.edges.equalToSuperview() }
        let stack = UIStackView(); stack.axis = .vertical; stack.spacing = 9; stack.alignment = .fill
        card.addSubview(stack); stack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.trailing.equalToSuperview().inset(17)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(18)
        }
        let title = UILabel(); title.text = titleText; title.textAlignment = .center; title.numberOfLines = 0; title.font = AppFont.nunito(22, weight: .heavy)
        let message = UILabel(); message.text = messageText; message.textAlignment = .center; message.numberOfLines = 0; message.font = AppFont.nunito(14, weight: .regular)
        message.setContentCompressionResistancePriority(.required, for: .vertical)
        stack.addArrangedSubview(title); stack.addArrangedSubview(message)
        stack.setCustomSpacing(18, after: message)
        let buttons = UIStackView(); buttons.spacing = 6; buttons.distribution = .fillEqually
        if let secondaryTitle { buttons.addArrangedSubview(alertButton(secondaryTitle, color: Palette.lime, selector: #selector(cancel))) }
        buttons.addArrangedSubview(alertButton(primaryTitle, color: Palette.purple, selector: #selector(confirm)))
        stack.addArrangedSubview(buttons)
    }
    private func alertButton(_ title: String, color: UIColor, selector: Selector) -> UIButton { let button = UIButton(type: .system); button.setTitle(title, for: .normal); button.setTitleColor(color == Palette.purple ? .white : Palette.ink, for: .normal); button.titleLabel?.font = AppFont.nunito(14, weight: .heavy); button.backgroundColor = color; button.layer.cornerRadius = 12; button.snp.makeConstraints { $0.height.equalTo(44) }; button.addTarget(self, action: selector, for: .touchUpInside); return button }
    @objc private func cancel() { dismiss(animated: true, completion: secondaryAction) }
    @objc private func confirm() { dismiss(animated: true, completion: primaryAction) }
}

final class EmptyStateView: UIView {
    init(text: String) {
        super.init(frame: .zero)
        let icon = UIImageView(image: UIImage(systemName: "sparkles"))
        icon.tintColor = Palette.purple
        let label = UILabel()
        label.text = text
        label.font = AppFont.nunito(14, weight: .semibold)
        label.textColor = Palette.muted
        label.textAlignment = .center
        label.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .vertical; stack.alignment = .center; stack.spacing = 12
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(24) }
        icon.snp.makeConstraints { $0.width.height.equalTo(28) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

enum AppRouter {
    static func mainController() -> UIViewController { MainTabBarController() }

    static func installRoot(_ controller: UIViewController, from source: UIViewController? = nil) {
        guard let scene = source?.view.window?.windowScene ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
              let delegate = scene.delegate as? SceneDelegate else { return }
        delegate.window?.rootViewController = controller
        UIView.transition(with: delegate.window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }

    static func showLogin(from source: UIViewController) {
        let controller = UINavigationController(rootViewController: WelcomeViewController())
        controller.modalPresentationStyle = .fullScreen
        source.present(controller, animated: true)
    }
}
