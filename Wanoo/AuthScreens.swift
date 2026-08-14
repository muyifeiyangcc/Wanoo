import UIKit
import SnapKit
import WebKit

final class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xFFFCF4)
        let art = UIImageView(image: UIImage(named: "Figma-309-3255-21-fd21-f21-a1-55f96b81")); art.contentMode = .scaleAspectFill; art.clipsToBounds = true
        let logo = UIImageView(image: UIImage(named: "Figma-309-3255-2111-6b65ddad")); logo.contentMode = .scaleAspectFit
        view.addSubview(art); art.snp.makeConstraints { $0.edges.equalToSuperview() }
        view.addSubview(logo); logo.snp.makeConstraints { $0.top.equalTo(view.safeAreaLayoutGuide).offset(38); $0.leading.trailing.equalToSuperview().inset(52); $0.height.equalTo(88) }
    }
}

final class WelcomeViewController: BaseScrollableViewController, UITextViewDelegate {
    private let checkbox = UIButton(type: .system)
    private let agreementTextView = UITextView()
    private var agreed = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        backgroundView.isHidden = true
        stack.isHidden = true
        scrollView.isHidden = true
        view.backgroundColor = UIColor(hex: 0xFFFCF4)
        let art = UIImageView(image: UIImage(named: "Figma-309-3265-180771-c9-ddde424-fbc414-a85028215511-c28a2067")); art.contentMode = .scaleAspectFill; art.clipsToBounds = true
        view.addSubview(art); art.snp.makeConstraints { $0.edges.equalToSuperview() }
        let logo = UIImageView(image: UIImage(named: "Figma-309-3255-2111-6b65ddad")); logo.contentMode = .scaleAspectFit
        view.addSubview(logo); logo.snp.makeConstraints { $0.top.equalTo(view.safeAreaLayoutGuide).offset(4); $0.leading.trailing.equalToSuperview().inset(38); $0.height.equalTo(112) }
        let signInButton = authButton("I’m new", iconAsset: "Figma-309-3265-1-ea83809d", outlined: false, selector: #selector(guest))
        let emailButton = authButton("Sign In By Email", iconAsset: "Figma-309-3265-22-045ffe95", outlined: true, selector: #selector(signIn))
        view.addSubview(signInButton)
        view.addSubview(emailButton)
        signInButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.equalToSuperview().inset(37)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-238)
            $0.height.equalTo(62)
        }
        emailButton.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(signInButton)
            $0.top.equalTo(signInButton.snp.bottom).offset(23)
        }

        let guestButton = UIButton(type: .system)
        let guestCopy = NSMutableAttributedString(
            string: "Don't have an account? ",
            attributes: [.font: AppFont.inter(12, weight: .semibold), .foregroundColor: UIColor(hex: 0x1D230D)]
        )
        guestCopy.append(NSAttributedString(
            string: "Sign up",
            attributes: [.font: AppFont.inter(12, weight: .semibold), .foregroundColor: Palette.purple, .underlineStyle: NSUnderlineStyle.single.rawValue]
        ))
        guestButton.setAttributedTitle(guestCopy, for: .normal)
        guestButton.addTarget(self, action: #selector(openRegistration), for: .touchUpInside)
        view.addSubview(guestButton)
        guestButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(emailButton.snp.bottom).offset(25)
            $0.height.equalTo(22)
        }

        checkbox.setImage(UIImage(named: "Figma-309-3265-ellipse2-5b51463f"), for: .normal)
        checkbox.tintColor = Palette.purple
        checkbox.imageView?.contentMode = .scaleAspectFit
        checkbox.contentVerticalAlignment = .top
        checkbox.addTarget(self, action: #selector(toggleAgreement), for: .touchUpInside)
        view.addSubview(checkbox)
        checkbox.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(68)
            $0.top.equalTo(guestButton.snp.bottom).offset(17)
            $0.width.equalTo(12)
            $0.height.equalTo(30)
        }

        let agreementCopy = NSMutableAttributedString(
            string: "By continuing you agree to our ",
            attributes: [.font: AppFont.inter(10, weight: .semibold), .foregroundColor: UIColor.black]
        )
        agreementCopy.append(NSAttributedString(string: "Terms of Service", attributes: [.font: AppFont.inter(10, weight: .semibold), .foregroundColor: Palette.purple, .underlineStyle: NSUnderlineStyle.single.rawValue, .link: URL(string: "https://sites.google.com/view/wanoo/users")!]))
        agreementCopy.append(NSAttributedString(string: " and\n", attributes: [.font: AppFont.inter(10, weight: .semibold), .foregroundColor: UIColor.black]))
        agreementCopy.append(NSAttributedString(string: "Privacy Policy", attributes: [.font: AppFont.inter(10, weight: .semibold), .foregroundColor: Palette.purple, .underlineStyle: NSUnderlineStyle.single.rawValue, .link: URL(string: "https://sites.google.com/view/wanoo/privacy")!]))
        agreementTextView.attributedText = agreementCopy
        agreementTextView.delegate = self
        agreementTextView.isEditable = false
        agreementTextView.isScrollEnabled = false
        agreementTextView.backgroundColor = .clear
        agreementTextView.textAlignment = .center
        agreementTextView.textContainerInset = .zero
        agreementTextView.textContainer.lineFragmentPadding = 0
        agreementTextView.linkTextAttributes = [.foregroundColor: Palette.purple, .underlineStyle: NSUnderlineStyle.single.rawValue]
        view.addSubview(agreementTextView)
        agreementTextView.snp.makeConstraints {
            $0.leading.equalTo(checkbox.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(38)
            $0.top.height.equalTo(checkbox)
        }
    }

    private func authButton(_ title: String, iconAsset: String, outlined: Bool, selector: Selector) -> UIButton {
        let value = UIButton(type: .system)
        value.setTitle(title, for: .normal); value.setTitleColor(outlined ? Palette.purple : .white, for: .normal)
        value.titleLabel?.font = AppFont.nunito(16, weight: .heavy); value.backgroundColor = outlined ? .white : Palette.purple
        value.layer.cornerRadius = 18; value.layer.borderWidth = outlined ? 2 : 0; value.layer.borderColor = Palette.purple.cgColor
        let icon = UIImageView(image: UIImage(named: iconAsset)); icon.contentMode = .scaleAspectFit; value.addSubview(icon)
        icon.snp.makeConstraints { $0.leading.equalToSuperview().offset(outlined ? 18 : 16); $0.centerY.equalToSuperview(); $0.width.height.equalTo(outlined ? 16 : 18) }
        let chevron = UILabel(); chevron.text = "›"; chevron.textColor = outlined ? Palette.purple : .white; chevron.font = AppFont.nunito(18, weight: .bold); value.addSubview(chevron)
        chevron.snp.makeConstraints { $0.trailing.equalToSuperview().inset(22); $0.centerY.equalToSuperview().offset(-1) }
        value.addTarget(self, action: selector, for: .touchUpInside)
        return value
    }

    @objc private func toggleAgreement() {
        agreed.toggle()
        let selected = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold))
        checkbox.setImage(agreed ? selected : UIImage(named: "Figma-309-3265-ellipse2-5b51463f"), for: .normal)
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let selectedText = (textView.attributedText.string as NSString).substring(with: characterRange)
        navigationController?.pushViewController(AgreementViewController(pageTitle: selectedText.contains("Terms") ? "Terms of Service" : "Privacy Policy"), animated: true)
        return false
    }
    @objc private func signIn() {
        guard agreed else { showAgreementRequiredMessage(); return }
        navigationController?.pushViewController(EmailAuthViewController(mode: .signIn), animated: true)
    }
    @objc private func openEmailAfterAgreement() { if agreed { navigationController?.pushViewController(EmailAuthViewController(mode: .signIn), animated: true) } else { showAgreementRequiredMessage() } }
    @objc private func openRegistration() {
        guard agreed else {
            showAgreementRequiredMessage()
            return
        }
        navigationController?.pushViewController(EmailAuthViewController(mode: .register), animated: true)
    }
    private func showAgreementRequiredMessage() {
        showMessage(
            "Review and Accept the Agreements",
            message: "To continue with sign in or account creation, select the checkbox confirming that you have read and agree to the Terms of Service and Privacy Policy.",
            actionTitle: "Got It"
        )
    }
    @objc private func guest() { repository.enterAsGuest(); AppRouter.installRoot(AppRouter.mainController(), from: self) }
    @objc private func openAgreement() { navigationController?.pushViewController(AgreementViewController(pageTitle: "Privacy Policy"), animated: true) }
}

