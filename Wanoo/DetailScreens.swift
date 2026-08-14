import UIKit
import SnapKit
import AVFoundation
import AVKit
import PhotosUI
import UniformTypeIdentifiers

final class ImageGalleryViewController: UIViewController, UIScrollViewDelegate {
    private let images: [UIImage]
    private let initialIndex: Int
    private let scroll = UIScrollView()
    private let page = UIPageControl()
    init(images: [UIImage], initialIndex: Int = 0) { self.images = images; self.initialIndex = initialIndex; super.init(nibName: nil, bundle: nil); modalPresentationStyle = .fullScreen }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad(); view.backgroundColor = .black
        scroll.isPagingEnabled = true; scroll.showsHorizontalScrollIndicator = false; scroll.delegate = self; view.addSubview(scroll); scroll.snp.makeConstraints { $0.edges.equalToSuperview() }
        let row = UIStackView(); scroll.addSubview(row); row.snp.makeConstraints { $0.edges.equalTo(scroll.contentLayoutGuide); $0.height.equalTo(scroll.frameLayoutGuide) }
        images.forEach { image in let imageView = UIImageView(image: image); imageView.contentMode = .scaleAspectFit; row.addArrangedSubview(imageView); imageView.snp.makeConstraints { $0.width.equalTo(scroll.frameLayoutGuide) } }
        page.numberOfPages = images.count; page.currentPage = initialIndex; page.hidesForSinglePage = true; view.addSubview(page); page.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16) }
        let close = UIButton(type: .system); close.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal); close.tintColor = .white; close.backgroundColor = UIColor.black.withAlphaComponent(0.45); close.layer.cornerRadius = 20; close.addTarget(self, action: #selector(dismissGallery), for: .touchUpInside); view.addSubview(close); close.snp.makeConstraints { $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16); $0.top.equalTo(view.safeAreaLayoutGuide).offset(10); $0.width.height.equalTo(40) }
        view.layoutIfNeeded(); scroll.setContentOffset(CGPoint(x: CGFloat(initialIndex) * scroll.bounds.width, y: 0), animated: false)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { guard scrollView.bounds.width > 0 else { return }; page.currentPage = Int(round(scrollView.contentOffset.x / scrollView.bounds.width)) }
    @objc private func dismissGallery() { dismiss(animated: true) }
}

final class PostDetailViewController: BaseScrollableViewController, UIScrollViewDelegate {
    private let postID: String; private let comments = UIStackView(); private let input = UITextField(); private let like = UIButton(type: .custom); private let likeIcon = UIImageView(image: UIImage(named: "good")?.withRenderingMode(.alwaysTemplate)); private let likeCount = UILabel(); private let commentCount = UILabel(); private let commentIcon = UIImageView(image: UIImage(named: "comment")?.withRenderingMode(.alwaysTemplate)); private let heroMediaScroll = UIScrollView(); private let heroPage = UIPageControl()
    init(postID: String) { self.postID = postID; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override func viewDidLoad() { super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); scrollView.contentInsetAdjustmentBehavior = .never; scrollView.snp.remakeConstraints { $0.edges.equalToSuperview() }; scrollView.contentInset.bottom = 76; stack.snp.updateConstraints { $0.top.equalToSuperview() }; build() }
    private func build() {
        guard let post = repository.post(id: postID) else { stack.addArrangedSubview(EmptyStateView(text: "This adventure is no longer available.")); return }
        let hero = UIView(); hero.clipsToBounds = false; hero.snp.makeConstraints { $0.height.equalTo(360) }; stack.addArrangedSubview(hero)
        buildHeroMedia(in: hero)
        let back = UIButton(type: .system); back.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21, weight: .bold)), for: .normal); back.tintColor = .white; back.addTarget(self, action: #selector(close), for: .touchUpInside); hero.addSubview(back); back.snp.makeConstraints { $0.leading.equalToSuperview().offset(2); $0.top.equalTo(view.safeAreaLayoutGuide).offset(8); $0.width.height.equalTo(34) }
        let moreButton = UIButton(type: .system); moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal); moreButton.tintColor = .white; moreButton.addTarget(self, action: #selector(more), for: .touchUpInside); hero.addSubview(moreButton); moreButton.snp.makeConstraints { $0.trailing.equalToSuperview().inset(3); $0.centerY.equalTo(back); $0.width.height.equalTo(34) }
        let title = label(post.title.uppercased(), size: 28, weight: .heavy, color: .white); hero.addSubview(title); title.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(8); $0.bottom.equalToSuperview().inset(42) }
        let metadata = [post.location.isEmpty ? nil : post.location, post.duration].compactMap { $0 }.joined(separator: " · "); let location = label(metadata, size: 11, weight: .bold, color: Palette.lime); hero.addSubview(location); location.snp.makeConstraints { $0.leading.equalTo(title); $0.top.equalTo(title.snp.bottom).offset(4) }
        if let author = repository.user(id: post.authorID) { let authorButton = UIButton(type: .system); let avatar = UIImageView(image: UserAvatarStore.image(userID: author.id) ?? UIImage(named: "Figma-280-3522-avatar-ce5410a5")); avatar.contentMode = .scaleAspectFill; avatar.layer.cornerRadius = 24; avatar.clipsToBounds = true; authorButton.addSubview(avatar); avatar.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.width.height.equalTo(48) }; let authorName = label(author.name, size: 14, weight: .bold); let authorLocation = label(author.location, size: 11, color: Palette.muted); let authorText = UIStackView(arrangedSubviews: [authorName, authorLocation]); authorText.axis = .vertical; authorButton.addSubview(authorText); authorText.snp.makeConstraints { $0.leading.equalTo(avatar.snp.trailing).offset(12); $0.trailing.lessThanOrEqualToSuperview(); $0.centerY.equalToSuperview() }; authorButton.snp.makeConstraints { $0.height.equalTo(54) }; authorButton.addTarget(self, action: #selector(openAuthor), for: .touchUpInside); stack.addArrangedSubview(authorButton) }
        stack.addArrangedSubview(titleLabel(post.highlights, size: 22)); stack.addArrangedSubview(label(post.story, size: 14, lines: 0))
        let commentTitle = section("Comment"); commentTitle.font = AppFont.nunito(24, weight: .black, italic: true); stack.addArrangedSubview(commentTitle); comments.axis = .vertical; comments.spacing = 8; stack.addArrangedSubview(comments)
        buildBottomComposer(post: post); render()
    }
    private func style(_ value: UIButton) { value.backgroundColor = .white; value.layer.cornerRadius = 20; value.setTitleColor(Palette.ink, for: .normal); value.titleLabel?.font = AppFont.nunito(13, weight: .bold); value.snp.makeConstraints { $0.height.equalTo(44) } }
    private func render() { guard let post = repository.post(id: postID) else { return }; let me = repository.currentUserID ?? ""; let liked = post.likedBy.contains(me); let likeColor = liked ? Palette.purple : Palette.ink; likeIcon.tintColor = likeColor; likeCount.textColor = likeColor; likeCount.text = "\(post.likes)"; commentCount.text = "\(post.comments.count)"; comments.arrangedSubviews.forEach { $0.removeFromSuperview() }; let visible = post.comments.filter { !repository.blocked.contains($0.authorID) }; if visible.isEmpty { comments.addArrangedSubview(EmptyStateView(text: "No comments yet.")); return }; visible.forEach { item in
        let row = UIView(); let avatar = UIImageView(image: UserAvatarStore.image(userID: item.authorID) ?? UIImage(named: "Figma-280-3522-avatar-ce5410a5")); avatar.contentMode = .scaleAspectFill; avatar.clipsToBounds = true; avatar.layer.cornerRadius = 24; row.addSubview(avatar); avatar.snp.makeConstraints { $0.leading.top.equalToSuperview(); $0.width.height.equalTo(48) }
        let author = label(repository.user(id: item.authorID)?.name ?? "Explorer", size: 15, weight: .bold); let text = label(item.text, size: 12, lines: 0); let time = label(item.timestamp.formatted(date: .abbreviated, time: .shortened), size: 10, color: Palette.muted); row.addSubview(author); row.addSubview(text); row.addSubview(time); author.snp.makeConstraints { $0.leading.equalTo(avatar.snp.trailing).offset(12); $0.top.equalToSuperview() }; text.snp.makeConstraints { $0.leading.equalTo(author); $0.trailing.equalToSuperview(); $0.top.equalTo(author.snp.bottom).offset(2) }; time.snp.makeConstraints { $0.leading.equalTo(author); $0.top.equalTo(text.snp.bottom).offset(3); $0.bottom.equalToSuperview() }; comments.addArrangedSubview(row)
    } }
    private func buildBottomComposer(post: AdventurePost) {
        let bar = UIView(); bar.backgroundColor = .white; bar.layer.cornerRadius = 20; bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]; view.addSubview(bar); bar.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview(); $0.height.equalTo(74) }
        let write = UIImageView(image: UIImage(systemName: "pencil.line")); write.tintColor = Palette.ink; write.contentMode = .scaleAspectFit; bar.addSubview(write); write.snp.makeConstraints { $0.leading.equalToSuperview().offset(18); $0.top.equalToSuperview().offset(21); $0.width.height.equalTo(18) }
        input.placeholder = "Say something..."; input.font = AppFont.nunito(13); input.textColor = Palette.ink; input.returnKeyType = .send; input.addTarget(self, action: #selector(postComment), for: .editingDidEndOnExit); bar.addSubview(input); input.snp.makeConstraints { $0.leading.equalTo(write.snp.trailing).offset(10); $0.centerY.equalTo(write); $0.trailing.lessThanOrEqualToSuperview().inset(150); $0.height.equalTo(36) }

        like.addTarget(self, action: #selector(toggleLike), for: .touchUpInside); bar.addSubview(like); like.snp.makeConstraints { $0.trailing.equalToSuperview().inset(70); $0.centerY.equalTo(write); $0.width.equalTo(58); $0.height.equalTo(36) }
        likeIcon.contentMode = .scaleAspectFit; likeIcon.tintColor = Palette.ink; likeIcon.isUserInteractionEnabled = false; likeCount.font = AppFont.nunito(13); likeCount.textColor = Palette.ink; likeCount.isUserInteractionEnabled = false; like.addSubview(likeIcon); like.addSubview(likeCount); likeIcon.snp.makeConstraints { $0.leading.equalToSuperview().offset(7); $0.centerY.equalToSuperview(); $0.width.height.equalTo(18) }; likeCount.snp.makeConstraints { $0.leading.equalTo(likeIcon.snp.trailing).offset(6); $0.centerY.equalTo(likeIcon); $0.trailing.lessThanOrEqualToSuperview() }

        commentIcon.contentMode = .scaleAspectFit; commentIcon.tintColor = Palette.ink; bar.addSubview(commentIcon); bar.addSubview(commentCount); commentIcon.snp.makeConstraints { $0.trailing.equalTo(commentCount.snp.leading).offset(-6); $0.centerY.equalTo(write); $0.width.height.equalTo(18) }; commentCount.font = AppFont.nunito(13); commentCount.textColor = Palette.ink; commentCount.textAlignment = .left; commentCount.snp.makeConstraints { $0.trailing.equalToSuperview().inset(18); $0.centerY.equalTo(write); $0.width.greaterThanOrEqualTo(24) }
    }
    private func buildHeroMedia(in hero: UIView) {
        let records = mediaRecords
        let displayRecords = records.isEmpty ? [""] : records
        heroMediaScroll.isPagingEnabled = true
        heroMediaScroll.showsHorizontalScrollIndicator = false
        heroMediaScroll.clipsToBounds = true
        heroMediaScroll.delegate = self
        hero.addSubview(heroMediaScroll)
        heroMediaScroll.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(-18); $0.top.bottom.equalToSuperview() }

        let pages = UIStackView(); pages.axis = .horizontal; pages.spacing = 0
        heroMediaScroll.addSubview(pages)
        pages.snp.makeConstraints { $0.edges.equalTo(heroMediaScroll.contentLayoutGuide); $0.height.equalTo(heroMediaScroll.frameLayoutGuide) }
        displayRecords.enumerated().forEach { index, record in
            let page = UIView()
            let preview = record.isEmpty ? mediaPreviewImage() : PostMediaStore.previewImage(for: record)
            let image = UIImageView(image: preview ?? UIImage(named: "Figma-280-3522-hero-1bf5d6b3"))
            image.contentMode = .scaleAspectFill; image.clipsToBounds = true
            page.addSubview(image); image.snp.makeConstraints { $0.edges.equalToSuperview() }
            let tap = UIButton(type: .custom); tap.tag = index; tap.addTarget(self, action: #selector(openHeroMedia(_:)), for: .touchUpInside)
            page.addSubview(tap); tap.snp.makeConstraints { $0.edges.equalToSuperview() }
            if PostMediaStore.isVideo(record) {
                let play = UIImageView(image: UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)))
                play.tintColor = .white; play.backgroundColor = UIColor.white.withAlphaComponent(0.72); play.layer.cornerRadius = 30; play.contentMode = .center; play.isUserInteractionEnabled = false
                page.addSubview(play); play.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(60) }
            }
            pages.addArrangedSubview(page)
            page.snp.makeConstraints { $0.width.equalTo(heroMediaScroll.frameLayoutGuide) }
        }
        heroPage.numberOfPages = displayRecords.count
        heroPage.hidesForSinglePage = true
        heroPage.currentPage = 0
        hero.addSubview(heroPage)
        heroPage.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.bottom.equalToSuperview().inset(10) }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === heroMediaScroll, scrollView.bounds.width > 0 else { return }
        heroPage.currentPage = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
    }
    @objc private func openHeroMedia(_ sender: UIButton) {
        let records = mediaRecords
        guard !records.isEmpty else { openMedia(); return }
        let index = min(sender.tag, records.count - 1)
        let record = records[index]
        if PostMediaStore.isVideo(record), let url = PostMediaStore.mediaURL(for: record) {
            let player = AVPlayerViewController(); player.player = AVPlayer(url: url); player.modalPresentationStyle = .fullScreen; present(player, animated: true) { player.player?.play() }
            return
        }
        let imageRecords = records.filter { !PostMediaStore.isVideo($0) }
        let images = imageRecords.compactMap(PostMediaStore.previewImage(for:))
        let imageIndex = max(0, imageRecords.firstIndex(of: record) ?? 0)
        guard !images.isEmpty else { return }
        present(ImageGalleryViewController(images: images, initialIndex: imageIndex), animated: true)
    }
    private var mediaRecords: [String] { PostMediaStore.records(postID: postID) }
    private var firstMediaIsVideo: Bool { mediaRecords.first.map(PostMediaStore.isVideo) == true }
    private func mediaPreviewImage() -> UIImage? {
        PostMediaStore.previewImage(postID: postID) ?? UIImage(named: "Figma-280-3522-hero-1bf5d6b3")
    }
    @objc private func openMedia() {
        if let first = mediaRecords.first, PostMediaStore.isVideo(first), let url = PostMediaStore.mediaURL(for: first) {
            let player = AVPlayerViewController(); player.player = AVPlayer(url: url); player.modalPresentationStyle = .fullScreen; present(player, animated: true) { player.player?.play() }; return
        }
        let images = mediaRecords.filter { !PostMediaStore.isVideo($0) }.compactMap(PostMediaStore.previewImage(for:))
        let galleryImages = images.isEmpty ? [UIImage(named: "Figma-280-3522-hero-1bf5d6b3")].compactMap { $0 } : images
        guard !galleryImages.isEmpty else { return }; present(ImageGalleryViewController(images: galleryImages), animated: true)
    }
    @objc private func toggleLike() { repository.toggleLike(postID: postID) }
    @objc private func toggleSave() { repository.toggleSaved(postID: postID) }
    @objc private func postComment() { let text = input.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""; guard !text.isEmpty else { showMessage("Write a comment", message: "Enter a message before posting."); return }; repository.addComment(postID: postID, text: text); input.text = "" }
    @objc private func openAuthor() { guard let author = repository.post(id: postID)?.authorID else { return }; navigationController?.pushViewController(OtherProfileViewController(userID: author), animated: true) }
    @objc private func more() {
        presentAdventureActions(postID: postID, afterDelete: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }, afterBlock: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
    }
    @objc private func close() { navigationController?.popViewController(animated: true) }
    override func repositoryDidChange() { render() }
}

