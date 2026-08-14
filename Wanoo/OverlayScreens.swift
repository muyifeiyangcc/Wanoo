import UIKit
import SnapKit

// MARK: - Figma overlay scene

/// The modal frames in Figma include the complete Home screen below the dimmer.
/// Keeping the backdrop as a real controller (instead of a flat screenshot) also
/// preserves the same safe-area and width behaviour on compact and large phones.
private final class OverlayHomeBackdropController: UIViewController {
    private let home = HomeViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(home)
        home.loadViewIfNeeded()
        tuneHomeForOverlayReference()
        view.addSubview(home.view)
        home.view.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(-8)
            $0.bottom.equalToSuperview()
        }
        home.didMove(toParent: self)
    }

    private func tuneHomeForOverlayReference() {
        let roomButtons = descendants(of: home.view, as: UIButton.self).filter {
            $0.currentTitle?.contains("online") == true
        }
        if roomButtons.indices.contains(0) {
            roomButtons[0].setBackgroundImage(UIImage(named: "Figma-256-1234-chatroom-stargazing1-712e30c2"), for: .normal)
            roomButtons[0].setTitle("  Stargazing Club\n  • 84 online      6/12", for: .normal)
        }
        if roomButtons.indices.contains(1) {
            roomButtons[1].setBackgroundImage(UIImage(named: "Figma-256-1234-chatroom-stargazing-72dd61d4"), for: .normal)
            roomButtons[1].setTitle("  Stargazing Club\n  • 84 online      6/12", for: .normal)
        }
        descendants(of: home.view, as: UILabel.self).forEach { label in
            if label.text == "HIKING" { label.text = "YOSEMITE · WEEKEND" }
        }
    }

    private func descendants<T: UIView>(of root: UIView, as type: T.Type) -> [T] {
        root.subviews.flatMap { child -> [T] in
            let match = (child as? T).map { [$0] } ?? []
            return match + descendants(of: child, as: type)
        }
    }
}

private final class OverlayColorBandView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var didConfigure = false

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !didConfigure else { return }
        didConfigure = true
        let gradient = layer as! CAGradientLayer
        gradient.colors = [
            UIColor(hex: 0xB9FF2C).cgColor,
            UIColor(hex: 0x71E4C5).cgColor,
            UIColor(hex: 0x8B7AF0).cgColor
        ]
        gradient.locations = [0, 0.52, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
    }

}

private final class OverlayWhiteFadeView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var didConfigure = false

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !didConfigure else { return }
        didConfigure = true
        let gradient = layer as! CAGradientLayer
        gradient.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
    }

}

struct OverlayPresentation {
    let title: String
    let message: String
    let secondaryTitle: String?
    let primaryTitle: String
    let designHeight: CGFloat
    let titleSize: CGFloat
    let messageSize: CGFloat

    init(
        title: String,
        message: String,
        secondaryTitle: String? = "Cancel",
        primaryTitle: String,
        designHeight: CGFloat,
        titleSize: CGFloat = 22,
        messageSize: CGFloat = 13
    ) {
        self.title = title
        self.message = message
        self.secondaryTitle = secondaryTitle
        self.primaryTitle = primaryTitle
        self.designHeight = designHeight
        self.titleSize = titleSize
        self.messageSize = messageSize
    }
}

class FigmaActionOverlayController: UIViewController {
    private let presentation: OverlayPresentation
    private let backdrop = OverlayHomeBackdropController()
    private let primaryAction: (() -> Void)?
    private let secondaryAction: (() -> Void)?

    init(
        presentation: OverlayPresentation,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.presentation = presentation
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        installBackdrop()
        installSheet()
    }

    private func installBackdrop() {
        addChild(backdrop)
        view.addSubview(backdrop.view)
        backdrop.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        backdrop.didMove(toParent: self)

        let dimmer = UIView()
        dimmer.backgroundColor = UIColor.black.withAlphaComponent(0.60)
        view.addSubview(dimmer)
        dimmer.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func installSheet() {
        let sheet = UIView()
        sheet.backgroundColor = .white
        sheet.layer.cornerRadius = 20
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheet.clipsToBounds = true
        view.addSubview(sheet)
        sheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }

        let background = UIImageView(image: UIImage(named: "alert_bg"))
        background.contentMode = .scaleToFill
        sheet.addSubview(background)
        background.snp.makeConstraints { $0.edges.equalToSuperview() }

        let titleLabel = UILabel()
        titleLabel.text = presentation.title
        titleLabel.textColor = Palette.ink
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = AppFont.nunito(presentation.titleSize, weight: .heavy)

        let messageLabel = UILabel()
        messageLabel.text = presentation.message
        messageLabel.textColor = Palette.ink
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = AppFont.nunito(presentation.messageSize, weight: .bold)

        let copy = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        copy.axis = .vertical
        copy.spacing = 9
        copy.alignment = .fill
        sheet.addSubview(copy)
        copy.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.trailing.equalToSuperview().inset(23)
        }