final class EmailAuthViewController: BaseScrollableViewController {
    enum Mode { case signIn, register, reset }
    private let mode: Mode
    private let email = UITextField()
    private let password = UITextField()
    private let confirmation = UITextField()
    private let name = UITextField()

    init(mode: Mode) { self.mode = mode; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        scrollView.isHidden = true
        let heading: String = mode == .signIn ? "Sign in" : (mode == .register ? "Sign up" : "Forgot Password")
        let back = UIButton(type: .system); back.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)), for: .normal); back.tintColor = Palette.ink; back.addTarget(self, action: #selector(close), for: .touchUpInside)
        let headingLabel = label(heading, size: 30, weight: .black); headingLabel.font = AppFont.nunito(30, weight: .black, italic: true)
        view.addSubview(back); view.addSubview(headingLabel)
        back.snp.makeConstraints { $0.leading.equalToSuperview().offset(20); $0.top.equalTo(view.safeAreaLayoutGuide).offset(10); $0.width.height.equalTo(24) }
        headingLabel.snp.makeConstraints { $0.leading.equalToSuperview().offset(60); $0.centerY.equalTo(back) }
        let emailCaption = label("Email", size: 12, weight: .semibold); view.addSubview(emailCaption)
        emailCaption.snp.makeConstraints { $0.leading.equalToSuperview().offset(22); $0.top.equalTo(back.snp.bottom).offset(30) }
        configure(email, placeholder: "Email", secure: false)
        configure(password, placeholder: mode == .register ? "Enter Password" : (mode == .signIn ? "Password" : "New password"), secure: true)
        email.placeholder = "Enter Email Address"
        let passwordCaption = label("Password", size: 12, weight: .semibold)
        view.addSubview(email); view.addSubview(passwordCaption); view.addSubview(password)
        email.snp.makeConstraints { $0.top.equalTo(emailCaption.snp.bottom).offset(8); $0.leading.trailing.equalToSuperview().inset(22) }
        passwordCaption.snp.makeConstraints { $0.leading.equalTo(email); $0.top.equalTo(email.snp.bottom).offset(20) }
        password.snp.makeConstraints { $0.top.equalTo(passwordCaption.snp.bottom).offset(8); $0.leading.trailing.equalTo(email) }
        if mode != .signIn {
            configure(confirmation, placeholder: "Please Enter The Password Again", secure: true)
            let confirmationCaption = label("Password", size: 12, weight: .semibold)
            view.addSubview(confirmationCaption); view.addSubview(confirmation)
            confirmationCaption.snp.makeConstraints { $0.leading.equalTo(email); $0.top.equalTo(password.snp.bottom).offset(20) }
            confirmation.snp.makeConstraints { $0.top.equalTo(confirmationCaption.snp.bottom).offset(8); $0.leading.trailing.equalTo(email) }
        }
        if mode == .register { configure(name, placeholder: "Name", secure: false); name.isHidden = true }
        if mode == .signIn {
            let forgotButton = UIButton(type: .system); forgotButton.setTitle("Forgot Password?", for: .normal); forgotButton.setTitleColor(Palette.purple, for: .normal); forgotButton.titleLabel?.font = AppFont.inter(10, weight: .medium); forgotButton.addTarget(self, action: #selector(forgot), for: .touchUpInside); view.addSubview(forgotButton)
            forgotButton.snp.makeConstraints { $0.top.equalTo(password.snp.bottom).offset(24); $0.centerX.equalToSuperview() }
        }
        let submitButton = button(mode == .signIn ? "Sign in" : (mode == .register ? "Sign up" : "Save"), action: #selector(submit))
        submitButton.backgroundColor = Palette.purple; submitButton.setTitleColor(.white, for: .normal); submitButton.layer.cornerRadius = 16
        view.addSubview(submitButton); submitButton.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(18); $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(2); $0.height.equalTo(54) }
    }

    private func configure(_ value: UITextField, placeholder: String, secure: Bool) {
        value.placeholder = placeholder; value.isSecureTextEntry = secure; value.backgroundColor = .white; value.layer.cornerRadius = 10; value.font = AppFont.nunito(12)
        let inset = UIView(); inset.snp.makeConstraints { $0.width.equalTo(16) }; value.leftView = inset; value.leftViewMode = .always
        value.snp.makeConstraints { $0.height.equalTo(44) }
    }

    @objc private func close() { navigationController?.popViewController(animated: true) }

    @objc private func forgot() { navigationController?.pushViewController(EmailAuthViewController(mode: .reset), animated: true) }
    @objc private func create() { navigationController?.pushViewController(EmailAuthViewController(mode: .register), animated: true) }
    @objc private func submit() {
        let mail = email.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pass = password.text ?? ""
        guard mail.contains("@"), pass.count >= 8 else { showMessage("Check your details", message: "Enter a valid email and a password with at least 8 characters."); return }
        if mode != .signIn && pass != confirmation.text { showMessage("Passwords do not match", message: "Enter the same password twice."); return }
        switch mode {
        case .signIn:
            guard repository.signIn(email: mail, password: pass) else { showMessage("Unable to sign in", message: "Check your email and password, then try again."); return }
            AppRouter.installRoot(AppRouter.mainController(), from: self)
        case .register:
            guard repository.register(email: mail, password: pass, name: "Explorer") else { showMessage("Account unavailable", message: "Use a different email."); return }
            navigationController?.pushViewController(ProfileSetupViewController(), animated: true)
        case .reset:
            guard repository.resetPassword(email: mail, password: pass) else { showMessage("Account not found", message: "No active account matches that email."); return }
            showMessage("Password updated", message: "You can now sign in with your new password.", action: { self.navigationController?.popToRootViewController(animated: true) })
        }
    }
}

