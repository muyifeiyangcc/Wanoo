import UIKit
import SnapKit

private final class RoomCardShadeView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let gradient = layer as? CAGradientLayer else { return }
        gradient.colors = [UIColor.black.withAlphaComponent(0.38).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.44).cgColor]
        gradient.locations = [0, 0.48, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

private final class WanooTabBarBackgroundView: UIView {
    private let shape = CAShapeLayer()
    override init(frame: CGRect) { super.init(frame: frame); layer.addSublayer(shape); shape.fillColor = UIColor.white.cgColor }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        shape.frame = bounds
        let top: CGFloat = 34
        let radius: CGFloat = 20
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.maxY))
        path.addLine(to: CGPoint(x: 0, y: top + radius))
        path.addQuadCurve(to: CGPoint(x: radius, y: top), controlPoint: CGPoint(x: 0, y: top))
        path.addLine(to: CGPoint(x: bounds.maxX - radius, y: top))
        path.addQuadCurve(to: CGPoint(x: bounds.maxX, y: top + radius), controlPoint: CGPoint(x: bounds.maxX, y: top))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.close()
        shape.path = path.cgPath
    }
}

/// Pages in this list already draw their own leading back/close control inside
/// the Figma layout, so the tab coordinator must not add a second system bar.
private protocol UsesEmbeddedBackNavigation {}
extension PostDetailViewController: UsesEmbeddedBackNavigation {}
extension AIAssistantViewController: UsesEmbeddedBackNavigation {}
extension ChatViewController: UsesEmbeddedBackNavigation {}
extension TopicViewController: UsesEmbeddedBackNavigation {}
extension OtherProfileViewController: UsesEmbeddedBackNavigation {}
extension PublishViewController: UsesEmbeddedBackNavigation {}
extension PassportViewController: UsesEmbeddedBackNavigation {}
extension SearchViewController: UsesEmbeddedBackNavigation {}
extension ReportViewController: UsesEmbeddedBackNavigation {}
extension BlockListViewController: UsesEmbeddedBackNavigation {}
extension AccountFollowListViewController: UsesEmbeddedBackNavigation {}
extension EditProfileViewController: UsesEmbeddedBackNavigation {}
extension SettingsViewController: UsesEmbeddedBackNavigation {}
extension RechargeViewController: UsesEmbeddedBackNavigation {}
extension AgreementViewController: UsesEmbeddedBackNavigation {}