final class AIAssistantViewController: BaseScrollableViewController {
    private let messages = UIStackView(); private let input = UITextField(); private let status = UILabel(); private let balance = UILabel(); private let bottomPanel = UIStackView()
    override func viewDidLoad() {
        super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); stack.spacing = 14
        stack.snp.updateConstraints { $0.bottom.equalToSuperview() }

        let header = UIStackView(); header.alignment = .center; header.spacing = 8
        let back = UIButton(type: .system); back.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21, weight: .bold)), for: .normal); back.tintColor = Palette.ink; back.addTarget(self, action: #selector(close), for: .touchUpInside); back.snp.makeConstraints { $0.width.equalTo(28); $0.height.equalTo(38) }
        let heading = titleLabel("Wanoo AI", size: 30); heading.font = AppFont.nunito(30, weight: .black, italic: true)
        header.addArrangedSubview(back); header.addArrangedSubview(heading); header.addArrangedSubview(UIView()); stack.addArrangedSubview(header)

        let hero = UIView(); hero.snp.makeConstraints { $0.height.equalTo(169) }
        status.textAlignment = .center; status.numberOfLines = 2; status.backgroundColor = Palette.lime; status.layer.cornerRadius = 17; status.layer.cornerCurve = .continuous; status.clipsToBounds = true
        hero.addSubview(status); status.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview(); $0.height.equalTo(59) }
        let mascot = UIImageView(image: UIImage(named: "FigmaAI")); mascot.contentMode = .scaleAspectFit
        hero.addSubview(mascot); mascot.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.top.equalToSuperview().offset(16); $0.width.equalTo(138); $0.height.equalTo(112) }
        stack.addArrangedSubview(hero)

        let capability = label("Route ideas, gear checks, weather & more", size: 11, color: Palette.muted); capability.textAlignment = .center; stack.addArrangedSubview(capability)
        messages.axis = .vertical; messages.spacing = 14; stack.addArrangedSubview(messages)
        let spacer = UIView(); spacer.snp.makeConstraints { $0.height.greaterThanOrEqualTo(0).priority(.low) }; stack.addArrangedSubview(spacer)

        balance.font = AppFont.nunito(11); balance.textColor = Palette.muted
        input.placeholder = "Ask Wanoo AI..."; input.font = AppFont.nunito(13); input.textColor = Palette.ink; input.backgroundColor = .white; input.layer.cornerRadius = 18; input.layer.cornerCurve = .continuous; input.returnKeyType = .send; input.addTarget(self, action: #selector(send), for: .editingDidEndOnExit); input.snp.makeConstraints { $0.height.equalTo(54) }
        let inset = UIView(); inset.snp.makeConstraints { $0.width.equalTo(16) }; input.leftView = inset; input.leftViewMode = .always
        bottomPanel.axis = .vertical; bottomPanel.spacing = 8; bottomPanel.addArrangedSubview(balance); bottomPanel.addArrangedSubview(input)
        view.addSubview(bottomPanel)
        bottomPanel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(22)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-8).priority(.high)
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
        scrollView.snp.remakeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomPanel.snp.top).offset(-8)
        }
        contentView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide) }
        render()
    }
    private func render() {
        let copy = NSMutableAttributedString(string: "\(repository.aiFreeMessages) free messages left", attributes: [.font: AppFont.nunito(14, weight: .black), .foregroundColor: Palette.ink])
        copy.append(NSAttributedString(string: "\nThen \(repository.aiMessageCost) coins per message", attributes: [.font: AppFont.nunito(10, weight: .medium), .foregroundColor: Palette.ink])); status.attributedText = copy
        let formattedBalance = NumberFormatter.localizedString(from: NSNumber(value: repository.currentUser?.coins ?? 0), number: .decimal)
        balance.text = "Balance:  🪙 \(formattedBalance) coins"
        messages.arrangedSubviews.forEach { $0.removeFromSuperview() }
        repository.aiMessages.forEach { messages.addArrangedSubview(aiMessageRow($0)) }
    }
    private func aiMessageRow(_ item: ChatMessage) -> UIView {
        let outgoing = item.senderID != "assistant"
        let row = UIView(); let bubble = UIView(); bubble.backgroundColor = outgoing ? Palette.purple : .white; bubble.layer.cornerRadius = 18; bubble.layer.cornerCurve = .continuous; bubble.clipsToBounds = true
        let copy = label(item.text, size: 13, weight: .medium, color: outgoing ? .white : Palette.ink, lines: 0); copy.setLineSpacing(1)
        bubble.addSubview(copy); copy.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)); $0.width.lessThanOrEqualTo(244) }
        row.addSubview(bubble)
        if outgoing { bubble.snp.makeConstraints { $0.trailing.top.bottom.equalToSuperview(); $0.leading.greaterThanOrEqualToSuperview().offset(48) } }
        else { bubble.snp.makeConstraints { $0.leading.top.bottom.equalToSuperview(); $0.trailing.lessThanOrEqualToSuperview().inset(66) } }
        return row
    }
    @objc private func send() { let text = input.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""; guard !text.isEmpty else { return }; let perform = { self.repository.sendAIMessage(text); self.input.text = "" }; if repository.aiFreeMessages > 0 { perform() } else { confirmSpend(amount: repository.aiMessageCost, purpose: "one AI message", completion: perform) } }
    override func repositoryDidChange() { render() }
    @objc private func close() { navigationController?.popViewController(animated: true) }
}