final class ProfileSetupViewController: BaseScrollableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let nameField = UITextField(); private let birthdayField = UITextField(); private let genderField = UITextField(); private let avatarButton = UIButton(type: .system); private var selectedAvatar: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false)
        scrollView.isHidden = true
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal)
        backButton.tintColor = Palette.ink
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.contentHorizontalAlignment = .leading
        backButton.snp.makeConstraints { $0.top.equalTo(view.safeAreaLayoutGuide).offset(8); $0.leading.equalToSuperview().offset(18); $0.width.height.equalTo(36) }

        avatarButton.setImage(UserAvatarStore.defaultAvatar(), for: .normal)
        avatarButton.tintColor = Palette.muted
        avatarButton.backgroundColor = .white
        avatarButton.imageView?.contentMode = .scaleAspectFit
        avatarButton.layer.cornerRadius = 56
        avatarButton.clipsToBounds = true
        avatarButton.addTarget(self, action: #selector(photo), for: .touchUpInside)
        view.addSubview(avatarButton)
        avatarButton.snp.makeConstraints { $0.top.equalTo(view.safeAreaLayoutGuide).offset(40); $0.centerX.equalToSuperview(); $0.width.height.equalTo(112) }
        let camera = UIImageView(image: UIImage(named: "Figma-289-4969-21-2d73f1d3")); camera.contentMode = .scaleAspectFit; camera.isUserInteractionEnabled = false
        view.addSubview(camera); camera.snp.makeConstraints { $0.centerX.equalTo(avatarButton); $0.top.equalTo(avatarButton).offset(87); $0.width.height.equalTo(20) }
        let heading = titleLabel("Improve your profile", size: 28); heading.textAlignment = .center
        view.addSubview(heading); heading.snp.makeConstraints { $0.top.equalTo(avatarButton.snp.bottom).offset(17); $0.centerX.equalToSuperview() }
        let fields: [(String, UITextField, String)] = [("Name", nameField, "Explorer"), ("Birthday", birthdayField, "2003-01-01"), ("Gender", genderField, "Madam")]
        var previousField: UITextField?
        fields.forEach { caption, item, placeholder in
            let captionLabel = label(caption, size: 13, weight: .bold)
            view.addSubview(captionLabel)
            captionLabel.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(15)
                if let previousField { $0.top.equalTo(previousField.snp.bottom).offset(17) }
                else { $0.top.equalTo(heading.snp.bottom).offset(24) }
            }
            item.placeholder = placeholder; item.backgroundColor = .white; item.layer.cornerRadius = 14; item.font = AppFont.nunito(13)
            let inset = UIView(); inset.snp.makeConstraints { $0.width.equalTo(16) }; item.leftView = inset; item.leftViewMode = .always
            view.addSubview(item)
            item.snp.makeConstraints {
                $0.top.equalTo(captionLabel.snp.bottom).offset(7)
                $0.leading.equalToSuperview().offset(15)
                $0.trailing.equalToSuperview().inset(21)
                $0.height.equalTo(44)
            }
            previousField = item
        }
        birthdayField.addTarget(self, action: #selector(openBirthdaySheet), for: .editingDidBegin)
        genderField.addTarget(self, action: #selector(openGenderSheet), for: .editingDidBegin)
        let existingName = repository.currentUser?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        nameField.text = existingName.isEmpty ? "Explorer" : existingName
        let save = button("Save", action: #selector(save)); save.backgroundColor = Palette.purple; save.setTitleColor(.white, for: .normal); save.titleLabel?.font = AppFont.nunito(20, weight: .heavy); save.layer.cornerRadius = 18
        view.addSubview(save); save.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(18); $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(2); $0.height.equalTo(54) }
    }
    @objc private func back() { navigationController?.popViewController(animated: true) }
    @objc private func photo() { chooseMedia(delegate: self) }
    @objc private func openBirthdaySheet() {
        birthdayField.resignFirstResponder()
        let picker = BirthdayPickerSheetController(currentValue: birthdayField.text ?? birthdayField.placeholder) { [weak self] value in
            self?.birthdayField.text = value
        }
        present(picker, animated: true)
    }
    @objc private func openGenderSheet() {
        genderField.resignFirstResponder()
        let sheet = UIAlertController(title: "Select Gender", message: nil, preferredStyle: .actionSheet)
        ["Madam", "Sir", "Non-binary", "Prefer not to say"].forEach { value in
            sheet.addAction(UIAlertAction(title: value, style: .default) { [weak self] _ in self?.genderField.text = value })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    @objc private func save() {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { showMessage("Name required", message: "Enter a name to continue."); return }
        repository.updateProfile(name: name, bio: repository.currentUser?.bio ?? "", location: "", birthday: birthdayField.text ?? birthdayField.placeholder ?? "", gender: genderField.text ?? genderField.placeholder ?? "")
        if let selectedAvatar { UserAvatarStore.save(selectedAvatar, userID: repository.currentUserID) }
        AppRouter.installRoot(AppRouter.mainController(), from: self)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage { selectedAvatar = image; avatarButton.setImage(nil, for: .normal); avatarButton.setBackgroundImage(image, for: .normal); avatarButton.imageView?.contentMode = .scaleAspectFill }; picker.dismiss(animated: true) }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }
}

private final class BirthdayPickerSheetController: UIViewController {
    private let picker = UIDatePicker()
    private let onSelection: (String) -> Void

    init(currentValue: String?, onSelection: @escaping (String) -> Void) {
        self.onSelection = onSelection
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.preferredCornerRadius = 24
        }
        if let currentValue, let date = Self.formatter.date(from: currentValue) { picker.date = date }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "Select Birthday"
        titleLabel.font = AppFont.nunito(20, weight: .heavy)
        titleLabel.textColor = Palette.ink

        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.maximumDate = Date()

        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(Palette.purple, for: .normal)
        cancel.titleLabel?.font = AppFont.nunito(16, weight: .bold)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.backgroundColor = Palette.purple
        done.layer.cornerRadius = 16
        done.titleLabel?.font = AppFont.nunito(16, weight: .heavy)
        done.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        view.addSubview(titleLabel); view.addSubview(picker); view.addSubview(cancel); view.addSubview(done)
        titleLabel.snp.makeConstraints { $0.top.equalToSuperview().offset(24); $0.centerX.equalToSuperview() }
        picker.snp.makeConstraints { $0.top.equalTo(titleLabel.snp.bottom).offset(8); $0.leading.trailing.equalToSuperview().inset(12) }
        cancel.snp.makeConstraints { $0.leading.equalToSuperview().offset(20); $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8); $0.width.equalTo(92); $0.height.equalTo(50) }
        done.snp.makeConstraints { $0.trailing.equalToSuperview().inset(20); $0.bottom.height.equalTo(cancel); $0.width.equalTo(150) }
    }

    @objc private func cancelTapped() { dismiss(animated: true) }
    @objc private func doneTapped() {
        onSelection(Self.formatter.string(from: picker.date))
        dismiss(animated: true)
    }

    private static let formatter: DateFormatter = {
        let value = DateFormatter()
        value.calendar = Calendar(identifier: .gregorian)
        value.locale = Locale(identifier: "en_US_POSIX")
        value.dateFormat = "yyyy-MM-dd"
        return value
    }()
}