final class MainTabBarController: UITabBarController, UITabBarControllerDelegate, UINavigationControllerDelegate {
    private let customBar = UIView()
    private var tabButtons: [UIButton] = []
    private let messagesSegment: Int
    init(messagesSegment: Int = 0) { self.messagesSegment = messagesSegment; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { self.messagesSegment = 0; super.init(coder: coder) }
    override func viewDidLoad() {
        super.viewDidLoad(); delegate = self
        hideSystemTabBar()
        let home = nav(HomeViewController(), title: "Home", icon: "house")
        let discover = nav(DiscoverViewController(), title: "Discover", icon: "safari")
        let publish = nav(UIViewController(), title: "Create", icon: "plus.circle.fill")
        let messages = nav(MessagesViewController(selectedIndex: messagesSegment), title: "Chats", icon: "message")
        let profile = nav(ProfileViewController(), title: "Me", icon: "person.crop.circle")
        publish.tabBarItem.selectedImage = UIImage(systemName: "plus.circle.fill")
        viewControllers = [home, discover, publish, messages, profile]
        buildCustomBar()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideSystemTabBar()
    }
    private func hideSystemTabBar() {
        tabBar.isHidden = true
        tabBar.alpha = 0
        tabBar.isUserInteractionEnabled = false
    }
    private func nav(_ root: UIViewController, title: String, icon: String) -> UINavigationController {
        if let rootPage = root as? BaseScrollableViewController {
            rootPage.loadViewIfNeeded()
            // The custom tab bar floats above child content instead of taking
            // part in UIKit's safe-area calculation. Reserve enough scrollable
            // space for both the white bar and the raised center action button.
            rootPage.scrollView.contentInset.bottom = 118
            rootPage.scrollView.verticalScrollIndicatorInsets.bottom = 118
        }
        let value = UINavigationController(rootViewController: root); value.navigationBar.tintColor = Palette.purple
        value.navigationBar.titleTextAttributes = [.font: AppFont.nunito(17, weight: .heavy), .foregroundColor: Palette.ink]
        value.delegate = self
        let appearance = UINavigationBarAppearance(); appearance.configureWithTransparentBackground(); appearance.backgroundColor = Palette.top.withAlphaComponent(0.96); appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.font: AppFont.nunito(17, weight: .heavy), .foregroundColor: Palette.ink]
        value.navigationBar.standardAppearance = appearance; value.navigationBar.scrollEdgeAppearance = appearance; value.navigationBar.compactAppearance = appearance
        value.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: UIImage(systemName: icon + ".fill")); return value
    }
    private func buildCustomBar() {
        customBar.backgroundColor = .clear
        view.addSubview(customBar); customBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            // Keep the complete custom bar visible on devices whose bottom
            // safe-area inset is zero as well as on home-indicator devices.
            $0.height.equalTo(108)
        }
        let background = WanooTabBarBackgroundView(); customBar.addSubview(background); background.snp.makeConstraints { $0.edges.equalToSuperview() }
        let icons = ["Figma-256-1234-352-944a57bb", "Figma-256-1234-11-45e21d42", "", "Figma-256-1234-12-33122888", "Figma-256-1234-13-83dad0f3"]
        for index in 0..<5 {
            let button = UIButton(type: .system); button.tag = index; button.addTarget(self, action: #selector(selectCustomTab(_:)), for: .touchUpInside)
            customBar.addSubview(button)
            if index == 2 {
                button.backgroundColor = Palette.purple; button.layer.cornerRadius = 34; button.layer.shadowColor = UIColor.clear.cgColor; button.layer.shadowOpacity = 0; button.layer.shadowRadius = 0; button.layer.shadowOffset = .zero; button.layer.shadowPath = nil; button.layer.masksToBounds = true
                let plus = UIImageView(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium))); plus.tintColor = .white; plus.contentMode = .scaleAspectFit; button.addSubview(plus); plus.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(32) }
                button.snp.makeConstraints { $0.top.equalToSuperview(); $0.centerX.equalToSuperview(); $0.width.height.equalTo(68) }
            } else {
                let icon = UIImageView(image: UIImage(named: icons[index])?.withRenderingMode(.alwaysTemplate)); icon.tag = 901; icon.contentMode = .scaleAspectFit; icon.tintColor = Palette.ink; button.addSubview(icon); icon.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(index == 0 ? 28 : 30) }
                button.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(46); $0.width.height.equalTo(40)
                    switch index {
                    case 0: $0.leading.equalToSuperview().offset(16)
                    case 1: $0.leading.equalToSuperview().offset(81)
                    case 3: $0.trailing.equalToSuperview().inset(88)
                    default: $0.trailing.equalToSuperview().inset(20)
                    }
                }
            }
            tabButtons.append(button)
        }
        refreshCustomTab()
    }
    @objc private func selectCustomTab(_ sender: UIButton) {
        guard sender.tag != 2 else { _ = tabBarController(self, shouldSelect: viewControllers![2]); return }
        guard let target = viewControllers?[sender.tag], tabBarController(self, shouldSelect: target) else { return }
        selectedIndex = sender.tag; refreshCustomTab()
    }
    func selectVisualTab(_ index: Int) { selectedIndex = index; refreshCustomTab() }
    private func refreshCustomTab() {
        for button in tabButtons where button.tag != 2 {
            (button.viewWithTag(901) as? UIImageView)?.tintColor = Palette.ink
            button.backgroundColor = button.tag == selectedIndex ? Palette.lime : .clear
            button.layer.cornerRadius = 20
            button.layer.cornerCurve = .continuous
        }
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return true }
        if index == 2 {
            guard AppRepository.shared.session == .authenticated else { presentLoginRequired(); return false }
            (selectedViewController as? UINavigationController)?.pushViewController(PublishViewController(), animated: true); return false
        }
        if AppRepository.shared.session == .guest && (index == 3 || index == 4) { presentLoginRequired(); return false }
        return true
    }
    private func presentLoginRequired() {
        present(WanooAlertController(titleText: "Sign In Required", messageText: "Sign in to use this section.", secondaryTitle: "Cancel", primaryTitle: "Sign In", primaryAction: { AppRouter.showLogin(from: self) }), animated: true)
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isTabRoot = navigationController.viewControllers.first === viewController
        let alreadyHasEmbeddedBack = viewController is UsesEmbeddedBackNavigation
        hideSystemTabBar()
        customBar.isHidden = !isTabRoot
        // The app uses its own overlay tab bar. UIKit's native tab bar must never
        // participate in push transitions or it can be restored on a detail page.
        viewController.hidesBottomBarWhenPushed = false
        navigationController.setNavigationBarHidden(isTabRoot || alreadyHasEmbeddedBack, animated: false)

        guard !isTabRoot, !alreadyHasEmbeddedBack else { return }
        if viewController.navigationItem.leftBarButtonItem == nil {
            viewController.navigationItem.hidesBackButton = true
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)),
                style: .plain,
                target: self,
                action: #selector(returnToPreviousPage)
            )
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        hideSystemTabBar()
        customBar.isHidden = navigationController.viewControllers.first !== viewController
    }

    @objc private func returnToPreviousPage() {
        (selectedViewController as? UINavigationController)?.popViewController(animated: true)
    }
}