private final class VoicePlaybackBubble: UIControl, AVAudioPlayerDelegate {
    private let playButton = UIImageView()
    private let track = UIView()
    private let progress = UIView()
    private let durationLabel = UILabel()
    private var timer: Timer?
    private var player: AVAudioPlayer?
    private let audioURL: URL?
    private let duration: TimeInterval

    init(audioURL: URL?, duration: TimeInterval) {
        self.audioURL = audioURL; self.duration = max(duration, 0.1)
        super.init(frame: .zero)
        backgroundColor = .white; layer.cornerRadius = 19; layer.cornerCurve = .continuous
        playButton.image = UIImage(systemName: "play.fill"); playButton.tintColor = Palette.purple; playButton.contentMode = .scaleAspectFit
        track.backgroundColor = UIColor(hex: 0xDDD8EB); track.layer.cornerRadius = 2; track.clipsToBounds = true
        progress.backgroundColor = Palette.purple; track.addSubview(progress)
        durationLabel.text = Self.timeText(duration); durationLabel.font = AppFont.nunito(10, weight: .semibold); durationLabel.textColor = Palette.muted
        addSubview(playButton); addSubview(track); addSubview(durationLabel)
        playButton.snp.makeConstraints { $0.leading.equalToSuperview().offset(14); $0.centerY.equalToSuperview(); $0.width.height.equalTo(18) }
        track.snp.makeConstraints { $0.leading.equalTo(playButton.snp.trailing).offset(10); $0.centerY.equalToSuperview(); $0.width.equalTo(92); $0.height.equalTo(4) }
        progress.snp.makeConstraints { $0.leading.top.bottom.equalToSuperview(); $0.width.equalTo(0) }
        durationLabel.snp.makeConstraints { $0.leading.equalTo(track.snp.trailing).offset(8); $0.trailing.equalToSuperview().inset(12); $0.centerY.equalToSuperview() }
        addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        snp.makeConstraints { $0.width.equalTo(178); $0.height.equalTo(40) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    deinit { timer?.invalidate(); player?.stop() }
    @objc private func togglePlayback() {
        if player?.isPlaying == true { player?.pause(); stopTimer(); return }
        guard let audioURL, FileManager.default.fileExists(atPath: audioURL.path), let audioPlayer = try? AVAudioPlayer(contentsOf: audioURL) else { return }
        player = audioPlayer; audioPlayer.delegate = self; audioPlayer.prepareToPlay(); audioPlayer.play()
        playButton.image = UIImage(systemName: "pause.fill")
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let player = self.player else { return }
            let ratio = min(player.currentTime / max(player.duration, 0.1), 1)
            progress.snp.remakeConstraints { $0.leading.top.bottom.equalToSuperview(); $0.width.equalTo(92 * ratio) }
            durationLabel.text = Self.timeText(max(0, player.duration - player.currentTime))
        }
    }
    private func stopTimer() { timer?.invalidate(); timer = nil; playButton.image = UIImage(systemName: "play.fill") }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { stopTimer(); durationLabel.text = Self.timeText(duration); progress.snp.remakeConstraints { $0.leading.top.bottom.equalToSuperview(); $0.width.equalTo(0) } }
    private static func timeText(_ value: TimeInterval) -> String { String(format: "%d:%02d", Int(value) / 60, Int(ceil(value)) % 60) }
}

final class ChatViewController: BaseScrollableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    enum Kind { case room(String), direct(String) }
    private let kind: Kind
    private let startsInVoiceMode: Bool
    private let messages = UIStackView()
    private let composer = UIStackView()
    private let input = UITextField()
    private let voice = UIButton(type: .system)
    private let voiceToggle = UIButton(type: .system)
    private let albumButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
    private var audioRecorder: AVAudioRecorder?
    private var recordingFileName: String?
    private var recordingStartedAt: Date?
    private var isCountedInRoom = false
    init(kind: Kind, voiceMode: Bool = false) { self.kind = kind; self.startsInVoiceMode = voiceMode; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        stack.spacing = 10
        stack.addArrangedSubview(makeHeader())
        messages.axis = .vertical
        messages.spacing = 11
        stack.addArrangedSubview(messages)
        let flexibleSpace = UIView()
        flexibleSpace.snp.makeConstraints { $0.height.greaterThanOrEqualTo(20).priority(.low) }
        stack.addArrangedSubview(flexibleSpace)
        buildComposer()
        view.addSubview(composer)
        composer.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(18)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-8).priority(.high)
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
        scrollView.snp.remakeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(composer.snp.top).offset(-8)
        }
        contentView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide) }
        setVoiceMode(startsInVoiceMode)
        stack.snp.updateConstraints { $0.bottom.equalToSuperview() }
        render()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard case .room(let id) = kind, !isCountedInRoom else { return }
        isCountedInRoom = true
        repository.enter(roomID: id)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard case .room(let id) = kind, isCountedInRoom else { return }
        let isLeavingChat = isMovingFromParent || navigationController?.topViewController !== self
        guard isLeavingChat else { return }
        isCountedInRoom = false
        repository.leave(roomID: id)
    }
    private func makeHeader() -> UIView {
        let container = UIView()
        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21, weight: .bold)), for: .normal)
        back.tintColor = Palette.ink
        back.addTarget(self, action: #selector(close), for: .touchUpInside)
        container.addSubview(back)
        back.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.width.equalTo(26); $0.height.equalTo(42) }
        if isRoom {
            let avatar = UIImageView(image: UIImage(named: avatarAsset)); avatar.contentMode = .scaleAspectFill; avatar.clipsToBounds = true; avatar.layer.cornerRadius = 20
            container.addSubview(avatar); avatar.snp.makeConstraints { $0.leading.equalTo(back.snp.trailing).offset(7); $0.centerY.equalToSuperview(); $0.width.height.equalTo(40) }
            let title = label(displayTitle, size: 16, weight: .black)
            let status = label("\(roomOnline) online", size: 10, weight: .semibold, color: Palette.muted)
            let texts = UIStackView(arrangedSubviews: [title, status]); texts.axis = .vertical; texts.spacing = 0
            container.addSubview(texts); texts.snp.makeConstraints { $0.leading.equalTo(avatar.snp.trailing).offset(8); $0.centerY.equalToSuperview(); $0.trailing.lessThanOrEqualToSuperview().inset(42) }
        } else {
            let title = label(displayTitle, size: 30, weight: .black); title.font = AppFont.nunito(30, weight: .black, italic: true)
            container.addSubview(title); title.snp.makeConstraints { $0.leading.equalTo(back.snp.trailing).offset(7); $0.centerY.equalToSuperview(); $0.trailing.lessThanOrEqualToSuperview().inset(42) }
        }
        let more = UIButton(type: .system); more.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal); more.tintColor = Palette.ink; more.contentHorizontalAlignment = .right; more.addTarget(self, action: #selector(openChatActions), for: .touchUpInside)
        container.addSubview(more)
        more.snp.makeConstraints { $0.trailing.centerY.equalToSuperview(); $0.width.height.equalTo(44) }
        container.snp.makeConstraints { $0.height.equalTo(52) }
        return container
    }
    private func buildComposer() {
        composer.axis = .horizontal; composer.spacing = 8; composer.alignment = .center; composer.backgroundColor = .white; composer.layer.cornerRadius = 18; composer.layer.cornerCurve = .continuous
        composer.isLayoutMarginsRelativeArrangement = true; composer.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        composer.snp.makeConstraints { $0.height.equalTo(54) }
        input.placeholder = isRoom ? "Message Yosemite Room..." : "Enter..."
        input.font = AppFont.nunito(12); input.backgroundColor = .clear
        let inset = UIView(); inset.snp.makeConstraints { $0.width.equalTo(isRoom ? 6 : 0) }; input.leftView = inset; input.leftViewMode = .always
        input.returnKeyType = .send; input.addTarget(self, action: #selector(send), for: .editingDidEndOnExit)
        if isRoom { composer.addArrangedSubview(input); return }
        voiceToggle.setImage(UIImage(named: "Figma-283-4185-2-png1-9ce9b998")?.withRenderingMode(.alwaysTemplate), for: .normal); voiceToggle.tintColor = Palette.ink
        voiceToggle.addTarget(self, action: #selector(toggleVoiceMode), for: .touchUpInside)
        voiceToggle.snp.makeConstraints { $0.width.height.equalTo(28) }
        voiceToggle.imageView?.snp.makeConstraints { $0.width.height.equalTo(19); $0.center.equalToSuperview() }
        composer.addArrangedSubview(voiceToggle)
        composer.addArrangedSubview(input)
        albumButton.setImage(UIImage(named: "Figma-283-4185-2-png3-x1-87198a03")?.withRenderingMode(.alwaysTemplate), for: .normal); albumButton.tintColor = Palette.ink; albumButton.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside); albumButton.snp.makeConstraints { $0.width.equalTo(28) }; albumButton.imageView?.snp.makeConstraints { $0.width.height.equalTo(20); $0.center.equalToSuperview() }; composer.addArrangedSubview(albumButton)
        sendButton.setImage(UIImage(named: "Figma-283-4185-21-c02b4e86")?.withRenderingMode(.alwaysTemplate), for: .normal); sendButton.tintColor = Palette.ink; sendButton.addTarget(self, action: #selector(send), for: .touchUpInside); sendButton.snp.makeConstraints { $0.width.equalTo(28) }; sendButton.imageView?.snp.makeConstraints { $0.width.height.equalTo(21); $0.center.equalToSuperview() }
        composer.addArrangedSubview(sendButton)
        voice.setTitle("Hold to Talk", for: .normal); voice.tintColor = .white; voice.titleLabel?.font = AppFont.nunito(20, weight: .bold)
        voice.setTitleColor(.white, for: .normal); voice.backgroundColor = Palette.purple; voice.layer.cornerRadius = 10
        voice.addTarget(self, action: #selector(voiceDown), for: .touchDown); voice.addTarget(self, action: #selector(voiceUp), for: .touchUpInside); voice.addTarget(self, action: #selector(cancelVoice), for: [.touchDragExit, .touchUpOutside])
        voice.layer.cornerRadius = 18; voice.layer.cornerCurve = .continuous
        voice.snp.makeConstraints { $0.height.equalTo(54) }
        let voiceIcon = UIImageView(image: UIImage(named: "Figma-283-4245-12011-138eb033")?.withRenderingMode(.alwaysTemplate)); voiceIcon.tintColor = .white; voiceIcon.contentMode = .scaleAspectFit; voice.addSubview(voiceIcon); voiceIcon.snp.makeConstraints { $0.leading.equalToSuperview().offset(26); $0.centerY.equalToSuperview(); $0.width.height.equalTo(18) }
    }
    private func render() {
        // Repository changes are delivered while controls, the keyboard or a picker may
        // still own an animation transaction. Rebuilding a UIStackView in that transaction
        // makes every message (especially a tall image) visibly slide into place.
        // Keep chat updates deliberately immediate.
        let oldAnimationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        messages.arrangedSubviews.forEach {
            messages.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let values: [ChatMessage]
        switch kind { case .room(let id): values = repository.visibleRooms.first(where: { $0.id == id })?.messages ?? []; case .direct(let id): values = repository.visibleConversations.first(where: { $0.peerID == id })?.messages.filter { !repository.blocked.contains($0.senderID) } ?? [] }
        if values.isEmpty {
            messages.addArrangedSubview(EmptyStateView(text: "Start the conversation."))
        } else {
            values.forEach { item in
                let outgoing = item.senderID == repository.currentUserID
                if item.isVoice { messages.addArrangedSubview(voiceMessageRow(item: item, outgoing: outgoing, senderID: item.senderID)) }
                else if item.text.hasPrefix("local-image:") { messages.addArrangedSubview(imageMessageRow(fileName: String(item.text.dropFirst("local-image:".count)), outgoing: outgoing, senderID: item.senderID, timestamp: item.timestamp)) }
                else { messages.addArrangedSubview(chatRow(senderID: item.senderID, text: item.text, outgoing: outgoing, timestamp: item.timestamp)) }
            }
        }
        view.layoutIfNeeded()
        let bottomY = max(-scrollView.adjustedContentInset.top, scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom)
        scrollView.setContentOffset(CGPoint(x: 0, y: bottomY), animated: false)
        CATransaction.commit()
        UIView.setAnimationsEnabled(oldAnimationsEnabled)
    }
    private func chatRow(senderID: String?, text: String, outgoing: Bool, timestamp: Date = Date()) -> UIView {
        let row = UIView(); let bubble = UILabel(); bubble.text = "   " + text + "   "; bubble.numberOfLines = 0; bubble.font = AppFont.nunito(13, weight: .medium); bubble.layer.cornerRadius = 19; bubble.layer.cornerCurve = .continuous; bubble.clipsToBounds = true
        bubble.backgroundColor = outgoing ? Palette.purple : .white; bubble.textColor = outgoing ? .white : Palette.ink
        row.addSubview(bubble)
        if outgoing { bubble.snp.makeConstraints { $0.trailing.top.bottom.equalToSuperview(); $0.leading.greaterThanOrEqualToSuperview().offset(80); $0.height.equalTo(42) } }
        else {
            let avatar = UIImageView(image: UserAvatarStore.image(userID: senderID) ?? UIImage(named: avatarAsset)); avatar.contentMode = .scaleAspectFill; avatar.clipsToBounds = true; avatar.layer.cornerRadius = 13; row.addSubview(avatar)
            avatar.layer.cornerRadius = 27; avatar.snp.makeConstraints { $0.leading.top.equalToSuperview(); $0.width.height.equalTo(54) }
            let senderName = senderID.flatMap(repository.user(id:))?.name ?? "Explorer"; let sender = label("\(senderName) · \(timestamp.formatted(date: .omitted, time: .shortened))", size: 10, weight: .bold)
            row.addSubview(sender); sender.snp.makeConstraints { $0.leading.equalTo(avatar.snp.trailing).offset(13); $0.top.equalToSuperview() }
            bubble.snp.makeConstraints { $0.leading.equalTo(sender); $0.top.equalTo(sender.snp.bottom).offset(7); $0.trailing.lessThanOrEqualToSuperview(); $0.bottom.equalToSuperview(); $0.height.equalTo(41) }
        }
        return row
    }
    private func voiceMessageRow(item: ChatMessage, outgoing: Bool, senderID: String?) -> UIView {
        let audioURL = item.audioFileName.map { mediaURL(fileName: $0) }
        let row = UIView(); let bubble = VoicePlaybackBubble(audioURL: audioURL, duration: item.voiceDuration ?? 0); row.addSubview(bubble)
        if outgoing { bubble.backgroundColor = Palette.purple.withAlphaComponent(0.14); bubble.snp.makeConstraints { $0.trailing.top.bottom.equalToSuperview() } }
        else {
            let avatar = UIImageView(image: UserAvatarStore.image(userID: senderID) ?? UIImage(named: avatarAsset)); avatar.contentMode = .scaleAspectFill; avatar.clipsToBounds = true; avatar.layer.cornerRadius = 27; row.addSubview(avatar); avatar.snp.makeConstraints { $0.leading.top.equalToSuperview(); $0.width.height.equalTo(54) }
            bubble.snp.makeConstraints { $0.leading.equalTo(avatar.snp.trailing).offset(13); $0.top.bottom.equalToSuperview() }
        }
        return row
    }
    private func imageMessageRow(fileName: String, outgoing: Bool, senderID: String?, timestamp: Date) -> UIView {
        let row = UIView(); let image = UIImageView(image: UIImage(contentsOfFile: mediaURL(fileName: fileName).path)); image.backgroundColor = UIColor(hex: 0xECEBE8); image.contentMode = .scaleAspectFill; image.clipsToBounds = true; image.layer.cornerRadius = 18; image.layer.cornerCurve = .continuous; row.addSubview(image)
        if outgoing { image.snp.makeConstraints { $0.trailing.top.bottom.equalToSuperview(); $0.width.equalTo(146); $0.height.equalTo(197) } }
        else { let avatar = UIImageView(image: UserAvatarStore.image(userID: senderID) ?? UIImage(named: avatarAsset)); avatar.contentMode = .scaleAspectFill; avatar.clipsToBounds = true; avatar.layer.cornerRadius = 27; row.addSubview(avatar); avatar.snp.makeConstraints { $0.leading.top.equalToSuperview(); $0.width.height.equalTo(54) }; let name = senderID.flatMap(repository.user(id:))?.name ?? "Explorer"; let sender = label("\(name) · \(timestamp.formatted(date: .omitted, time: .shortened))", size: 10, weight: .bold); row.addSubview(sender); sender.snp.makeConstraints { $0.leading.equalTo(avatar.snp.trailing).offset(13); $0.top.equalToSuperview() }; image.snp.makeConstraints { $0.leading.equalTo(sender); $0.top.equalTo(sender.snp.bottom).offset(8); $0.bottom.equalToSuperview(); $0.width.equalTo(146); $0.height.equalTo(197) } }
        return row
    }
    private var isRoom: Bool { if case .room = kind { return true }; return false }
    private var peerID: String? { if case .direct(let id) = kind { return id }; return repository.rooms.first(where: { room in if case .room(let id) = kind { return room.id == id }; return false })?.messages.first?.senderID }
    private var displayTitle: String { switch kind { case .room(let id): return repository.rooms.first(where: { $0.id == id })?.name ?? "Chatroom"; case .direct(let id): return repository.user(id: id)?.name ?? "Explorer" } }
    private var roomOnline: Int { if case .room(let id) = kind { return repository.rooms.first(where: { $0.id == id })?.online ?? 128 }; return 0 }
    private var avatarAsset: String { isRoom ? "Figma-283-3828-ellipse31-47dd20a3" : "Figma-283-3828-ellipse36-6d7f936e" }
    private func setVoiceMode(_ enabled: Bool) {
        guard !isRoom else { return }
        if enabled {
            input.removeFromSuperview(); voiceToggle.isHidden = true; albumButton.isHidden = true; sendButton.isHidden = true
            composer.backgroundColor = .clear; composer.layoutMargins = .zero; composer.addArrangedSubview(voice)
        } else {
            voice.removeFromSuperview(); voiceToggle.isHidden = false; albumButton.isHidden = false; sendButton.isHidden = false
            composer.backgroundColor = .white; composer.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            if input.superview == nil { composer.insertArrangedSubview(input, at: 1) }
        }
    }
    @objc private func toggleVoiceMode() { setVoiceMode(voice.superview == nil) }
    @objc private func openChatActions() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        switch kind {
        case .direct(let userID):
            sheet.addAction(UIAlertAction(title: "Report", style: .default) { [weak self] _ in
                self?.navigationController?.pushViewController(ReportViewController(targetID: userID), animated: true)
            })
            sheet.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
                guard let self else { return }
                self.present(WanooAlertController(
                    titleText: "Block User",
                    messageText: "Block \(self.repository.user(id: userID)?.name ?? "this user")? Their posts, comments, and conversations will no longer be shown.",
                    secondaryTitle: "Cancel",
                    primaryTitle: "Block",
                    primaryAction: {
                        self.repository.block(userID: userID)
                        self.navigationController?.popViewController(animated: true)
                    }
                ), animated: true)
            })
        case .room(let roomID):
            sheet.addAction(UIAlertAction(title: "Report", style: .default) { [weak self] _ in
                self?.navigationController?.pushViewController(ReportViewController(targetID: roomID), animated: true)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    @objc private func send() { let text = input.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""; guard !text.isEmpty else { return }; switch kind { case .room(let id): repository.sendRoomMessage(roomID: id, text: text); case .direct(let id): repository.sendDirectMessage(peerID: id, text: text) }; input.text = "" }
    @objc private func selectPhoto() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images; configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration); picker.delegate = self
        present(picker, animated: true)
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage, let data = image.jpegData(compressionQuality: 0.86) else { return }
            let fileName = UUID().uuidString + ".jpg"; let url = self.mediaURL(fileName: fileName)
            do {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
                try data.write(to: url, options: .atomic)
                DispatchQueue.main.async { let payload = "local-image:" + fileName; switch self.kind { case .room(let id): self.repository.sendRoomMessage(roomID: id, text: payload); case .direct(let id): self.repository.sendDirectMessage(peerID: id, text: payload) } }
            } catch { DispatchQueue.main.async { self.showMessage("Unable to send image", message: "The selected photo could not be prepared for sending.") } }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage, let data = image.jpegData(compressionQuality: 0.86) else { picker.dismiss(animated: true); return }
        let fileName = UUID().uuidString + ".jpg"; let url = mediaURL(fileName: fileName)
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
            let payload = "local-image:" + fileName
            switch kind { case .room(let id): repository.sendRoomMessage(roomID: id, text: payload); case .direct(let id): repository.sendDirectMessage(peerID: id, text: payload) }
        } catch { showMessage("Unable to send image", message: "The selected photo could not be prepared for sending.") }
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }
    private func mediaURL(fileName: String) -> URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return root.appendingPathComponent("WanooChatMedia", isDirectory: true).appendingPathComponent(fileName)
    }
    @objc private func voiceDown() {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in DispatchQueue.main.async { if allowed { self.startRecording() } else { self.showMessage("Microphone access needed", message: "Allow microphone access in Settings to send voice messages.") } } }
    }
    private func startRecording() {
        let fileName = UUID().uuidString + ".m4a"; let url = mediaURL(fileName: fileName)
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let session = AVAudioSession.sharedInstance(); try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker]); try session.setActive(true)
            let settings: [String: Any] = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44_100.0, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            let recorder = try AVAudioRecorder(url: url, settings: settings); recorder.prepareToRecord(); recorder.record()
            audioRecorder = recorder; recordingFileName = fileName; recordingStartedAt = Date(); voice.setTitle("Release to Send", for: .normal)
        } catch { showMessage("Unable to record", message: "The audio recording could not be started.") }
    }
    @objc private func voiceUp() {
        guard let recorder = audioRecorder, recorder.isRecording, let fileName = recordingFileName else { return }
        recorder.stop(); audioRecorder = nil
        let duration = max(recordingStartedAt.map { Date().timeIntervalSince($0) } ?? 0, 0)
        voice.setTitle("Hold to Talk", for: .normal); recordingFileName = nil; recordingStartedAt = nil
        guard duration >= 0.5 else { try? FileManager.default.removeItem(at: mediaURL(fileName: fileName)); showMessage("Recording too short", message: "Hold the button a little longer and try again."); return }
        let text = "Voice message · \(Int(ceil(duration)))s"
        switch kind { case .direct(let id): repository.sendDirectMessage(peerID: id, text: text, isVoice: true, audioFileName: fileName, voiceDuration: duration); case .room(let id): repository.sendRoomMessage(roomID: id, text: text, isVoice: true, audioFileName: fileName, voiceDuration: duration) }
        if !startsInVoiceMode { setVoiceMode(false) }
    }
    @objc private func cancelVoice() {
        audioRecorder?.stop(); audioRecorder = nil
        if let fileName = recordingFileName { try? FileManager.default.removeItem(at: mediaURL(fileName: fileName)) }
        recordingFileName = nil; recordingStartedAt = nil; voice.setTitle("Hold to Talk", for: .normal)
        if !startsInVoiceMode { setVoiceMode(false) }; showMessage("Recording cancelled", message: "Hold the button to try again.")
    }
    @objc private func close() { navigationController?.popViewController(animated: true) }
    override func repositoryDidChange() { render() }
}

