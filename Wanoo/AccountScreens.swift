import UIKit
import SnapKit
import StoreKit

final class ReportViewController: BaseScrollableViewController {
    private let targetID: String; private let detail = UITextView(); private var reason = AppRepository.shared.reportReasons[2]; private var reasonButtons: [UIButton] = []
    init(targetID: String) { self.targetID = targetID; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); stack.spacing = 12; stack.snp.updateConstraints { $0.top.equalToSuperview().offset(2); $0.bottom.equalToSuperview() }; contentView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide) }
        stack.addArrangedSubview(accountHeader("Report")); stack.addArrangedSubview(titleLabel("Why are you reporting this\nAdventure?", size: 21)); stack.addArrangedSubview(label("Your report is private. We’ll review the content and account.", size: 12, lines: 0))
        repository.reportReasons.forEach { value in let row = UIButton(type: .system); row.accessibilityIdentifier = value; row.backgroundColor = .white; row.layer.cornerRadius = 16; row.layer.cornerCurve = .continuous; let dot = UIView(); dot.tag = 91; dot.layer.cornerRadius = 9; dot.isUserInteractionEnabled = false; row.addSubview(dot); dot.snp.makeConstraints { $0.leading.equalToSuperview().offset(14); $0.centerY.equalToSuperview(); $0.width.height.equalTo(18) }; let reasonLabel = label(value, size: 13, weight: .semibold); reasonLabel.isUserInteractionEnabled = false; row.addSubview(reasonLabel); reasonLabel.snp.makeConstraints { $0.leading.equalTo(dot.snp.trailing).offset(14); $0.trailing.lessThanOrEqualToSuperview().inset(12); $0.centerY.equalToSuperview() }; row.snp.makeConstraints { $0.height.equalTo(46) }; row.addTarget(self, action: #selector(selectReason(_:)), for: .touchUpInside); reasonButtons.append(row); stack.addArrangedSubview(row) }
        detail.isHidden = true; let spacer = UIView(); spacer.snp.makeConstraints { $0.height.greaterThanOrEqualTo(0).priority(.low) }; stack.addArrangedSubview(spacer); let submit = button("Continue", action: #selector(submit)); submit.backgroundColor = Palette.purple; submit.setTitleColor(.white, for: .normal); submit.layer.cornerRadius = 16; submit.layer.cornerCurve = .continuous; submit.titleLabel?.font = AppFont.nunito(20, weight: .bold); submit.snp.makeConstraints { $0.height.equalTo(54) }; stack.addArrangedSubview(submit); refreshReasons()
    }
    @objc private func selectReason(_ sender: UIButton) { reason = sender.accessibilityIdentifier ?? reason; refreshReasons() }
    private func refreshReasons() { reasonButtons.forEach { button in button.viewWithTag(91)?.backgroundColor = button.accessibilityIdentifier == reason ? Palette.lime : Palette.base } }
    @objc private func submit() { if reason == "Something else" && detail.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { showMessage("Add more detail", message: "Tell us what happened before submitting."); return }; repository.report(targetID: targetID, reason: reason, detail: detail.text); showMessage("Report submitted", message: "Thank you. Your report has been recorded.", action: { self.navigationController?.popViewController(animated: true) }) }
}

final class BlockListViewController: BaseScrollableViewController {
    override func viewDidLoad() { super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); contentView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide) }; render() }
    private func render() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.addArrangedSubview(accountHeader("Blocked Users"))
        if repository.blocked.isEmpty {
            stack.addArrangedSubview(EmptyStateView(text: "Your block list is empty."))
        } else {
            repository.blocked.forEach { id in
                let value = accountUserRow(userID: id, actionTitle: "Unblock")
                value.addAction(UIAction { [weak self] _ in self?.confirmUnblock(userID: id) }, for: .touchUpInside)
                stack.addArrangedSubview(value)
            }
        }
        let flexible = UIView()
        flexible.snp.makeConstraints { $0.height.greaterThanOrEqualTo(0).priority(.low) }
        stack.addArrangedSubview(flexible)
    }
    @objc private func noop() {}
    private func confirmUnblock(userID: String) {
        let name = repository.user(id: userID)?.name ?? "this user"
        present(WanooAlertController(titleText: "Unblock User", messageText: "Unblock \(name)? Their content will become visible again.", secondaryTitle: "Cancel", primaryTitle: "Unblock", primaryAction: { self.repository.unblock(userID: userID) }), animated: true)
    }
    override func repositoryDidChange() { render() }
}