final class HomeViewController: BaseScrollableViewController {
    private var selectedCategory = "All"
    private let feed = UIStackView()
    private let roomStack = UIStackView()
    override func viewDidLoad() { super.viewDidLoad(); buildGeometry(); render() }
    private func buildGeometry() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        stack.spacing = 14
        let top = UIStackView(); top.alignment = .center; top.distribution = .equalSpacing; top.snp.makeConstraints { $0.height.equalTo(70) }
        let identity = UIStackView(); identity.axis = .vertical; identity.spacing = 2; let brand = titleLabel("Wanoo", size: 38); brand.font = AppFont.nunito(38, weight: .black, italic: true); identity.addArrangedSubview(brand); identity.addArrangedSubview(label("Tiny escapes. Real stories.", size: 12)); top.addArrangedSubview(identity)
        let aiWrap = UIView(); aiWrap.snp.makeConstraints { $0.width.equalTo(168); $0.height.equalTo(70) }; aiWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openAI))); aiWrap.isUserInteractionEnabled = true
        let ai = UIImageView(image: UIImage(named: "FigmaAI")); ai.contentMode = .scaleAspectFit; aiWrap.addSubview(ai); ai.snp.makeConstraints { $0.trailing.equalToSuperview(); $0.top.equalToSuperview().offset(-7); $0.width.equalTo(94); $0.height.equalTo(78) }
        let bubbleBackground = UIImageView(image: UIImage(named: "home_chat_bg")); bubbleBackground.contentMode = .scaleAspectFit; aiWrap.addSubview(bubbleBackground); bubbleBackground.snp.makeConstraints { $0.leading.equalToSuperview(); $0.top.equalToSuperview().offset(-10); $0.width.equalTo(105); $0.height.equalTo(59) }
        let bubble = UILabel(); bubble.text = "Hi, I am your\ndedicated AI assistant"; bubble.numberOfLines = 2; bubble.textAlignment = .center; bubble.font = AppFont.inter(7, weight: .bold); bubble.textColor = Palette.ink; aiWrap.addSubview(bubble); bubble.snp.makeConstraints { $0.leading.equalToSuperview().offset(7); $0.top.equalToSuperview().offset(-3); $0.width.equalTo(88); $0.height.equalTo(26) }
        let entry = UILabel(); entry.text = "Click to enter"; entry.textAlignment = .center; entry.font = AppFont.inter(5, weight: .bold); entry.textColor = .white; entry.backgroundColor = Palette.purple; entry.layer.cornerRadius = 5; entry.clipsToBounds = true; aiWrap.addSubview(entry); entry.snp.makeConstraints { $0.centerX.equalTo(bubble); $0.top.equalTo(bubble.snp.bottom).offset(1); $0.width.equalTo(48); $0.height.equalTo(10) }
        top.addArrangedSubview(aiWrap); stack.addArrangedSubview(top)
        let chipScroll = UIScrollView(); chipScroll.showsHorizontalScrollIndicator = false; chipScroll.snp.makeConstraints { $0.height.equalTo(36) }
        let chips = UIStackView(); chips.spacing = 8; chipScroll.addSubview(chips); chips.snp.makeConstraints { $0.edges.equalTo(chipScroll.contentLayoutGuide); $0.height.equalTo(chipScroll.frameLayoutGuide) }
        repository.categories.forEach { name in let chip = ChipButton(title: name); chip.isSelected = name == selectedCategory; chip.addAction(UIAction { [weak self, weak chip] _ in self?.selectedCategory = name; chips.arrangedSubviews.compactMap { $0 as? ChipButton }.forEach { $0.isSelected = $0 === chip }; self?.render(); self?.renderRooms() }, for: .touchUpInside); chips.addArrangedSubview(chip) }; stack.addArrangedSubview(chipScroll)
        stack.addArrangedSubview(section("Popular chatrooms"))
        let roomViewport = UIView(); roomViewport.snp.makeConstraints { $0.height.equalTo(112) }
        let roomScroll = UIScrollView(); roomScroll.showsHorizontalScrollIndicator = false; roomScroll.clipsToBounds = true; roomViewport.addSubview(roomScroll)
        roomScroll.snp.makeConstraints { $0.leading.top.bottom.equalToSuperview(); $0.trailing.equalToSuperview().offset(7) }
        roomStack.spacing = 5; roomScroll.addSubview(roomStack); roomStack.snp.makeConstraints { $0.edges.equalTo(roomScroll.contentLayoutGuide); $0.height.equalTo(roomScroll.frameLayoutGuide) }
        renderRooms(); stack.addArrangedSubview(roomViewport)
        feed.axis = .vertical; feed.spacing = 14; stack.addArrangedSubview(feed)
    }
    private func roomCard(_ room: ChatRoom) -> UIView {
        let value = UIButton(type: .custom)
        value.layer.cornerRadius = 18
        value.layer.cornerCurve = .continuous
        value.clipsToBounds = true
        value.snp.makeConstraints { $0.width.equalTo(170); $0.height.equalTo(112) }

        let background = UIImageView(image: UIImage(named: room.coverAsset))
        background.contentMode = .scaleAspectFill
        background.clipsToBounds = true
        background.isUserInteractionEnabled = false
        value.addSubview(background)
        background.snp.makeConstraints { $0.edges.equalToSuperview() }

        let shade = RoomCardShadeView()
        shade.isUserInteractionEnabled = false
        value.addSubview(shade)
        shade.snp.makeConstraints { $0.edges.equalToSuperview() }

        let title = label(room.name, size: 14, weight: .heavy, color: .white)
        title.isUserInteractionEnabled = false
        title.numberOfLines = 1
        value.addSubview(title)
        title.snp.makeConstraints { $0.leading.equalToSuperview().offset(11); $0.trailing.lessThanOrEqualToSuperview().inset(8); $0.top.equalToSuperview().offset(9) }

        let onlineBadge = UIView()
        onlineBadge.isUserInteractionEnabled = false
        onlineBadge.backgroundColor = Palette.online
        onlineBadge.layer.cornerRadius = 5
        value.addSubview(onlineBadge)
        onlineBadge.snp.makeConstraints { $0.leading.equalToSuperview().offset(11); $0.top.equalToSuperview().offset(31); $0.width.equalTo(43); $0.height.equalTo(10) }
        let onlineDot = UIView(); onlineDot.backgroundColor = .white; onlineDot.layer.cornerRadius = 2
        let onlineText = label("\(room.online) online", size: 5, weight: .bold, color: .white)
        onlineBadge.addSubview(onlineDot); onlineBadge.addSubview(onlineText)
        onlineDot.snp.makeConstraints { $0.leading.equalToSuperview().offset(4); $0.centerY.equalToSuperview(); $0.width.height.equalTo(4) }
        onlineText.snp.makeConstraints { $0.leading.equalTo(onlineDot.snp.trailing).offset(3); $0.centerY.equalToSuperview().offset(-0.5) }

        let avatarRow = UIStackView(); avatarRow.spacing = -5; avatarRow.isUserInteractionEnabled = false
        ["Figma-256-1234-ellipse35-d9e61420", "Figma-256-1234-ellipse36-a0c08173", "Figma-256-1234-ellipse37-f50743b0"].forEach { asset in
            let avatar = UIImageView(image: UIImage(named: asset)); avatar.contentMode = .scaleAspectFill; avatar.clipsToBounds = true; avatar.layer.cornerRadius = 8; avatar.layer.borderWidth = 1; avatar.layer.borderColor = UIColor.white.cgColor; avatar.snp.makeConstraints { $0.width.height.equalTo(16) }; avatarRow.addArrangedSubview(avatar)
        }
        let remaining = max(0, room.participantCount - 3); if remaining > 0 { let more = UILabel(); more.text = "+\(remaining)"; more.textAlignment = .center; more.font = AppFont.nunito(5, weight: .bold); more.textColor = .white; more.backgroundColor = UIColor(hex: 0x2E2B2E); more.layer.cornerRadius = 8; more.clipsToBounds = true; more.snp.makeConstraints { $0.width.height.equalTo(16) }; avatarRow.addArrangedSubview(more) }
        value.addSubview(avatarRow)
        avatarRow.snp.makeConstraints { $0.leading.equalToSuperview().offset(12); $0.bottom.equalToSuperview().inset(11); $0.height.equalTo(16) }

        let membersIcon = UIImageView(image: UIImage(named: "Figma-256-1234-group1000005121-8481c588")); membersIcon.contentMode = .scaleAspectFit
        let membersText = label("\(room.participantCount)/\(room.capacity)", size: 8, weight: .bold, color: .white)
        membersText.setContentCompressionResistancePriority(.required, for: .horizontal)
        let members = UIStackView(arrangedSubviews: [membersIcon, membersText]); members.alignment = .center; members.spacing = 3; members.isUserInteractionEnabled = false
        membersIcon.snp.makeConstraints { $0.width.height.equalTo(13) }
        value.addSubview(members)
        members.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(9)
            $0.bottom.equalToSuperview().inset(11)
            $0.height.equalTo(16)
        }

        value.addAction(UIAction { [weak self] _ in self?.openRoom(room.id) }, for: .touchUpInside)
        return value
    }
    private func render() {
        feed.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let posts = repository.visiblePosts.filter { selectedCategory == "All" || $0.category == selectedCategory }
        if posts.isEmpty { feed.addArrangedSubview(EmptyStateView(text: "No adventures match this category.")); return }
        posts.forEach { feed.addArrangedSubview(postCard($0)) }
    }
    private func renderRooms() { roomStack.arrangedSubviews.forEach { $0.removeFromSuperview() }; repository.visibleRooms.filter { selectedCategory == "All" || $0.category == selectedCategory }.forEach { roomStack.addArrangedSubview(roomCard($0)) } }
    private func postCard(_ post: AdventurePost) -> UIView {
        let value = AdventureFeedCardView(post: post, author: repository.user(id: post.authorID))
        value.onOpen = { [weak self] in self?.openPost(post.id) }
        value.onComment = { [weak self] in self?.openPost(post.id) }
        value.onLike = { [weak self] in self?.requireLogin { self?.repository.toggleLike(postID: post.id) } }
        return value
    }
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) { if let id = gesture.name { openPost(id) } }
    private func openPost(_ id: String) { requireLogin { self.navigationController?.pushViewController(PostDetailViewController(postID: id), animated: true) } }
    private func openRoom(_ id: String) {
        requireLogin {
            self.repository.join(roomID: id)
            self.navigationController?.pushViewController(ChatViewController(kind: .room(id)), animated: true)
        }
    }
    @objc private func openAI() { requireLogin { self.navigationController?.pushViewController(AIAssistantViewController(), animated: true) } }
    override func repositoryDidChange() { render(); renderRooms() }
}