final class TopicViewController: BaseScrollableViewController {
    private let topic: String
    init(topic: String) { self.topic = topic; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() { super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); build() }
    private func build() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }; stack.spacing = 10
        let nav = UIView(); nav.snp.makeConstraints { $0.height.equalTo(26) }
        let back = UIButton(type: .system); back.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21, weight: .bold)), for: .normal); back.tintColor = Palette.ink; back.addTarget(self, action: #selector(close), for: .touchUpInside)
        nav.addSubview(back); back.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.width.height.equalTo(26) }
        stack.addArrangedSubview(nav)
        let heading = titleLabel(topic, size: 30); heading.font = AppFont.nunito(30, weight: .black, italic: true); stack.addArrangedSubview(heading)
        let posts = repository.visiblePosts.filter { topic == "All" || $0.category == topic || $0.location.localizedCaseInsensitiveContains(topic) }
        let count = label("  \(posts.count) adventure\(posts.count == 1 ? "" : "s")  ", size: 10, weight: .black); count.backgroundColor = Palette.lime; count.textAlignment = .center; count.layer.cornerRadius = 13; count.clipsToBounds = true; count.snp.makeConstraints { $0.height.equalTo(26) }; let countRow = UIStackView(arrangedSubviews: [count, UIView()]); stack.addArrangedSubview(countRow)
        if posts.isEmpty { stack.addArrangedSubview(EmptyStateView(text: "No adventures in this topic yet.")) }
        else { posts.forEach { post in
            let value = AdventureFeedCardView(post: post, author: repository.user(id: post.authorID))
            value.onOpen = { [weak self] in self?.requireLogin { self?.navigationController?.pushViewController(PostDetailViewController(postID: post.id), animated: true) } }
            value.onComment = value.onOpen
            value.onLike = { [weak self] in self?.requireLogin { self?.repository.toggleLike(postID: post.id) } }
            stack.addArrangedSubview(value)
        } }
    }
    @objc private func close() { navigationController?.popViewController(animated: true) }
    @objc private func noop() {}
    override func repositoryDidChange() { build() }
}

