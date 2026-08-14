import UIKit

#if DEBUG
enum VisualTestRouter {
    static func controller(arguments: [String]) -> UIViewController? {
        guard let marker = arguments.firstIndex(of: "--visual-node"), arguments.indices.contains(marker + 1) else { return nil }
        let nodeID = arguments[marker + 1]
        prepareDeterministicData()
        switch nodeID {
        case "309:3255": return SplashViewController()
        case "309:3265": return UINavigationController(rootViewController: WelcomeViewController())
        case "309:3285": return UINavigationController(rootViewController: EmailAuthViewController(mode: .signIn))
        case "309:3296": return UINavigationController(rootViewController: EmailAuthViewController(mode: .register))
        case "309:3307": return UINavigationController(rootViewController: EmailAuthViewController(mode: .reset))
        case "309:3318": return UINavigationController(rootViewController: ProfileSetupViewController())
        case "256:1234": return tab(index: 0)
        case "268:2889": return tab(index: 1)
        case "268:3129": return tab(index: 3)
        case "268:3262": return tab(index: 3, messagesSegment: 1)
        case "278:3402": return tab(index: 4)
        case "285:4316": return UINavigationController(rootViewController: PublishViewController())
        case "280:3522": return UINavigationController(rootViewController: PostDetailViewController(postID: "post-forest"))
        case "282:3716": return UINavigationController(rootViewController: AIAssistantViewController())
        case "320:4850": return UINavigationController(rootViewController: SearchViewController())
        case "285:4547": return UINavigationController(rootViewController: RechargeViewController(visualPackages: !arguments.contains("--live-products")))
        case "285:4644": return UINavigationController(rootViewController: ReportViewController(targetID: "user-chris"))
        case "287:4745": prepareBlockedUsers(); return UINavigationController(rootViewController: BlockListViewController())
        case "287:4816": return UINavigationController(rootViewController: AccountFollowListViewController(kind: .followers, visualIDs: visualExplorerIDs))
        case "287:4862": return UINavigationController(rootViewController: AccountFollowListViewController(kind: .following, visualIDs: visualExplorerIDs))
        case "287:4908": return UINavigationController(rootViewController: SettingsViewController())
        case "289:4969": return UINavigationController(rootViewController: EditProfileViewController(visualMode: true))
        case "297:5093": return EULAOverlayController(onCancelled: {})
        case "298:5257": return InsufficientBalanceAlertController()
        case "298:5406": return LoginRequiredAlertController()
        case "305:5894": return PaymentConfirmAlertController()
        case "305:6043": return DeleteAccountAlertController()
        case "306:6204": return LogoutAlertController()
        case "349:3483": return AIContinuePaymentAlertController()
        case "305:5598": return ChatLimitAlertController()
        case "283:3895": return UINavigationController(rootViewController: TopicViewController(topic: "Weekend Trips"))
        case "283:4002": return UINavigationController(rootViewController: OtherProfileViewController(userID: "user-maya"))
        case "283:3828": return UINavigationController(rootViewController: ChatViewController(kind: .room("room-yosemite")))
        case "283:4185": return UINavigationController(rootViewController: ChatViewController(kind: .direct("user-maya")))
        case "283:4245": return UINavigationController(rootViewController: ChatViewController(kind: .direct("user-maya"), voiceMode: true))
        case "292:5041": return UINavigationController(rootViewController: PassportViewController(postID: "post-forest", selectedTemplate: "Parks"))
        case "306:6355": return UINavigationController(rootViewController: PassportViewController(postID: "post-forest", selectedTemplate: "Vintage"))
        case "306:6421": return UINavigationController(rootViewController: PassportViewController(postID: "post-forest", selectedTemplate: "Mountain"))
        case "306:6487": return UINavigationController(rootViewController: PassportViewController(postID: "post-forest", selectedTemplate: "Forest"))
        case "311:4166": return UINavigationController(rootViewController: PassportViewController(postID: "post-forest", selectedTemplate: "Minimal"))
        default: return nil
        }
    }

    private static func tab(index: Int, messagesSegment: Int = 0) -> UIViewController {
        let controller = MainTabBarController(messagesSegment: messagesSegment)
        controller.loadViewIfNeeded()
        controller.selectVisualTab(index)
        return controller
    }

    private static func prepareDeterministicData() {
        AppRepository.shared.reloadSeedData()
        _ = AppRepository.shared.signIn(email: "123@gmail.com", password: "12345678")
    }

    private static let visualExplorerIDs = ["user-chris", "user-evelyn", "user-mia"]
    private static func prepareBlockedUsers() { visualExplorerIDs.forEach { AppRepository.shared.block(userID: $0) } }
}
#endif