final class DiscoverViewController: BaseScrollableViewController {
    private let themeAssets = [
        "Camping": "Figma-268-2889-camping-d38a4d93", "Hiking": "Figma-268-2889-hiking-c69b4f5e",
        "Rock Climbing": "Figma-268-2889-rock-climbing-c01af435", "Kayaking": "Figma-268-2889-kayaking-870f07cc",
        "Birdwatching": "Figma-268-2889-birdwatching-6bdcacc7", "Stargazing": "Figma-268-2889-stargazing-eb6b2f7f",
        "Forest Discovery": "Figma-268-2889-forest-discovery-3655be6b", "Waterfalls": "Figma-268-2889-waterfalls-40ce97d3",
        "National Parks": "Figma-268-2889-national-parks-ea9d0e91", "Weekend Trips": "Figma-268-2889-weekend-trips-e9bde857"
    ]
    private let themeCounts = ["Camping": "2.8k adventures", "Hiking": "5.4k adventures", "Rock Climbing": "1.2k adventures", "Kayaking": "980 adventures", "Birdwatching": "1.6k adventures", "Stargazing": "2.1k adventures", "Forest Discovery": "3.9k adventures", "Waterfalls": "1.4k adventures", "National Parks": "6.2k adventures", "Weekend Trips": "4.8k adventures"]
    private let content = UIStackView()
    override func viewDidLoad() {
        super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false)
        stack.spacing = 10
        let header = UIView(); header.snp.makeConstraints { $0.height.equalTo(66) }; let heading = titleLabel("Discover", size: 38); heading.font = AppFont.nunito(38, weight: .black, italic: true); let subtitle = label("Find your next micro adventure.", size: 12); let search = UIButton(type: .custom); search.setImage(UIImage(named: "search")?.withRenderingMode(.alwaysOriginal), for: .normal); search.backgroundColor = Palette.purple; search.layer.cornerRadius = 28; search.layer.cornerCurve = .continuous; search.imageView?.contentMode = .scaleAspectFit; search.addTarget(self, action: #selector(openSearch), for: .touchUpInside); header.addSubview(heading); header.addSubview(subtitle); header.addSubview(search); heading.snp.makeConstraints { $0.leading.top.equalToSuperview() }; subtitle.snp.makeConstraints { $0.leading.equalToSuperview(); $0.top.equalToSuperview().offset(49) }; search.snp.makeConstraints { $0.trailing.equalToSuperview(); $0.top.equalToSuperview().offset(5); $0.width.height.equalTo(56) }; stack.addArrangedSubview(header)
        content.axis = .vertical; content.spacing = 10; stack.addArrangedSubview(content); renderContent()
    }
    private func renderContent() { content.arrangedSubviews.forEach { $0.removeFromSuperview() }; content.addArrangedSubview(section("Explore by theme")); content.addArrangedSubview(imageGrid(items: repository.themes)); content.addArrangedSubview(section("Popular destinations")); content.addArrangedSubview(destinationGrid()) }
    private func imageGrid(items: [String]) -> UIView { let container = UIStackView(); container.axis = .vertical; container.spacing = 10; stride(from: 0, to: items.count, by: 2).forEach { start in let row = UIStackView(); row.spacing = 10; row.distribution = .fillEqually; items[start..<min(start + 2, items.count)].forEach { item in let count = repository.visiblePosts.filter { $0.category == item }.count; let value = imageTile(title: item, subtitle: "\(count) adventure\(count == 1 ? "" : "s")", asset: themeAssets[item] ?? "Figma-268-2889-camping-d38a4d93"); value.addAction(UIAction { [weak self] _ in self?.openTopic(item) }, for: .touchUpInside); row.addArrangedSubview(value) }; container.addArrangedSubview(row) }; return container }
    private func destinationGrid() -> UIView {
        let scroll = UIScrollView(); scroll.showsHorizontalScrollIndicator = false; scroll.alwaysBounceHorizontal = true
        let row = UIStackView(); row.spacing = 10
        scroll.addSubview(row)
        row.snp.makeConstraints { $0.edges.equalTo(scroll.contentLayoutGuide); $0.height.equalTo(scroll.frameLayoutGuide) }
        let yosemiteCount = repository.visiblePosts.filter { $0.location.localizedCaseInsensitiveContains("Yosemite") }.count; let tahoeCount = repository.visiblePosts.filter { $0.location.localizedCaseInsensitiveContains("Lake Tahoe") }.count
        let yosemite = imageTile(title: "Yosemite", subtitle: "\(yosemiteCount) cards", asset: "Figma-268-2889-yosemite-72538f09", tall: true)
        let tahoe = imageTile(title: "Lake Tahoe", subtitle: "\(tahoeCount) cards", asset: "Figma-268-2889-zion-9b5d7493", tall: true)
        yosemite.addAction(UIAction { [weak self] _ in self?.openTopic("Yosemite") }, for: .touchUpInside)
        tahoe.addAction(UIAction { [weak self] _ in self?.openTopic("Lake Tahoe") }, for: .touchUpInside)
        [yosemite, tahoe].forEach { $0.snp.makeConstraints { $0.width.equalTo(179) }; row.addArrangedSubview($0) }
        scroll.snp.makeConstraints { $0.height.equalTo(92) }
        return scroll
    }
    private func imageTile(title: String, subtitle: String, asset: String, tall: Bool = false) -> UIButton { let value = UIButton(type: .system); value.layer.cornerRadius = 16; value.clipsToBounds = true; let image = UIImageView(image: UIImage(named: asset)); image.contentMode = .scaleAspectFill; image.clipsToBounds = true; image.isUserInteractionEnabled = false; value.addSubview(image); image.snp.makeConstraints { $0.edges.equalToSuperview() }; let shade = UIView(); shade.backgroundColor = UIColor.black.withAlphaComponent(0.16); shade.isUserInteractionEnabled = false; value.addSubview(shade); shade.snp.makeConstraints { $0.edges.equalToSuperview() }; let copy = UIStackView(); copy.axis = .vertical; copy.spacing = 0; copy.isUserInteractionEnabled = false; let titleLabel = label(title, size: tall ? 18 : 14, weight: .heavy, color: .white); let subtitleLabel = label(subtitle, size: 11, weight: .heavy, color: tall ? Palette.lime : .white); copy.addArrangedSubview(titleLabel); copy.addArrangedSubview(subtitleLabel); value.addSubview(copy); copy.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(10); $0.bottom.equalToSuperview().inset(9) }; value.snp.makeConstraints { $0.height.equalTo(tall ? 92 : 66) }; return value }
    @objc private func noop() {}
    @objc private func openSearch() { navigationController?.pushViewController(SearchViewController(), animated: true) }
    private func openTopic(_ name: String) { navigationController?.pushViewController(TopicViewController(topic: name), animated: true) }
    private func open(_ id: String) { requireLogin { self.navigationController?.pushViewController(PostDetailViewController(postID: id), animated: true) } }
    override func repositoryDidChange() { renderContent() }
}