final class OtherProfileViewController: BaseScrollableViewController {
    private let userID: String; private let follow = UIButton(type: .system)
    init(userID: String) { self.userID = userID; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() { super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); follow.addTarget(self, action: #selector(toggleFollow), for: .touchUpInside); build() }
    private func build() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }; stack.spacing = 9
        guard let user = repository.user(id: userID) else { stack.addArrangedSubview(EmptyStateView(text: "This explorer is unavailable.")); return }
        let nav = UIView(); let back = UIButton(type: .system); back.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21, weight: .bold)), for: .normal); back.tintColor = Palette.ink; back.contentHorizontalAlignment = .leading; back.addTarget(self, action: #selector(close), for: .touchUpInside); nav.addSubview(back); back.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.width.height.equalTo(34) }; let moreButton = UIButton(type: .system); moreButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal); moreButton.tintColor = Palette.ink; moreButton.addTarget(self, action: #selector(more), for: .touchUpInside); nav.addSubview(moreButton); moreButton.snp.makeConstraints { $0.trailing.centerY.equalToSuperview(); $0.width.height.equalTo(34) }; nav.snp.makeConstraints { $0.height.equalTo(34) }; stack.addArrangedSubview(nav)
        let avatar = UIImageView(image: UserAvatarStore.image(userID: user.id) ?? UIImage(named: "Figma-283-4002-avatar-bc770f60")); avatar.contentMode = .scaleAspectFill; avatar.clipsToBounds = true; avatar.layer.cornerRadius = 60; avatar.snp.makeConstraints { $0.width.height.equalTo(120) }; let avatarRow = UIStackView(arrangedSubviews: [UIView(), avatar, UIView()]); avatarRow.distribution = .equalCentering; stack.addArrangedSubview(avatarRow)
        let name = titleLabel(user.name, size: 20); name.textAlignment = .center; stack.addArrangedSubview(name)
        let bio = label(user.bio, size: 12, color: Palette.muted, lines: 2); bio.textAlignment = .center; stack.addArrangedSubview(bio)
        let counts = UIStackView(); counts.distribution = .fillEqually; [("Followers", user.followers.count), ("Following", user.following.count)].forEach { item in let column = UIStackView(); column.axis = .vertical; column.alignment = .center; column.spacing = 1; let number = label(String(item.1), size: 18, weight: .black); let caption = label(item.0, size: 11, color: Palette.muted); column.addArrangedSubview(number); column.addArrangedSubview(caption); counts.addArrangedSubview(column) }; stack.addArrangedSubview(counts)
        if repository.currentUserID != userID {
            let actions = UIStackView(); actions.spacing = 10; actions.distribution = .fillEqually; styleFollow(); actions.addArrangedSubview(follow); let messageButton = button("Message", primary: false, action: #selector(message)); messageButton.setTitleColor(Palette.ink, for: .normal); actions.addArrangedSubview(messageButton); actions.snp.makeConstraints { $0.height.equalTo(48) }; stack.addArrangedSubview(actions)
        }
        let posts = repository.visiblePosts.filter { $0.authorID == userID }; if posts.isEmpty { stack.addArrangedSubview(EmptyStateView(text: "No adventures yet.")) }
        posts.forEach { post in
            let card = AdventureFeedCardView(post: post, author: repository.user(id: post.authorID))
            card.onOpen = { [weak self] in self?.navigationController?.pushViewController(PostDetailViewController(postID: post.id), animated: true) }
            card.onComment = card.onOpen
            card.onLike = { [weak self] in self?.requireLogin { self?.repository.toggleLike(postID: post.id) } }
            stack.addArrangedSubview(card)
        }
    }
    private func styleFollow() { let isFollowing = repository.currentUser?.following.contains(userID) == true; follow.setTitle(isFollowing ? "Following" : "Follow", for: .normal); follow.titleLabel?.font = AppFont.nunito(14, weight: .black); follow.backgroundColor = isFollowing ? Palette.purple : Palette.lime; follow.setTitleColor(isFollowing ? .white : Palette.ink, for: .normal); follow.layer.cornerRadius = 14 }
    @objc private func toggleFollow() { guard repository.currentUserID != userID else { return }; requireLogin { self.repository.toggleFollow(userID: self.userID) } }
    @objc private func message() { guard repository.isMutual(userID: userID) else { showMessage("Messages locked", message: "Follow each other to unlock messages."); return }; navigationController?.pushViewController(ChatViewController(kind: .direct(userID)), animated: true) }
    @objc private func more() { let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet); sheet.addAction(UIAlertAction(title: "Report", style: .default) { _ in self.navigationController?.pushViewController(ReportViewController(targetID: self.userID), animated: true) }); sheet.addAction(UIAlertAction(title: "Block", style: .destructive) { _ in self.repository.block(userID: self.userID); self.navigationController?.popViewController(animated: true) }); sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel)); present(sheet, animated: true) }
    @objc private func close() { navigationController?.popViewController(animated: true) }
    @objc private func noop() {}
    override func repositoryDidChange() { build() }
}