        let actions = UIStackView()
        actions.axis = .horizontal
        actions.spacing = 8
        actions.distribution = .fillEqually
        if let secondaryTitle = presentation.secondaryTitle {
            actions.addArrangedSubview(makeButton(title: secondaryTitle, primary: false, action: #selector(secondaryTapped)))
        }
        actions.addArrangedSubview(makeButton(title: presentation.primaryTitle, primary: true, action: #selector(primaryTapped)))
        sheet.addSubview(actions)
        actions.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(17)
            $0.top.equalTo(copy.snp.bottom).offset(18)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(18)
            $0.height.equalTo(44)
        }
    }

    private func makeButton(title: String, primary: Bool, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(primary ? .white : .black, for: .normal)
        button.titleLabel?.font = AppFont.nunito(14, weight: .heavy)
        button.backgroundColor = primary ? UIColor(hex: 0x7352CF) : UIColor(hex: 0xB8FF24)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func primaryTapped() {
        dismiss(animated: true, completion: primaryAction)
    }

    @objc private func secondaryTapped() {
        dismiss(animated: true, completion: secondaryAction)
    }
}

// MARK: - 297:5093 EULA

final class EULAOverlayController: UIViewController {
    private let backdrop = OverlayHomeBackdropController()
    private let onAccepted: (() -> Void)?
    private let onCancelled: (() -> Void)?

    init(onAccepted: (() -> Void)? = nil, onCancelled: (() -> Void)? = nil) {
        self.onAccepted = onAccepted
        self.onCancelled = onCancelled
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        isModalInPresentation = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        installBackdrop()
        installAgreementCard()
    }

    private func installBackdrop() {
        addChild(backdrop)
        view.addSubview(backdrop.view)
        backdrop.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        backdrop.didMove(toParent: self)
        let dimmer = UIView()
        dimmer.backgroundColor = UIColor.black.withAlphaComponent(0.60)
        view.addSubview(dimmer)
        dimmer.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func installAgreementCard() {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card.clipsToBounds = true
        view.addSubview(card)
        card.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            // 297:5093 begins at y=124 on the 375×812 reference (44pt top safe area).
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
        }

        let background = UIImageView(image: UIImage(named: "alert_bg"))
        background.contentMode = .scaleToFill
        card.addSubview(background)
        background.snp.makeConstraints { $0.edges.equalToSuperview() }

        let title = UILabel()
        title.text = "EULA"
        title.font = AppFont.nunito(22, weight: .heavy)
        title.textColor = Palette.ink
        title.textAlignment = .center
        card.addSubview(title)
        title.snp.makeConstraints { $0.top.equalToSuperview().offset(30); $0.leading.trailing.equalToSuperview().inset(20) }

        let text = UILabel()
        text.text = Self.agreementText
        text.font = AppFont.nunito(12, weight: .regular)
        text.textColor = Palette.ink
        text.numberOfLines = 0
        card.addSubview(text)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        card.addSubview(scroll)
        scroll.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
        scroll.addSubview(text)
        text.snp.makeConstraints {
            $0.edges.equalTo(scroll.contentLayoutGuide).inset(UIEdgeInsets(top: 0, left: 23, bottom: 10, right: 23))
            $0.width.equalTo(scroll.frameLayoutGuide).offset(-46)
        }

        let cancel = makeAgreementButton(title: "Cancel", primary: false, action: #selector(cancelTapped))
        let publish = makeAgreementButton(title: "Agree", primary: true, action: #selector(acceptTapped))
        let buttons = UIStackView(arrangedSubviews: [cancel, publish])
        buttons.spacing = 8
        buttons.distribution = .fillEqually
        card.addSubview(buttons)
        buttons.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(17)
            $0.top.equalTo(scroll.snp.bottom).offset(9)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
    }

    private func makeAgreementButton(title: String, primary: Bool, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(primary ? .white : .black, for: .normal)
        button.titleLabel?.font = AppFont.nunito(14, weight: .heavy)
        button.backgroundColor = primary ? UIColor(hex: 0x7352CF) : UIColor(hex: 0xB8FF24)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func acceptTapped() {
        AppRepository.shared.hasAcceptedEULA = true
        dismiss(animated: true, completion: onAccepted)
    }

    @objc private func cancelTapped() {
        if let onCancelled {
            dismiss(animated: true, completion: onCancelled)
        } else {
            exit(0)
        }
    }

    private static let agreementText = """
    Welcome to Wanoo! To create a positive, safe, and standardized space for outdoor exploration and community sharing, the following content is strictly prohibited on the app:

    1. Child Safety & Minor Protection: Any content involving child harm, pornography, or other materials detrimental to minors' physical and mental health—including but not limited to texts, images, videos, or comments that insult, defame, or improperly use minors' portraits and personal information.

    2. False & Harmful Public Information: False and harmful public information, including misleading content generated by AI or other means that disrupts public order—especially fake trail guides, misleading survival tutorials, dangerous route advice, or false public opinion content.

    3. Violent & Harassment Content: Violent content, cyberbullying, or any content that promotes illegal acts, or disrupts the community environment. Specifically, uploading pornographic, violent, or bloody content, or using comments, private messages, and chatroom features to conduct harassment is strictly forbidden.

    If any of the above violations are detected, your uploaded posts, comments, and other published content will be deleted, and your account will be restricted or banned. By clicking the confirmation button, you agree to abide by the Terms of Use and Privacy Policy of Wanoo.
    """
}

// MARK: - Remaining Figma alert frames

final class InsufficientBalanceAlertController: FigmaActionOverlayController {
    init(onRecharge: (() -> Void)? = nil) {
        super.init(
            presentation: OverlayPresentation(
                title: "Not Enough Coins",
                message: "You don't have enough Coins to\ncontinue. Would you like to\nrecharge now?",
                primaryTitle: "Confirm",
                designHeight: 277
            ),
            primaryAction: onRecharge
        )
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class LoginRequiredAlertController: FigmaActionOverlayController {
    init(onSignIn: (() -> Void)? = nil) {
        super.init(
            presentation: OverlayPresentation(
                title: "Sign In Required",
                message: "To ensure the normal operation of\nthe function, please sign in\nto your account first.",
                primaryTitle: "Sign In",
                designHeight: 277
            ),
            primaryAction: onSignIn
        )
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class PaymentConfirmAlertController: FigmaActionOverlayController {
    init(amount: Int = 0, purpose: String = "Adventure Passport", onConfirm: (() -> Void)? = nil) {
        let shownAmount = amount > 0 ? "\(amount)" : "XXX"
        super.init(
            presentation: OverlayPresentation(
                title: "Unlock Adventure\nPassport",
                message: "Are you sure you want to spend\n\(shownAmount) coins to unlock your\n\(purpose)?",
                primaryTitle: "Confirm",
                designHeight: 316
            ),
            primaryAction: onConfirm
        )
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class DeleteAccountAlertController: FigmaActionOverlayController {
    init(onDelete: (() -> Void)? = nil) {
        super.init(
            presentation: OverlayPresentation(
                title: "Delete Account",
                message: "Are you sure you want to delete\nthis account? All data will be\ncleared after deletion and cannot\nbe recovered.",
                primaryTitle: "Delete",
                designHeight: 295
            ),
            primaryAction: onDelete
        )
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class LogoutAlertController: FigmaActionOverlayController {
    init(onLogout: (() -> Void)? = nil) {
        super.init(
            presentation: OverlayPresentation(
                title: "Sign Out",
                message: "Are you sure you want to sign out\nof your account?",
                primaryTitle: "Sure",
                designHeight: 255
            ),
            primaryAction: onLogout
        )
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class AIContinuePaymentAlertController: FigmaActionOverlayController {
    init(costPerMessage: Int = 0, onContinue: (() -> Void)? = nil) {
        let cost = costPerMessage > 0 ? "\(costPerMessage)" : "xx"
        super.init(
            presentation: OverlayPresentation(
                title: "Continue\nwith AI Chat",
                message: "You’ve used all your free\nmessages. Continuing will cost\n\(cost) coins per message.",
                primaryTitle: "Continue",
                designHeight: 305
            ),
            primaryAction: onContinue
        )
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class ChatLimitAlertController: FigmaActionOverlayController {
    init(onConfirm: (() -> Void)? = nil) {
        super.init(
            presentation: OverlayPresentation(
                title: "Connect to Chat",
                message: "Follow each other to unlock\nmessages.",
                secondaryTitle: nil,
                primaryTitle: "Confirm",
                designHeight: 229
            ),
            primaryAction: onConfirm
        )
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