final class MessagesViewController: BaseScrollableViewController {
    private let chatsButton = UIButton(type: .system); private let roomsButton = UIButton(type: .system); private let list = UIStackView(); private var selectedIndex: Int
    init(selectedIndex: Int = 0) { self.selectedIndex = selectedIndex; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { self.selectedIndex = 0; super.init(coder: coder) }
    override func viewDidLoad() {
        super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); stack.spacing = 10
        let heading = titleLabel("Messages", size: 38); heading.font = AppFont.nunito(38, weight: .black, italic: true); stack.addArrangedSubview(heading)
        stack.addArrangedSubview(label("Stories continue in conversation.", size: 12))
        let segment = UIStackView(arrangedSubviews: [chatsButton, roomsButton, UIView()]); segment.spacing = 10; segment.alignment = .center
        chatsButton.snp.makeConstraints { $0.width.equalTo(110); $0.height.equalTo(40) }
        roomsButton.snp.makeConstraints { $0.width.equalTo(143); $0.height.equalTo(40) }
        [chatsButton, roomsButton].forEach { $0.layer.cornerRadius = 20; $0.layer.cornerCurve = .continuous; $0.titleLabel?.font = AppFont.nunito(14, weight: .bold) }; chatsButton.setTitle("Chats", for: .normal); roomsButton.setTitle("Chatrooms", for: .normal); chatsButton.addTarget(self, action: #selector(showChats), for: .touchUpInside); roomsButton.addTarget(self, action: #selector(showRooms), for: .touchUpInside); stack.addArrangedSubview(segment)
        list.axis = .vertical; list.spacing = 10; stack.addArrangedSubview(list); render()
    }
    @objc private func showChats() { selectedIndex = 0; render() }
    @objc private func showRooms() { selectedIndex = 1; render() }
    @objc private func render() {
        list.arrangedSubviews.forEach { $0.removeFromSuperview() }
        [chatsButton, roomsButton].enumerated().forEach { index, button in button.backgroundColor = index == selectedIndex ? Palette.purple : UIColor(hex: 0xD5D0E0); button.setTitleColor(index == selectedIndex ? .white : Palette.ink, for: .normal) }
        if selectedIndex == 0 {
            let ai = UIButton(type: .custom); ai.setBackgroundImage(UIImage(named: "Figma-268-3129-ai-entry-1a4aae34")?.withRenderingMode(.alwaysOriginal), for: .normal); ai.layer.cornerRadius = 18; ai.layer.cornerCurve = .continuous; ai.clipsToBounds = true; ai.snp.makeConstraints { $0.height.equalTo(100) }
            let allowance = UILabel(); allowance.backgroundColor = .white; allowance.textAlignment = .center; allowance.layer.cornerRadius = 13; allowance.clipsToBounds = true
            let allowanceText = NSMutableAttributedString(string: "\(repository.aiFreeMessages)", attributes: [.font: AppFont.nunito(20, weight: .black), .foregroundColor: UIColor(hex: 0x8CD51C)])
            allowanceText.append(NSAttributedString(string: "  free messages left", attributes: [.font: AppFont.nunito(11, weight: .black), .foregroundColor: Palette.ink])); allowance.attributedText = allowanceText
            ai.addSubview(allowance); allowance.snp.makeConstraints { $0.trailing.equalToSuperview().inset(24); $0.bottom.equalToSuperview().inset(14); $0.width.equalTo(156); $0.height.equalTo(26) }
            ai.addAction(UIAction { [weak self] _ in self?.navigationController?.pushViewController(AIAssistantViewController(), animated: true) }, for: .touchUpInside); list.addArrangedSubview(ai)
            let values = repository.visibleConversations; if values.isEmpty { list.addArrangedSubview(EmptyStateView(text: "No conversations yet.")) }
            values.forEach { chat in let user = repository.user(id: chat.peerID); let latest = chat.messages.last?.text ?? "Start a conversation"; let value = messageRow(title: user?.name ?? "Explorer", subtitle: latest, asset: "", userID: chat.peerID); value.addAction(UIAction { [weak self] _ in self?.navigationController?.pushViewController(ChatViewController(kind: .direct(chat.peerID)), animated: true) }, for: .touchUpInside); list.addArrangedSubview(value) }
        } else {
            let userID = repository.currentUserID ?? ""
            let rooms = repository.visibleRooms
            let joinedRooms = rooms.filter { $0.members.contains(userID) }
            if !joinedRooms.isEmpty {
                list.addArrangedSubview(section("Your chatrooms"))
                joinedRooms.forEach { room in
                    let value = messageRow(title: room.name, subtitle: "\(room.online) online", asset: room.coverAsset)
                    value.addAction(UIAction { [weak self] _ in self?.navigationController?.pushViewController(ChatViewController(kind: .room(room.id)), animated: true) }, for: .touchUpInside)
                    list.addArrangedSubview(value)
                }
            }
            list.addArrangedSubview(section("Discover more"))
            repository.discoverRooms.forEach { room in
                let row = messageRow(title: room.name, subtitle: "\(room.online) online", asset: room.coverAsset, join: true, joined: false)
                row.addAction(UIAction { [weak self] _ in self?.repository.join(roomID: room.id) }, for: .touchUpInside)
                list.addArrangedSubview(row)
            }
        }
    }
    private func messageRow(title: String, subtitle: String, asset: String, userID: String? = nil, join: Bool = false, joined: Bool = false) -> UIButton { let value = UIButton(type: .system); value.backgroundColor = join ? .white : .clear; value.layer.cornerRadius = 16; value.snp.makeConstraints { $0.height.equalTo(72) }; let avatarImage = userID.flatMap { UserAvatarStore.image(userID: $0) } ?? UIImage(named: asset); let avatar = UIImageView(image: avatarImage); avatar.tintColor = Palette.muted; avatar.contentMode = .scaleAspectFill; avatar.clipsToBounds = true; avatar.layer.cornerRadius = 27; avatar.isUserInteractionEnabled = false; value.addSubview(avatar); avatar.snp.makeConstraints { $0.leading.equalToSuperview(); $0.centerY.equalToSuperview(); $0.width.height.equalTo(54) }; let texts = UIStackView(); texts.axis = .vertical; texts.isUserInteractionEnabled = false; let titleLabel = label(title, size: 17, weight: .heavy); let subtitleLabel = label(subtitle, size: 12, color: Palette.muted); texts.addArrangedSubview(titleLabel); texts.addArrangedSubview(subtitleLabel); value.addSubview(texts); texts.snp.makeConstraints { $0.leading.equalTo(avatar.snp.trailing).offset(12); $0.centerY.equalToSuperview(); $0.trailing.lessThanOrEqualToSuperview().inset(join ? 88 : 8) }; if join { let badge = UILabel(); badge.text = joined ? "Joined" : "Join"; badge.textAlignment = .center; badge.font = AppFont.nunito(12, weight: .bold); badge.textColor = joined ? Palette.purple : Palette.ink; badge.backgroundColor = joined ? UIColor(hex: 0xF1EDFF) : Palette.lime; badge.layer.cornerRadius = 14; badge.clipsToBounds = true; badge.isUserInteractionEnabled = false; value.addSubview(badge); badge.snp.makeConstraints { $0.trailing.equalToSuperview().inset(8); $0.centerY.equalToSuperview(); $0.width.equalTo(joined ? 72 : 58); $0.height.equalTo(36) } }; return value }
    @objc private func noop() {}
    override func repositoryDidChange() { render() }
}

final class ProfileViewController: BaseScrollableViewController {
    override func viewDidLoad() { super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); build() }
    private func build() {
        guard let user = repository.currentUser else { return }
        stack.spacing = 10
        let top = UIView(); top.snp.makeConstraints { $0.height.equalTo(42) }
        let heading = titleLabel("Profile", size: 38); heading.font = AppFont.nunito(38, weight: .black, italic: true); top.addSubview(heading); heading.snp.makeConstraints { $0.leading.top.equalToSuperview() }
        let edit = UIButton(type: .custom); edit.setImage(UIImage(named: "edit")?.withRenderingMode(.alwaysOriginal), for: .normal); edit.addTarget(self, action: #selector(editProfile), for: .touchUpInside); top.addSubview(edit); edit.snp.makeConstraints { $0.trailing.equalToSuperview().inset(51); $0.centerY.equalToSuperview(); $0.width.height.equalTo(34) }
        let setting = UIButton(type: .custom); setting.setImage(UIImage(named: "setting")?.withRenderingMode(.alwaysOriginal), for: .normal); setting.addTarget(self, action: #selector(settings), for: .touchUpInside); top.addSubview(setting); setting.snp.makeConstraints { $0.trailing.centerY.equalToSuperview(); $0.width.height.equalTo(34) }
        stack.addArrangedSubview(top); stack.addArrangedSubview(label("Your adventure archive.", size: 12))
        let header = UIStackView(); header.alignment = .center; header.spacing = 14; let avatar = UIImageView(image: UserAvatarStore.displayImage(for: user, fallbackAsset: "Figma-278-3402-profile-photo-96bd475e")); avatar.tintColor = Palette.muted; avatar.contentMode = .scaleAspectFill; avatar.clipsToBounds = true; avatar.layer.cornerRadius = 40; avatar.snp.makeConstraints { $0.width.height.equalTo(80) }; header.addArrangedSubview(avatar); let text = UIStackView(); text.axis = .vertical; text.addArrangedSubview(titleLabel(user.name, size: 24)); text.addArrangedSubview(label(user.bio, size: 12, color: Palette.muted, lines: 0)); header.addArrangedSubview(text); stack.addArrangedSubview(header)
        let counts = UIStackView(); counts.distribution = .fillEqually; [("Following", user.following.count), ("Followers", user.followers.count), ("Adventures", repository.posts.filter { $0.authorID == user.id }.count)].forEach { pair in let b = UIButton(type: .system); b.setTitle("\(pair.1)\n\(pair.0)", for: .normal); b.setTitleColor(Palette.ink, for: .normal); b.titleLabel?.font = AppFont.nunito(13, weight: .bold); b.titleLabel?.numberOfLines = 2; b.titleLabel?.textAlignment = .center; if pair.0 != "Adventures" { b.addAction(UIAction { [weak self] _ in self?.navigationController?.pushViewController(AccountFollowListViewController(kind: pair.0 == "Following" ? .following : .followers), animated: true) }, for: .touchUpInside) }; counts.addArrangedSubview(b) }; stack.addArrangedSubview(counts)
        let coins = UIButton(type: .custom); coins.setBackgroundImage(UIImage(named: "me_bg")?.withRenderingMode(.alwaysOriginal), for: .normal); coins.layer.cornerRadius = 22; coins.layer.cornerCurve = .continuous; coins.clipsToBounds = true; coins.snp.makeConstraints { $0.height.equalTo(90) }; coins.addTarget(self, action: #selector(recharge), for: .touchUpInside)
        let coinTitle = label("Wanoo Coins", size: 15, weight: .semibold, color: .white); let coinAmount = label(NumberFormatter.localizedString(from: NSNumber(value: user.coins), number: .decimal), size: 34, weight: .black, color: Palette.lime); coins.addSubview(coinTitle); coins.addSubview(coinAmount); coinTitle.snp.makeConstraints { $0.leading.equalToSuperview().offset(25); $0.top.equalToSuperview().offset(17) }; coinAmount.snp.makeConstraints { $0.leading.equalTo(coinTitle); $0.top.equalTo(coinTitle.snp.bottom).offset(-2) }; stack.addArrangedSubview(coins)
        stack.addArrangedSubview(section("My Adventures"))
        let myPosts = repository.posts.filter { $0.authorID == user.id }
        if myPosts.isEmpty {
            stack.addArrangedSubview(EmptyStateView(text: "No adventures yet."))
        } else {
            let adventureScroll = UIScrollView()
            adventureScroll.showsHorizontalScrollIndicator = false
            adventureScroll.alwaysBounceHorizontal = true
            adventureScroll.isDirectionalLockEnabled = true
            let adventureRow = UIStackView()
            adventureRow.axis = .horizontal
            adventureRow.spacing = 10
            adventureScroll.addSubview(adventureRow)
            adventureRow.snp.makeConstraints {
                $0.edges.equalTo(adventureScroll.contentLayoutGuide)
                $0.height.equalTo(adventureScroll.frameLayoutGuide)
            }
            myPosts.forEach { post in
                let tile = UIButton(type: .custom)
                tile.clipsToBounds = true
                tile.layer.cornerRadius = 16
                tile.layer.cornerCurve = .continuous
                let image = UIImageView(image: PostMediaStore.previewImage(postID: post.id) ?? UIImage(named: "FigmaForest"))
                image.contentMode = .scaleAspectFill
                image.clipsToBounds = true
                image.isUserInteractionEnabled = false
                tile.addSubview(image)
                image.snp.makeConstraints { $0.edges.equalToSuperview() }
                let shade = UIView(); shade.backgroundColor = UIColor.black.withAlphaComponent(0.12); shade.isUserInteractionEnabled = false
                tile.addSubview(shade); shade.snp.makeConstraints { $0.edges.equalToSuperview() }
                let name = label(post.title, size: 11, weight: .bold, color: .white)
                name.isUserInteractionEnabled = false
                tile.addSubview(name)
                name.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview().inset(10) }
                tile.addAction(UIAction { [weak self] _ in
                    self?.navigationController?.pushViewController(PostDetailViewController(postID: post.id), animated: true)
                }, for: .touchUpInside)
                tile.snp.makeConstraints { $0.width.equalTo(116); $0.height.equalTo(116) }
                adventureRow.addArrangedSubview(tile)
            }
            adventureScroll.snp.makeConstraints { $0.height.equalTo(116) }
            stack.addArrangedSubview(adventureScroll)
        }
        stack.addArrangedSubview(section("My Passports"))
        let myPassports = repository.passports.filter { passport in
            repository.posts.contains(where: { $0.id == passport.postID && $0.authorID == user.id })
        }
        if myPassports.isEmpty {
            stack.addArrangedSubview(EmptyStateView(text: "No passports yet."))
        } else {
            let passportScroll = UIScrollView()
            passportScroll.showsHorizontalScrollIndicator = false
            passportScroll.alwaysBounceHorizontal = true
            passportScroll.isDirectionalLockEnabled = true
            passportScroll.decelerationRate = .fast
            let passportRow = UIStackView()
            passportRow.axis = .horizontal
            passportRow.alignment = .top
            passportRow.spacing = 12
            passportScroll.addSubview(passportRow)
            passportRow.snp.makeConstraints {
                $0.edges.equalTo(passportScroll.contentLayoutGuide)
                $0.height.equalTo(passportScroll.frameLayoutGuide)
            }
            myPassports.forEach { passport in
                guard let post = repository.post(id: passport.postID) else { return }
                let card = ProfilePassportCardView(passport: passport, post: post, user: user)
                card.snp.makeConstraints { $0.width.equalTo(142) }
                passportRow.addArrangedSubview(card)
            }
            passportScroll.snp.makeConstraints { $0.height.equalTo(205) }
            stack.addArrangedSubview(passportScroll)
        }
    }
    @objc private func noop() {}
    @objc private func recharge() { navigationController?.pushViewController(RechargeViewController(), animated: true) }
    @objc private func editProfile() { navigationController?.pushViewController(EditProfileViewController(), animated: true) }
    @objc private func settings() { navigationController?.pushViewController(SettingsViewController(), animated: true) }
    override func repositoryDidChange() { stack.arrangedSubviews.forEach { $0.removeFromSuperview() }; build() }
}

private final class ProfilePassportCardView: UIView {
    init(passport: PassportRecord, post: AdventurePost, user: UserProfile) {
        super.init(frame: .zero)
        let style = PassportStyle(name: passport.template)

        let backing = UIImageView(image: UIImage(named: style.backingAsset))
        backing.contentMode = .scaleAspectFit
        backing.clipsToBounds = false
        addSubview(backing)
        backing.snp.makeConstraints { $0.edges.equalToSuperview().inset(2) }

        // The template image is only the decorative passport shell. Its center
        // is populated from the post so saved passports never appear blank.
        let content = UIView()
        content.backgroundColor = UIColor(hex: style.paperColor)
        content.clipsToBounds = true
        content.layer.cornerRadius = 2
        addSubview(content)
        content.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(2)
            $0.top.equalToSuperview().offset(42)
            $0.width.equalTo(102)
            $0.height.equalTo(124)
        }

        let band = UILabel()
        band.text = passport.template.uppercased()
        band.textAlignment = .center
        band.textColor = .white
        band.backgroundColor = UIColor(hex: style.accentColor)
        band.font = AppFont.nunito(8, weight: .black)
        content.addSubview(band)
        band.snp.makeConstraints { $0.leading.trailing.top.equalToSuperview(); $0.height.equalTo(15) }

        let media = UIImageView(image: PostMediaStore.previewImage(postID: post.id) ?? UIImage(named: "FigmaForest"))
        media.contentMode = .scaleAspectFill
        media.clipsToBounds = true
        media.layer.cornerRadius = 2
        media.layer.borderWidth = 2
        media.layer.borderColor = UIColor.white.cgColor
        content.addSubview(media)
        media.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(7)
            $0.top.equalTo(band.snp.bottom).offset(6)
            $0.height.equalTo(47)
        }

        let details = UIStackView()
        details.axis = .vertical
        details.spacing = 2
        content.addSubview(details)
        details.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.equalTo(media.snp.bottom).offset(6)
        }
        let date = post.createdAt.formatted(date: .abbreviated, time: .omitted)
        [
            ("Explorer", user.name),
            ("Date", date),
            ("Duration", post.duration),
            ("Highlight", post.highlights.isEmpty ? post.title : post.highlights)
        ].forEach { key, value in
            let row = UIView()
            let keyLabel = UILabel()
            keyLabel.text = key
            keyLabel.font = AppFont.nunito(4.5, weight: .semibold)
            keyLabel.textColor = UIColor(hex: 0xA7A99F)
            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = AppFont.nunito(4.5, weight: .bold)
            valueLabel.textColor = Palette.ink
            valueLabel.textAlignment = .right
            valueLabel.adjustsFontSizeToFitWidth = true
            valueLabel.minimumScaleFactor = 0.6
            row.addSubview(keyLabel)
            row.addSubview(valueLabel)
            keyLabel.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }
            valueLabel.snp.makeConstraints {
                $0.leading.greaterThanOrEqualTo(keyLabel.snp.trailing).offset(3)
                $0.trailing.centerY.equalToSuperview()
            }
            row.snp.makeConstraints { $0.height.equalTo(7) }
            details.addArrangedSubview(row)
        }

        snp.makeConstraints { $0.height.equalTo(200) }
        isAccessibilityElement = true
        accessibilityLabel = "\(passport.template) passport, \(post.title)"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