final class PublishViewController: BaseScrollableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate, UITextViewDelegate {
    private let locationField = UITextField()
    private let highlightsField = UITextField()
    private let story = UITextView()
    private let storyPlaceholder = UILabel()
    private let mediaScroll = UIScrollView()
    private let mediaRow = UIStackView()
    private var selectedMediaRecords: [String] = []
    private var selectedCategory = "Hiking"
    private var selectedDuration = "One Day"

    override func viewDidLoad() {
        super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); stack.spacing = 10
        let close = UIButton(type: .system); close.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)), for: .normal); close.tintColor = Palette.ink; close.contentHorizontalAlignment = .left; close.addTarget(self, action: #selector(closePage), for: .touchUpInside); close.snp.makeConstraints { $0.height.equalTo(30) }; stack.addArrangedSubview(close)
        mediaScroll.showsHorizontalScrollIndicator = false
        mediaRow.spacing = 10
        mediaRow.alignment = .center
        mediaScroll.addSubview(mediaRow)
        mediaRow.snp.makeConstraints { $0.edges.equalTo(mediaScroll.contentLayoutGuide); $0.height.equalTo(mediaScroll.frameLayoutGuide) }
        mediaScroll.snp.makeConstraints { $0.height.equalTo(164) }
        stack.addArrangedSubview(mediaScroll)
        renderMedia()
        stack.addArrangedSubview(label("Adventure type", size: 12, weight: .semibold)); stack.addArrangedSubview(chipRow(values: repository.explorationTypes, selected: selectedCategory, action: #selector(selectCategory(_:))))
        stack.addArrangedSubview(label("Location", size: 12, weight: .semibold)); styleField(locationField, placeholder: "Add location..."); stack.addArrangedSubview(locationField)
        stack.addArrangedSubview(label("Duration", size: 12, weight: .semibold)); stack.addArrangedSubview(chipRow(values: repository.durations, selected: selectedDuration, action: #selector(selectDuration(_:))))
        stack.addArrangedSubview(label("Highlights", size: 12, weight: .semibold)); styleField(highlightsField, placeholder: "What stood out the most?"); stack.addArrangedSubview(highlightsField)
        stack.addArrangedSubview(label("Story", size: 12, weight: .semibold))
        story.backgroundColor = .white
        story.layer.cornerRadius = 16
        story.font = AppFont.inter(12)
        story.textColor = Palette.ink
        story.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        story.delegate = self
        storyPlaceholder.text = "Describe your experience here..."
        storyPlaceholder.font = AppFont.inter(12)
        storyPlaceholder.textColor = Palette.muted
        storyPlaceholder.isUserInteractionEnabled = false
        story.addSubview(storyPlaceholder)
        storyPlaceholder.snp.makeConstraints { $0.top.equalToSuperview().offset(12); $0.leading.equalToSuperview().offset(15); $0.trailing.lessThanOrEqualToSuperview().inset(12) }
        story.snp.makeConstraints { $0.height.equalTo(76) }
        stack.addArrangedSubview(story)
        let passport = coinActionButton(title: "Adventure Passport", coins: 5, action: #selector(openPassport)); stack.addArrangedSubview(passport)
        stack.addArrangedSubview(button("Publish", action: #selector(publish)))
    }
    private func styleField(_ field: UITextField, placeholder: String) { field.placeholder = placeholder; field.backgroundColor = .white; field.layer.cornerRadius = 14; field.font = AppFont.inter(12); let inset = UIView(); inset.snp.makeConstraints { $0.width.equalTo(14) }; field.leftView = inset; field.leftViewMode = .always; field.snp.makeConstraints { $0.height.equalTo(46) } }
    private func chipRow(values: [String], selected: String, action: Selector) -> UIView { let scroll = UIScrollView(); scroll.showsHorizontalScrollIndicator = false; let row = UIStackView(); row.spacing = 8; scroll.addSubview(row); row.snp.makeConstraints { $0.edges.equalTo(scroll.contentLayoutGuide); $0.height.equalTo(scroll.frameLayoutGuide) }; values.forEach { name in let chip = ChipButton(title: name); chip.accessibilityIdentifier = name; chip.isSelected = name == selected; chip.addTarget(self, action: action, for: .touchUpInside); row.addArrangedSubview(chip) }; scroll.snp.makeConstraints { $0.height.equalTo(30) }; return scroll }
    @objc private func selectCategory(_ sender: UIButton) { selectedCategory = sender.accessibilityIdentifier ?? selectedCategory; updateChipSelection(sender, value: selectedCategory) }
    @objc private func selectDuration(_ sender: UIButton) { selectedDuration = sender.accessibilityIdentifier ?? selectedDuration; updateChipSelection(sender, value: selectedDuration) }
    private func updateChipSelection(_ sender: UIButton, value: String) { (sender.superview as? UIStackView)?.arrangedSubviews.compactMap { $0 as? ChipButton }.forEach { $0.isSelected = $0.accessibilityIdentifier == value } }
    @objc private func closePage() { navigationController?.popViewController(animated: true) }

    func textViewDidChange(_ textView: UITextView) {
        if textView === story { storyPlaceholder.isHidden = !textView.text.isEmpty }
    }

    @objc private func addMedia() {
        let sheet = UIAlertController(title: "Add photos or video", message: nil, preferredStyle: .actionSheet)
        if !selectedMediaRecords.contains(where: { $0.hasPrefix("video|") }) && selectedMediaRecords.count < 9 {
            sheet.addAction(UIAlertAction(title: "Choose photos (up to 9)", style: .default) { _ in self.choosePhotos() })
        }
        if selectedMediaRecords.isEmpty {
            sheet.addAction(UIAlertAction(title: "Choose one video", style: .default) { _ in self.chooseVideo() })
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) && !selectedMediaRecords.contains(where: { $0.hasPrefix("video|") }) && selectedMediaRecords.count < 9 {
            sheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in self.openCamera() })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func choosePhotos() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = max(1, 9 - selectedMediaRecords.count)
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func chooseVideo() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .videos
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [UTType.image.identifier]
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }
        let group = DispatchGroup()
        let lock = NSLock()
        var imported = Array<String?>(repeating: nil, count: results.count)
        results.enumerated().forEach { index, result in
            let provider = result.itemProvider
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                group.enter()
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                    defer { group.leave() }
                    guard let url, let record = self.persistVideo(from: url) else { return }
                    lock.lock(); imported[index] = record; lock.unlock()
                }
            } else if provider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    defer { group.leave() }
                    guard let image = object as? UIImage, let record = self.persistImage(image) else { return }
                    lock.lock(); imported[index] = record; lock.unlock()
                }
            }
        }
        group.notify(queue: .main) {
            let orderedRecords = imported.compactMap { $0 }
            if orderedRecords.contains(where: { $0.hasPrefix("video|") }) { self.selectedMediaRecords = Array(orderedRecords.filter { $0.hasPrefix("video|") }.prefix(1)) }
            else { self.selectedMediaRecords.append(contentsOf: orderedRecords.prefix(max(0, 9 - self.selectedMediaRecords.count))) }
            self.renderMedia()
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage, selectedMediaRecords.count < 9, let record = persistImage(image) { selectedMediaRecords.append(record); renderMedia() }
        picker.dismiss(animated: true)
    }

    private var mediaFolder: URL { let value = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("WanooPostMedia", isDirectory: true); try? FileManager.default.createDirectory(at: value, withIntermediateDirectories: true); return value }
    private func persistImage(_ image: UIImage) -> String? { guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }; let target = mediaFolder.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg"); guard (try? data.write(to: target, options: .atomic)) != nil else { return nil }; return "image|" + target.path }
    private func persistVideo(from source: URL) -> String? { let target = mediaFolder.appendingPathComponent(UUID().uuidString).appendingPathExtension(source.pathExtension.isEmpty ? "mov" : source.pathExtension); guard (try? FileManager.default.copyItem(at: source, to: target)) != nil else { return nil }; return "video|" + target.path }

    private func renderMedia() {
        mediaRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        selectedMediaRecords.enumerated().forEach { index, record in mediaRow.addArrangedSubview(mediaCell(record: record, index: index)) }
        if selectedMediaRecords.isEmpty || (!selectedMediaRecords.contains(where: { $0.hasPrefix("video|") }) && selectedMediaRecords.count < 9) {
            let add = addMediaCell()
            mediaRow.addArrangedSubview(add)
            // The button must enter the scroll-view hierarchy before it can be
            // constrained to the scroll view's layout guide.
            if selectedMediaRecords.isEmpty {
                add.snp.makeConstraints { $0.width.equalTo(mediaScroll.frameLayoutGuide) }
            }
        }
    }

    private func mediaCell(record: String, index: Int) -> UIView {
        let cell = UIControl(); cell.tag = index; cell.layer.cornerRadius = 16; cell.clipsToBounds = true; cell.snp.makeConstraints { $0.width.equalTo(116) }
        let image = UIImageView(image: PostMediaStore.previewImage(for: record)); image.contentMode = .scaleAspectFill; cell.addSubview(image); image.snp.makeConstraints { $0.edges.equalToSuperview() }
        if record.hasPrefix("video|") { let play = UIImageView(image: UIImage(systemName: "play.circle.fill")); play.tintColor = .white; cell.addSubview(play); play.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(34) } }
        let delete = UIButton(type: .system); delete.tag = index; delete.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal); delete.tintColor = .white; delete.backgroundColor = UIColor.black.withAlphaComponent(0.65); delete.layer.cornerRadius = 13; delete.addTarget(self, action: #selector(deleteMedia(_:)), for: .touchUpInside); cell.addSubview(delete); delete.snp.makeConstraints { $0.top.trailing.equalToSuperview().inset(6); $0.width.height.equalTo(26) }
        cell.addAction(UIAction { [weak self] _ in guard let self, self.selectedMediaRecords.indices.contains(index) else { return }; PostMediaStore.present(record: self.selectedMediaRecords[index], allRecords: self.selectedMediaRecords, from: self) }, for: .touchUpInside)
        return cell
    }

    private func addMediaCell() -> UIButton {
        if selectedMediaRecords.isEmpty {
            let add = DashedMediaButton(type: .system)
            add.layer.cornerRadius = 20
            let icon = UIImageView(image: UIImage(named: "Figma-285-4316-11-dc903043"))
            icon.contentMode = .scaleAspectFit
            icon.isUserInteractionEnabled = false
            add.addSubview(icon)
            icon.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.top.equalToSuperview().offset(26); $0.width.height.equalTo(62) }
            let title = UILabel()
            title.text = "Add photos or video"
            title.textAlignment = .center
            title.textColor = .white
            title.backgroundColor = Palette.purple
            title.layer.cornerRadius = 15
            title.clipsToBounds = true
            title.font = AppFont.nunito(12, weight: .bold)
            title.isUserInteractionEnabled = false
            add.addSubview(title)
            title.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.top.equalTo(icon.snp.bottom).offset(8); $0.width.equalTo(154); $0.height.equalTo(30) }
            add.addTarget(self, action: #selector(addMedia), for: .touchUpInside)
            add.snp.makeConstraints { $0.height.equalTo(164) }
            return add
        }
        let add = UIButton(type: .system)
        add.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)), for: .normal)
        add.tintColor = Palette.purple
        add.backgroundColor = .white
        add.layer.cornerRadius = 16
        add.layer.borderWidth = 1.5
        add.layer.borderColor = Palette.purple.cgColor
        add.addTarget(self, action: #selector(addMedia), for: .touchUpInside)
        add.snp.makeConstraints { $0.width.height.equalTo(116) }
        return add
    }

    @objc private func deleteMedia(_ sender: UIButton) { guard selectedMediaRecords.indices.contains(sender.tag) else { return }; let record = selectedMediaRecords.remove(at: sender.tag); try? FileManager.default.removeItem(atPath: String(record.dropFirst(6))); renderMedia() }

    private func formValues() -> (title: String, story: String)? { let title = highlightsField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""; let text = story.text.trimmingCharacters(in: .whitespacesAndNewlines); guard !selectedMediaRecords.isEmpty, !title.isEmpty, !text.isEmpty else { showMessage("Complete your adventure", message: "Add media, highlights, and your story before publishing."); return nil }; return (title, text) }
    private func createPost(values: (title: String, story: String)) -> String? { repository.publish(category: selectedCategory, title: values.title, location: locationField.text ?? "", story: values.story, duration: selectedDuration, highlights: values.title, mediaRecords: selectedMediaRecords) }
    @objc private func openPassport() {
        guard let values = formValues() else { return }
        let draft = PassportDraft(category: selectedCategory, title: values.title, location: locationField.text ?? "", story: values.story, duration: selectedDuration, mediaRecords: selectedMediaRecords)
        navigationController?.pushViewController(PassportViewController(draft: draft), animated: true)
    }
    @objc private func publish() { guard let values = formValues(), createPost(values: values) != nil else { return }; navigationController?.popViewController(animated: true) }

    private func coinActionButton(title: String, coins: Int, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = Palette.purple
        button.layer.cornerRadius = 17
        button.addTarget(self, action: action, for: .touchUpInside)
        button.snp.makeConstraints { $0.height.equalTo(48) }
        let titleLabel = label(title, size: 15, weight: .black, color: .white)
        let coin = UIImageView(image: UIImage(named: "coin")); coin.contentMode = .scaleAspectFit
        let amount = label("\(coins) Coins", size: 13, weight: .black, color: Palette.ink)
        let badge = UIStackView(arrangedSubviews: [coin, amount]); badge.spacing = 4; badge.alignment = .center; badge.backgroundColor = Palette.lime; badge.layer.cornerRadius = 9; badge.clipsToBounds = true; badge.isLayoutMarginsRelativeArrangement = true; badge.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        coin.snp.makeConstraints { $0.width.height.equalTo(16) }
        button.addSubview(titleLabel); button.addSubview(badge)
        titleLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        badge.snp.makeConstraints { $0.trailing.equalToSuperview().inset(4); $0.centerY.equalToSuperview() }
        return button
    }
}