final class AccountFollowListViewController: BaseScrollableViewController {
    enum Kind { case followers, following }
    private let kind: Kind; private let visualIDs: [String]?
    init(kind: Kind, visualIDs: [String]? = nil) { self.kind = kind; self.visualIDs = visualIDs; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() { super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); contentView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide) }; render() }
    private func render() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.addArrangedSubview(accountHeader(kind == .followers ? "Followers" : "Following"))
        let ids: [String] = visualIDs ?? Array(kind == .followers ? repository.currentUser?.followers ?? [] : repository.currentUser?.following ?? [])
        if ids.isEmpty {
            stack.addArrangedSubview(EmptyStateView(text: "No explorers to show."))
        } else {
            ids.filter { !repository.blocked.contains($0) }.forEach { id in
                let isFollowing = repository.currentUser?.following.contains(id) == true
                let action = kind == .following || isFollowing ? "Following" : "Follow"
                let row = accountUserRow(userID: id, actionTitle: action, highlighted: action == "Follow")
                row.addAction(UIAction { [weak self] _ in self?.confirmFollowAction(userID: id, isFollowing: isFollowing) }, for: .touchUpInside)
                stack.addArrangedSubview(row)
            }
        }
        let flexible = UIView()
        flexible.snp.makeConstraints { $0.height.greaterThanOrEqualTo(0).priority(.low) }
        stack.addArrangedSubview(flexible)
    }
    private func confirmFollowAction(userID: String, isFollowing: Bool) {
        let name = repository.user(id: userID)?.name ?? "this explorer"
        let title = isFollowing ? "Unfollow \(name)?" : "Follow \(name)?"
        let message = isFollowing ? "Their new adventures will no longer appear through your following relationship." : "Their new adventures will appear through your following relationship."
        present(WanooAlertController(titleText: title, messageText: message, secondaryTitle: "Cancel", primaryTitle: isFollowing ? "Unfollow" : "Follow", primaryAction: { self.repository.toggleFollow(userID: userID) }), animated: true)
    }
    override func repositoryDidChange() { render() }
}