final class AgreementViewController: UIViewController, WKNavigationDelegate {
    private let pageTitle: String
    init(pageTitle: String = "Privacy Policy") { self.pageTitle = pageTitle; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { self.pageTitle = "Privacy Policy"; super.init(coder: coder) }

    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); navigationController?.setNavigationBarHidden(true, animated: false) }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.base
        let header = UIView(); view.addSubview(header); header.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(18); $0.top.equalTo(view.safeAreaLayoutGuide); $0.height.equalTo(54) }
        let backButton = UIButton(type: .system); backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal); backButton.tintColor = Palette.ink; backButton.addTarget(self, action: #selector(back), for: .touchUpInside); header.addSubview(backButton); backButton.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.width.height.equalTo(34) }
        let heading = UILabel(); heading.text = pageTitle; heading.font = AppFont.nunito(20, weight: .black); heading.textColor = Palette.ink; header.addSubview(heading); heading.snp.makeConstraints { $0.center.equalToSuperview() }
        let address = pageTitle == "Terms of Service"
            ? "https://sites.google.com/view/wanoo/users"
            : "https://sites.google.com/view/wanoo/privacy"
        guard let url = URL(string: address) else { return }
        let browser = WKWebView(); browser.navigationDelegate = self; browser.backgroundColor = Palette.base; browser.scrollView.backgroundColor = Palette.base; view.addSubview(browser); browser.snp.makeConstraints { $0.top.equalTo(header.snp.bottom); $0.leading.trailing.bottom.equalToSuperview() }; browser.load(URLRequest(url: url))
    }
    @objc private func back() { navigationController?.popViewController(animated: true) }
}