fileprivate struct PassportDraft {
    let category: String
    let title: String
    let location: String
    let story: String
    let duration: String
    let mediaRecords: [String]
}

final class PassportViewController: BaseScrollableViewController {
    private var postID: String?
    private let draft: PassportDraft?
    private var selected: String
    private let preview = UIView()
    private let choices = UIStackView()
    private let saveButton = UIButton(type: .system)
    init(postID: String, selectedTemplate: String = "Parks") { self.postID = postID; self.draft = nil; self.selected = selectedTemplate; super.init(nibName: nil, bundle: nil) }
    fileprivate init(draft: PassportDraft, selectedTemplate: String = "Parks") { self.postID = nil; self.draft = draft; self.selected = selectedTemplate; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); stack.spacing = 8
        scrollView.contentInset.bottom = 80
        scrollView.verticalScrollIndicatorInsets.bottom = 80
        let header = UIStackView(); header.alignment = .center; header.spacing = 6
        let back = UIButton(type: .system); back.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal); back.tintColor = Palette.ink; back.contentHorizontalAlignment = .leading; back.addTarget(self, action: #selector(close), for: .touchUpInside); back.snp.makeConstraints { $0.width.equalTo(27); $0.height.equalTo(38) }
        let heading = titleLabel("Adventure Passport", size: 29); heading.font = AppFont.nunito(29, weight: .black, italic: true); header.addArrangedSubview(back); header.addArrangedSubview(heading); header.addArrangedSubview(UIView()); stack.addArrangedSubview(header)
        stack.addArrangedSubview(label("Adventure type", size: 13, weight: .bold))
        let selectorCard = UIView(); selectorCard.backgroundColor = .white; selectorCard.layer.cornerRadius = 18
        choices.spacing = 5; choices.distribution = .fillEqually; selectorCard.addSubview(choices); choices.snp.makeConstraints { $0.edges.equalToSuperview().inset(9) }
        repository.passportTemplates.forEach { name in let choice = passportChoice(name); choice.addAction(UIAction { [weak self] _ in self?.selected = name; self?.render() }, for: .touchUpInside); choices.addArrangedSubview(choice) }
        selectorCard.snp.makeConstraints { $0.height.equalTo(98) }; stack.addArrangedSubview(selectorCard)
        let price = DashedMediaButton(type: .system); price.dashCornerRadius = 13; price.layer.cornerRadius = 13; price.addTarget(self, action: #selector(generate), for: .touchUpInside); price.snp.makeConstraints { $0.width.equalTo(228); $0.height.equalTo(42) }
        let generateTitle = label("Generate for", size: 15, weight: .bold, color: Palette.muted); generateTitle.isUserInteractionEnabled = false
        let priceCoin = UIImageView(image: UIImage(named: "coin")); priceCoin.contentMode = .scaleAspectFit; priceCoin.isUserInteractionEnabled = false; priceCoin.snp.makeConstraints { $0.width.height.equalTo(17) }
        let priceAmount = label("5 coins", size: 15, weight: .bold, color: Palette.muted); priceAmount.isUserInteractionEnabled = false
        let priceContent = UIStackView(arrangedSubviews: [generateTitle, priceCoin, priceAmount]); priceContent.spacing = 5; priceContent.alignment = .center; priceContent.isUserInteractionEnabled = false; price.addSubview(priceContent); priceContent.snp.makeConstraints { $0.center.equalToSuperview() }
        let priceRow = UIStackView(arrangedSubviews: [UIView(), price, UIView()]); priceRow.distribution = .equalCentering; stack.addArrangedSubview(priceRow)
        preview.snp.makeConstraints { $0.height.equalTo(405) }; stack.addArrangedSubview(preview)
        let flexible = UIView(); flexible.snp.makeConstraints { $0.height.greaterThanOrEqualTo(0).priority(.low) }; stack.addArrangedSubview(flexible)
        saveButton.setTitle("Save", for: .normal); saveButton.setTitleColor(.white, for: .normal); saveButton.titleLabel?.font = AppFont.nunito(20, weight: .black); saveButton.backgroundColor = Palette.purple; saveButton.layer.cornerRadius = 17; saveButton.addTarget(self, action: #selector(save), for: .touchUpInside); saveButton.snp.makeConstraints { $0.height.equalTo(54) }
        view.addSubview(saveButton); saveButton.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(18); $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(3); $0.height.equalTo(54) }
        contentView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide) }
        stack.snp.updateConstraints { $0.bottom.equalToSuperview().inset(3) }
        render()
    }
    private func passportChoice(_ name: String) -> UIButton {
        let value = UIButton(type: .system); value.accessibilityIdentifier = name; value.layer.cornerRadius = 8
        let image = UIImageView(image: UIImage(named: PassportStyle(name: name).thumbnailAsset)); image.contentMode = .scaleAspectFill; image.clipsToBounds = true; image.layer.cornerRadius = 6; value.addSubview(image); image.snp.makeConstraints { $0.top.centerX.equalToSuperview().offset(1); $0.width.equalTo(38); $0.height.equalTo(45) }
        let title = label(name, size: 10, weight: .bold); title.textAlignment = .center; value.addSubview(title); title.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview().inset(2); $0.top.equalTo(image.snp.bottom).offset(2) }
        return value
    }
    private func render() {
        choices.arrangedSubviews.forEach { view in let active = view.accessibilityIdentifier == selected; view.layer.borderWidth = active ? 1 : 0; view.layer.borderColor = Palette.purple.cgColor; view.backgroundColor = active ? UIColor(hex: 0xF1EDFF) : .clear }
        preview.subviews.forEach { $0.removeFromSuperview() }
        let style = PassportStyle(name: selected); let post = postID.flatMap(repository.post(id:)); let titleText = draft?.title ?? post?.title ?? "Wild escape"
        let shadow = UIView(); shadow.backgroundColor = UIColor.black.withAlphaComponent(0.12); shadow.layer.cornerRadius = 8; shadow.transform = CGAffineTransform(rotationAngle: 0.035); preview.addSubview(shadow); shadow.snp.makeConstraints { $0.centerX.equalToSuperview().offset(5); $0.top.equalToSuperview().offset(35); $0.width.equalTo(235); $0.height.equalTo(350) }
        let backing = UIImageView(image: UIImage(named: style.backingAsset)); backing.contentMode = .scaleAspectFit; backing.clipsToBounds = false; backing.transform = CGAffineTransform(rotationAngle: -0.025); preview.addSubview(backing); backing.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.top.equalToSuperview().offset(24); $0.width.equalTo(255); $0.height.equalTo(365) }
        let ticket = UIView(); ticket.backgroundColor = UIColor(hex: style.paperColor); ticket.layer.cornerRadius = 4; ticket.layer.borderWidth = 1; ticket.layer.borderColor = UIColor(hex: 0xD8D3C4).cgColor; preview.addSubview(ticket); ticket.snp.makeConstraints { $0.centerX.equalToSuperview().offset(5); $0.top.equalToSuperview().offset(78); $0.width.equalTo(207); $0.height.equalTo(278) }
        let band = UILabel(); band.text = selected.uppercased(); band.textColor = .white; band.backgroundColor = UIColor(hex: style.accentColor); band.font = AppFont.nunito(14, weight: .black); band.textAlignment = .center; ticket.addSubview(band); band.snp.makeConstraints { $0.leading.trailing.top.equalToSuperview(); $0.height.equalTo(28) }
        let previewImage = draft?.mediaRecords.first.flatMap(PostMediaStore.previewImage(for:)) ?? postID.flatMap(PostMediaStore.previewImage(postID:)) ?? UIImage(named: "Figma-292-5041-rectangle157-425c351f")
        let landscape = UIImageView(image: previewImage); landscape.contentMode = .scaleAspectFill; landscape.clipsToBounds = true; landscape.layer.borderWidth = 4; landscape.layer.borderColor = UIColor.white.cgColor; landscape.layer.cornerRadius = 3; ticket.addSubview(landscape); landscape.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(12); $0.top.equalTo(band.snp.bottom).offset(13); $0.height.equalTo(100) }
        let duration = draft?.duration ?? post?.duration ?? "Weekend"
        let details = UIStackView(); details.axis = .vertical; details.spacing = 7; ticket.addSubview(details); details.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(18); $0.top.equalTo(landscape.snp.bottom).offset(14) }
        let rows = [
            ("Explorer", repository.currentUser?.name ?? "Explorer"),
            ("Date", (post?.createdAt ?? Date()).formatted(date: .abbreviated, time: .omitted)),
            ("Duration", duration),
            ("Highlight", titleText)
        ]
        rows.forEach { key, value in
            let row = UIView(); let keyLabel = label(key, size: 6.5, weight: .semibold, color: UIColor(hex: 0xA7A99F)); let valueLabel = label(value, size: 6.5, weight: .bold, color: Palette.ink); valueLabel.textAlignment = .right; valueLabel.adjustsFontSizeToFitWidth = true; valueLabel.minimumScaleFactor = 0.75; row.addSubview(keyLabel); row.addSubview(valueLabel); keyLabel.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }; valueLabel.snp.makeConstraints { $0.leading.greaterThanOrEqualTo(keyLabel.snp.trailing).offset(8); $0.trailing.centerY.equalToSuperview() }; row.snp.makeConstraints { $0.height.equalTo(10) }; details.addArrangedSubview(row)
        }
        let stamp = label(selected.uppercased(), size: 10, weight: .black, color: UIColor(hex: style.accentColor)); stamp.textAlignment = .center; stamp.layer.borderWidth = 2; stamp.layer.borderColor = UIColor(hex: style.accentColor).cgColor; stamp.transform = CGAffineTransform(rotationAngle: -0.12); ticket.addSubview(stamp); stamp.snp.makeConstraints { $0.trailing.bottom.equalToSuperview().inset(8); $0.width.equalTo(74); $0.height.equalTo(26) }
        let side = label(selected.uppercased(), size: 9, weight: .black, color: UIColor(hex: style.accentColor)); side.textAlignment = .center; side.backgroundColor = UIColor(hex: style.paperColor); side.transform = CGAffineTransform(rotationAngle: -.pi / 2); preview.addSubview(side); side.snp.makeConstraints { $0.centerY.equalTo(ticket); $0.centerX.equalTo(ticket.snp.leading).offset(-2); $0.width.equalTo(74); $0.height.equalTo(22) }
    }
    @objc private func generate() { render() }
    @objc private func save() {
        confirmSpend(amount: 5, purpose: "publishing this Adventure Card and saving the \(selected) Passport") {
            var resolvedID = self.postID
            if resolvedID == nil, let draft = self.draft {
                resolvedID = self.repository.publish(category: draft.category, title: draft.title, location: draft.location, story: draft.story, duration: draft.duration, highlights: draft.title, mediaRecords: draft.mediaRecords)
            }
            guard let resolvedID else { return }
            self.repository.savePassport(postID: resolvedID, template: self.selected)
            NotificationCenter.default.post(name: AppRepository.changed, object: self.repository)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    @objc private func close() { navigationController?.popViewController(animated: true) }
}

struct PassportStyle {
    let name: String
    var backingAsset: String { switch name { case "Vintage": return "Figma-306-6355-parks11-a5a20b20"; case "Mountain": return "Figma-306-6421-parks11-8b676147"; case "Forest": return "Figma-306-6487-parks11-61e04b7c"; case "Minimal": return "Figma-311-4166-parks11-585b0e3d"; default: return "Figma-292-5041-parks11-6e64af69" } }
    var thumbnailAsset: String { switch name { case "Vintage": return "Figma-292-5041-vintage2-41efd490"; case "Mountain": return "Figma-292-5041-mountain1-cae4a743"; case "Forest": return "Figma-292-5041-forest1-40ab3415"; case "Minimal": return "Figma-292-5041-minimal1-4123ea3d"; default: return "Figma-292-5041-parks2-3a968035" } }
    var accentColor: UInt32 { switch name { case "Vintage": return 0x8A5A22; case "Mountain": return 0x6C512A; case "Forest": return 0x315D42; case "Minimal": return 0x25231F; default: return 0x4B642D } }
    var paperColor: UInt32 { name == "Minimal" ? 0xF7F3E9 : 0xF0E9D7 }
}

private extension UILabel {
    func setLineSpacing(_ spacing: CGFloat) {
        guard let text else { return }; let paragraph = NSMutableParagraphStyle(); paragraph.lineSpacing = spacing
        attributedText = NSAttributedString(string: text, attributes: [.font: font as Any, .foregroundColor: textColor as Any, .paragraphStyle: paragraph])
    }
}

final class SearchViewController: BaseScrollableViewController {
    private let query = UISearchBar(); private let results = UIStackView()
    override func viewDidLoad() {
        super.viewDidLoad(); navigationController?.setNavigationBarHidden(true, animated: false); stack.spacing = 20
        let header = UIStackView(); header.alignment = .center; header.spacing = 7
        let back = UIButton(type: .system); back.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21, weight: .bold)), for: .normal); back.tintColor = Palette.ink; back.addTarget(self, action: #selector(close), for: .touchUpInside); back.snp.makeConstraints { $0.width.equalTo(27) }
        let heading = titleLabel("Search", size: 30); heading.font = AppFont.nunito(30, weight: .black)
        header.addArrangedSubview(back); header.addArrangedSubview(heading); header.addArrangedSubview(UIView()); stack.addArrangedSubview(header)
        query.placeholder = "Search adventures, parks, trails..."; query.searchBarStyle = .minimal; query.backgroundImage = UIImage(); query.backgroundColor = .white; query.layer.cornerRadius = 18; query.layer.cornerCurve = .continuous; query.clipsToBounds = true; query.delegate = self
        query.searchTextField.backgroundColor = .clear; query.searchTextField.borderStyle = .none; query.searchTextField.font = AppFont.nunito(13, weight: .semibold); query.searchTextField.textColor = Palette.ink
        query.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)), for: .search, state: .normal)
        query.snp.makeConstraints { $0.height.equalTo(60) }; stack.addArrangedSubview(query)
        results.axis = .vertical; results.spacing = 14; stack.addArrangedSubview(results); render("")
    }
    private func render(_ term: String) {
        results.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let value = term.trimmingCharacters(in: .whitespacesAndNewlines).folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        let posts = repository.visiblePosts.filter { post in
            guard !value.isEmpty else { return true }
            let author = repository.user(id: post.authorID)?.name ?? ""
            let searchableText = [post.title, post.location, post.category, post.duration, post.highlights, post.story, author]
                .joined(separator: " ")
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            return searchableText.contains(value)
        }
        if posts.isEmpty { results.addArrangedSubview(EmptyStateView(text: "No matching results. Try another search.")) } else { posts.forEach { post in
        let card = searchCard(post)
        card.onOpen = { [weak self] in self?.requireLogin { self?.navigationController?.pushViewController(PostDetailViewController(postID: post.id), animated: true) } }
        card.onComment = card.onOpen
        card.onLike = { [weak self] in self?.requireLogin { self?.repository.toggleLike(postID: post.id) } }
        results.addArrangedSubview(card)
        } }
    }
    private func searchCard(_ post: AdventurePost) -> AdventureFeedCardView {
        AdventureFeedCardView(post: post, author: repository.user(id: post.authorID))
    }
    @objc private func noop() {}
    @objc private func close() { navigationController?.popViewController(animated: true) }
    override func repositoryDidChange() { render(query.text ?? "") }
}
extension SearchViewController: UISearchBarDelegate { func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { render(searchText) } }

final class FollowListViewController: BaseScrollableViewController {
    enum Kind { case following, followers }; private let kind: Kind
    init(kind: Kind) { self.kind = kind; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() { super.viewDidLoad(); configureSecondary(title: kind == .following ? "Following" : "Followers"); render() }
    private func render() { stack.arrangedSubviews.forEach { $0.removeFromSuperview() }; let ids = kind == .following ? repository.currentUser?.following ?? [] : repository.currentUser?.followers ?? []; let visible = ids.filter { !repository.blocked.contains($0) }; if visible.isEmpty { stack.addArrangedSubview(EmptyStateView(text: "No explorers to show.")) } else { visible.forEach { id in guard let user = repository.user(id: id) else { return }; let value = button(user.name + (repository.currentUser?.following.contains(id) == true ? " · Following" : " · Follow"), primary: false, action: #selector(noop)); value.addAction(UIAction { [weak self] _ in self?.navigationController?.pushViewController(OtherProfileViewController(userID: id), animated: true) }, for: .touchUpInside); stack.addArrangedSubview(value) } } }
    @objc private func noop() {}
    override func repositoryDidChange() { render() }
}