final class EditProfileViewController: BaseScrollableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let name = UITextField(); private let bio = UITextView(); private let avatar = UIButton(type: .system); private let visualMode: Bool; private var changed = false; private var selectedAvatar: UIImage?
    init(visualMode: Bool = false) { self.visualMode = visualMode; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { self.visualMode = false; super.init(coder: coder) }
    override func viewDidLoad() {
        super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); stack.spacing = 12
        contentView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide) }; stack.snp.updateConstraints { $0.bottom.equalToSuperview() }
        let header = accountHeader("Edit Profile", backAction: #selector(attemptBack)); stack.addArrangedSubview(header)
        let avatarSpacer = UIView(); avatarSpacer.snp.makeConstraints { $0.height.equalTo(31) }; stack.addArrangedSubview(avatarSpacer)
        let avatarWrap = UIView(); avatarWrap.snp.makeConstraints { $0.height.equalTo(120) }; avatarWrap.addSubview(avatar)
        avatar.setBackgroundImage(savedAvatar(), for: .normal); avatar.tintColor = Palette.muted; avatar.imageView?.contentMode = .scaleAspectFill; avatar.layer.cornerRadius = 60; avatar.clipsToBounds = true; avatar.addTarget(self, action: #selector(photo), for: .touchUpInside); avatar.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(120) }
        let camera = UIImageView(image: UIImage(named: "Figma-289-4969-21-2d73f1d3")); camera.contentMode = .scaleAspectFit; avatar.addSubview(camera); camera.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.bottom.equalToSuperview().inset(8); $0.width.height.equalTo(25) }; stack.addArrangedSubview(avatarWrap)
        let heading = titleLabel("Improve your profile", size: 28); heading.font = AppFont.nunito(28, weight: .black); heading.textAlignment = .center; let headingWrap = UIView(); headingWrap.addSubview(heading); heading.snp.makeConstraints { $0.center.equalToSuperview() }; headingWrap.snp.makeConstraints { $0.height.equalTo(51) }; stack.addArrangedSubview(headingWrap)
        guard let user = repository.currentUser else { return }
        stack.addArrangedSubview(fieldCaption("Name")); name.placeholder = "Where are you name?"; name.text = visualMode ? nil : user.name; styleNameField(); stack.addArrangedSubview(name)
        stack.addArrangedSubview(fieldCaption("Bio")); bio.text = visualMode ? "Tell the community a little about yourself..." : user.bio; bio.textColor = visualMode || user.bio.isEmpty ? UIColor(hex: 0xADB2AB) : Palette.ink; bio.font = AppFont.nunito(13); bio.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 10, right: 10); bio.backgroundColor = .white; bio.layer.cornerRadius = 15; bio.delegate = self; bio.snp.makeConstraints { $0.height.equalTo(73) }; stack.addArrangedSubview(bio)
        let flexible = UIView(); flexible.snp.makeConstraints { $0.height.greaterThanOrEqualTo(0).priority(.low) }; stack.addArrangedSubview(flexible)
        let saveButton = button("Save", action: #selector(save)); saveButton.backgroundColor = Palette.purple; saveButton.setTitleColor(.white, for: .normal); saveButton.layer.cornerRadius = 16; saveButton.titleLabel?.font = AppFont.nunito(20, weight: .black); saveButton.snp.makeConstraints { $0.height.equalTo(54) }; stack.addArrangedSubview(saveButton)
    }
    private func fieldCaption(_ text: String) -> UILabel { label(text, size: 13, weight: .semibold) }
    private func styleNameField() { name.backgroundColor = .white; name.layer.cornerRadius = 15; name.font = AppFont.nunito(13); name.addTarget(self, action: #selector(didEdit), for: .editingChanged); let inset = UIView(); inset.snp.makeConstraints { $0.width.equalTo(14) }; name.leftView = inset; name.leftViewMode = .always; name.snp.makeConstraints { $0.height.equalTo(44) } }
    @objc private func didEdit() { changed = true }
    @objc private func photo() { chooseMedia(delegate: self) }
    @objc private func save() {
        let value = name.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let bioValue = placeholderVisible ? "" : bio.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, value.count <= 40, bioValue.count <= 160 else {
            showMessage("Check your profile", message: "Enter a name under 40 characters and a bio under 160 characters.")
            return
        }
        if let selectedAvatar {
            UserAvatarStore.save(selectedAvatar, userID: repository.currentUserID)
        }
        repository.updateProfile(name: value, bio: bioValue, location: repository.currentUser?.location ?? "")
        changed = false
        navigationController?.popViewController(animated: true)
    }
    @objc private func attemptBack() { guard changed else { navigationController?.popViewController(animated: true); return }; present(WanooAlertController(titleText: "Discard Changes?", messageText: "Your edits have not been saved.", secondaryTitle: "Keep Editing", primaryTitle: "Discard", primaryAction: { self.changed = false; self.navigationController?.popViewController(animated: true) }), animated: true) }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage { selectedAvatar = image; avatar.setBackgroundImage(image, for: .normal); changed = true }; dismiss(animated: true) }
    private func savedAvatar() -> UIImage? { UserAvatarStore.image(userID: repository.currentUserID) ?? UserAvatarStore.defaultAvatar() }
    private var placeholderVisible: Bool { bio.textColor == UIColor(hex: 0xADB2AB) }
}

extension EditProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) { if placeholderVisible { textView.text = ""; textView.textColor = Palette.ink }; changed = true }
    func textViewDidChange(_ textView: UITextView) { changed = true }
}

final class SettingsViewController: BaseScrollableViewController {
    override func viewDidLoad() {
        super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); stack.spacing = 10
        stack.snp.updateConstraints { $0.top.equalToSuperview().offset(2) }
        contentView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide) }
        stack.addArrangedSubview(accountHeader("Settings"))
        let gap = UIView(); gap.snp.makeConstraints { $0.height.equalTo(17) }; stack.addArrangedSubview(gap)
        [("Privacy Policy", #selector(privacy)), ("Terms of Service", #selector(terms)), ("Block List", #selector(blocks))].forEach { stack.addArrangedSubview(settingsRow($0.0, action: $0.1)) }
        let sectionGap = UIView(); sectionGap.snp.makeConstraints { $0.height.equalTo(19) }; stack.addArrangedSubview(sectionGap)
        stack.addArrangedSubview(settingsRow("Log Out", action: #selector(logout)))
        stack.addArrangedSubview(settingsRow("Delete Account", destructive: true, action: #selector(deleteAccount)))
        let flexible = UIView()
        flexible.snp.makeConstraints { $0.height.greaterThanOrEqualTo(0).priority(.low) }
        stack.addArrangedSubview(flexible)
    }
    private func settingsRow(_ title: String, destructive: Bool = false, action: Selector) -> UIButton { let value = UIButton(type: .system); value.contentHorizontalAlignment = .leading; value.setTitle(title, for: .normal); value.setTitleColor(destructive ? .red : Palette.ink, for: .normal); value.titleLabel?.font = AppFont.nunito(14, weight: .semibold); value.backgroundColor = destructive ? UIColor(hex: 0xFFE2E2) : .white; value.layer.cornerRadius = 16; value.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16); value.snp.makeConstraints { $0.height.equalTo(55) }; value.addTarget(self, action: action, for: .touchUpInside); return value }
    @objc private func privacy() { navigationController?.pushViewController(AgreementViewController(pageTitle: "Privacy Policy"), animated: true) }
    @objc private func terms() { navigationController?.pushViewController(AgreementViewController(pageTitle: "Terms of Service"), animated: true) }
    @objc private func blocks() { navigationController?.pushViewController(BlockListViewController(), animated: true) }
    @objc private func logout() { present(WanooAlertController(titleText: "Sign Out", messageText: "Are you sure you want to sign out of your account?", secondaryTitle: "Cancel", primaryTitle: "Sure", primaryAction: { self.repository.signOut(); AppRouter.installRoot(UINavigationController(rootViewController: WelcomeViewController()), from: self) }), animated: true) }
    @objc private func deleteAccount() { present(WanooAlertController(titleText: "Delete Account", messageText: "Are you sure you want to delete this account? All data will be cleared after deletion and cannot be recovered.", secondaryTitle: "Cancel", primaryTitle: "Delete", primaryAction: { self.repository.deleteCurrentAccount(); AppRouter.installRoot(UINavigationController(rootViewController: WelcomeViewController()), from: self) }), animated: true) }
}

final class RechargeViewController: BaseScrollableViewController {
    private let list = UIStackView()
    private let loading = UIActivityIndicatorView(style: .large)
    private let loadingCover = UIView()
    private let balanceAmount = UILabel()
    private let continueButton = UIButton(type: .system)
    private var selected: SKProduct?
    private var selectedVisualIndex = 2
    private let visualPackages: Bool

    init(visualPackages: Bool = false) { self.visualPackages = visualPackages; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { self.visualPackages = false; super.init(coder: coder) }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        scrollView.contentInset.bottom = 88
        scrollView.verticalScrollIndicatorInsets.bottom = 88
        stack.spacing = 14
        stack.addArrangedSubview(accountHeader("Wanoo Coins"))
        stack.setCustomSpacing(18, after: stack.arrangedSubviews.last!)

        let balance = UIView()
        balance.layer.cornerRadius = 20
        balance.layer.cornerCurve = .continuous
        balance.clipsToBounds = true
        balance.snp.makeConstraints { $0.height.equalTo(98) }
        let background = UIImageView(image: UIImage(named: "me_bg"))
        background.contentMode = .scaleAspectFill
        balance.addSubview(background)
        background.snp.makeConstraints { $0.edges.equalToSuperview() }
        let caption = label("CURRENT BALANCE", size: 10, weight: .black, color: .white)
        balance.addSubview(caption)
        caption.snp.makeConstraints { $0.leading.equalToSuperview().offset(17); $0.top.equalToSuperview().offset(27) }
        balanceAmount.font = AppFont.nunito(36, weight: .black)
        balanceAmount.textColor = Palette.lime
        balance.addSubview(balanceAmount)
        balanceAmount.snp.makeConstraints { $0.leading.equalTo(caption); $0.top.equalTo(caption.snp.bottom).offset(1) }
        let coinsCaption = label("coins", size: 13, weight: .bold, color: .white)
        balance.addSubview(coinsCaption)
        coinsCaption.snp.makeConstraints { $0.leading.equalTo(balanceAmount.snp.trailing).offset(8); $0.lastBaseline.equalTo(balanceAmount).offset(-5) }
        stack.addArrangedSubview(balance)
        stack.setCustomSpacing(28, after: balance)

        let heading = label("Choose a pack", size: 20, weight: .black)
        stack.addArrangedSubview(heading)
        stack.setCustomSpacing(15, after: heading)
        list.axis = .vertical
        list.spacing = 12
        stack.addArrangedSubview(list)

        continueButton.setTitle("Buy", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = AppFont.nunito(20, weight: .black)
        continueButton.backgroundColor = Palette.purple
        continueButton.layer.cornerRadius = 17
        continueButton.layer.cornerCurve = .continuous
        continueButton.addTarget(self, action: #selector(continuePurchase), for: .touchUpInside)
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(18); $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(3); $0.height.equalTo(54) }

        loadingCover.backgroundColor = UIColor.white.withAlphaComponent(0.58)
        loadingCover.isHidden = true
        view.addSubview(loadingCover)
        loadingCover.snp.makeConstraints { $0.edges.equalToSuperview() }
        loading.color = Palette.purple
        loadingCover.addSubview(loading)
        loading.snp.makeConstraints { $0.center.equalToSuperview() }

        NotificationCenter.default.addObserver(self, selector: #selector(stateChanged), name: InAppPurchaseManager.stateChanged, object: InAppPurchaseManager.shared)
        if visualPackages { render() } else { InAppPurchaseManager.shared.loadProducts(); render() }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func render() {
        balanceAmount.text = NumberFormatter.localizedString(from: NSNumber(value: repository.currentUser?.coins ?? 0), number: .decimal)
        list.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let products = InAppPurchaseManager.shared.products
        if visualPackages && products.isEmpty {
            [(400, "$0.99"), (800, "$1.99"), (2_450, "$4.99"), (5_150, "$9.99"), (6_400, "$12.99"), (10_800, "$19.99"), (14_900, "$24.99"), (29_400, "$49.99"), (39_500, "$79.99"), (63_700, "$99.99")].enumerated().forEach { index, pack in
                let row = packageRow(amount: pack.0, price: pack.1, selected: index == selectedVisualIndex)
                row.addAction(UIAction { [weak self] _ in self?.selectedVisualIndex = index; self?.render() }, for: .touchUpInside)
                list.addArrangedSubview(row)
            }
        } else if products.isEmpty {
            list.addArrangedSubview(EmptyStateView(text: "Coin packs are being prepared."))
        } else {
            if selected == nil { selected = products[min(2, products.count - 1)] }
            products.forEach { product in
                let row = packageRow(
                    amount: InAppPurchaseManager.shared.coinAmount(for: product),
                    price: InAppPurchaseManager.shared.dollarPrice(for: product),
                    selected: selected?.productIdentifier == product.productIdentifier
                )
                row.addAction(UIAction { [weak self] _ in self?.selected = product; self?.render() }, for: .touchUpInside)
                list.addArrangedSubview(row)
            }
        }
    }

    private func packageRow(amount: Int, price: String, selected: Bool) -> UIButton {
        let row = UIButton(type: .custom)
        row.backgroundColor = selected ? Palette.lime : .white
        row.layer.cornerRadius = 17
        row.layer.cornerCurve = .continuous
        row.snp.makeConstraints { $0.height.equalTo(62) }
        let coinBackground = UIView()
        coinBackground.backgroundColor = selected ? .black : Palette.lime
        coinBackground.layer.cornerRadius = 14
        coinBackground.layer.cornerCurve = .continuous
        coinBackground.isUserInteractionEnabled = false
        row.addSubview(coinBackground)
        coinBackground.snp.makeConstraints { $0.leading.equalToSuperview().offset(14); $0.centerY.equalToSuperview(); $0.width.height.equalTo(28) }
        let coin = UIImageView(image: UIImage(named: "coin"))
        coin.contentMode = .scaleAspectFit
        coin.isUserInteractionEnabled = false
        coinBackground.addSubview(coin)
        coin.snp.makeConstraints { $0.edges.equalToSuperview().inset(3) }
        let amountLabel = label("\(NumberFormatter.localizedString(from: NSNumber(value: amount), number: .decimal)) coins", size: 15, weight: .black)
        let priceLabel = label(price, size: 11, weight: .semibold, color: UIColor(hex: 0x899186))
        let text = UIStackView(arrangedSubviews: [amountLabel, priceLabel])
        text.axis = .vertical
        text.spacing = -1
        text.isUserInteractionEnabled = false
        row.addSubview(text)
        text.snp.makeConstraints { $0.leading.equalTo(coinBackground.snp.trailing).offset(12); $0.centerY.equalToSuperview() }
        let arrow = label("›", size: 19, weight: .black)
        arrow.isUserInteractionEnabled = false
        row.addSubview(arrow)
        arrow.snp.makeConstraints { $0.trailing.equalToSuperview().inset(21); $0.centerY.equalToSuperview() }
        return row
    }

    @objc private func continuePurchase() { if visualPackages { return }; guard let selected else { showMessage("Choose a coin pack", message: "Select a pack before continuing."); return }; InAppPurchaseManager.shared.purchase(selected) }
    @objc private func stateChanged() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.stateChanged() }
            return
        }
        switch InAppPurchaseManager.shared.state {
        case .loading, .purchasing:
            loadingCover.isHidden = false; loading.startAnimating(); continueButton.isEnabled = false
        case .completed:
            loading.stopAnimating(); loadingCover.isHidden = true; continueButton.isEnabled = true; render(); showMessage("Purchase complete", message: "Your coin balance has been updated.")
        case .cancelled:
            loading.stopAnimating(); loadingCover.isHidden = true; continueButton.isEnabled = true
        case .failed:
            loading.stopAnimating(); loadingCover.isHidden = true; continueButton.isEnabled = true; showMessage("Purchase unsuccessful", message: "Please try again.")
        case .idle:
            loading.stopAnimating(); loadingCover.isHidden = true; continueButton.isEnabled = true; render()
        }
    }
}

private extension BaseScrollableViewController {
    func accountHeader(_ title: String, backAction: Selector = #selector(accountBack)) -> UIView { let row = UIStackView(); row.alignment = .center; row.spacing = 6; let back = UIButton(type: .system); back.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal); back.tintColor = Palette.ink; back.addTarget(self, action: backAction, for: .touchUpInside); back.snp.makeConstraints { $0.width.equalTo(28); $0.height.equalTo(38) }; row.addArrangedSubview(back); let heading = titleLabel(title, size: 29); heading.font = AppFont.nunito(29, weight: .black, italic: true); row.addArrangedSubview(heading); row.addArrangedSubview(UIView()); return row }
    func accountUserRow(userID: String, actionTitle: String, highlighted: Bool = false) -> UIButton { let row = UIButton(type: .system); row.snp.makeConstraints { $0.height.equalTo(74) }; let avatar = UIImageView(image: UserAvatarStore.displayImage(for: repository.user(id: userID), fallbackAsset: "")); avatar.tintColor = Palette.muted; avatar.contentMode = .scaleAspectFill; avatar.clipsToBounds = true; avatar.layer.cornerRadius = 27; avatar.isUserInteractionEnabled = false; row.addSubview(avatar); avatar.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.width.height.equalTo(54) }; let name = label(repository.user(id: userID)?.name ?? "Explorer", size: 18, weight: .heavy); name.isUserInteractionEnabled = false; row.addSubview(name); name.snp.makeConstraints { $0.leading.equalTo(avatar.snp.trailing).offset(16); $0.centerY.equalToSuperview() }; let action = UILabel(); action.text = actionTitle; action.textAlignment = .center; action.font = AppFont.nunito(13, weight: .semibold); action.backgroundColor = highlighted ? Palette.lime : .white; action.layer.cornerRadius = 18; action.clipsToBounds = true; action.isUserInteractionEnabled = false; row.addSubview(action); action.snp.makeConstraints { $0.trailing.equalToSuperview(); $0.centerY.equalToSuperview(); $0.width.equalTo(84); $0.height.equalTo(36) }; return row }
    @objc func accountBack() { navigationController?.popViewController(animated: true) }
}
