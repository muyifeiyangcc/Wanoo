import Foundation

struct UserProfile: Codable, Hashable {
    let id: String
    var email: String
    var password: String
    var name: String
    var bio: String
    var location: String
    var following: Set<String>
    var followers: Set<String>
    var coins: Int
    var deleted: Bool
    var birthday: String = ""
    var gender: String = ""
    var avatarAsset: String = ""

    private enum CodingKeys: String, CodingKey { case id, email, password, name, bio, location, following, followers, coins, deleted, birthday, gender, avatarAsset }
    init(id: String, email: String, password: String, name: String, bio: String, location: String, following: Set<String>, followers: Set<String>, coins: Int, deleted: Bool, birthday: String = "", gender: String = "", avatarAsset: String = "") { self.id = id; self.email = email; self.password = password; self.name = name; self.bio = bio; self.location = location; self.following = following; self.followers = followers; self.coins = coins; self.deleted = deleted; self.birthday = birthday; self.gender = gender; self.avatarAsset = avatarAsset }
    init(from decoder: Decoder) throws { let c = try decoder.container(keyedBy: CodingKeys.self); id = try c.decode(String.self, forKey: .id); email = try c.decode(String.self, forKey: .email); password = try c.decode(String.self, forKey: .password); name = try c.decode(String.self, forKey: .name); bio = try c.decode(String.self, forKey: .bio); location = try c.decode(String.self, forKey: .location); following = try c.decode(Set<String>.self, forKey: .following); followers = try c.decode(Set<String>.self, forKey: .followers); coins = try c.decode(Int.self, forKey: .coins); deleted = try c.decode(Bool.self, forKey: .deleted); birthday = try c.decodeIfPresent(String.self, forKey: .birthday) ?? ""; gender = try c.decodeIfPresent(String.self, forKey: .gender) ?? ""; avatarAsset = try c.decodeIfPresent(String.self, forKey: .avatarAsset) ?? "" }
}

struct AdventurePost: Codable, Hashable {
    let id: String
    let authorID: String
    var category: String
    var title: String
    var location: String
    var story: String
    var likes: Int
    var comments: [Comment]
    var likedBy: Set<String>
    var savedBy: Set<String>
    var duration: String = "Weekend"
    var highlights: String = ""
    var createdAt: Date = Date()
    var mediaRecords: [String] = []

    private enum CodingKeys: String, CodingKey { case id, authorID, category, title, location, story, likes, comments, likedBy, savedBy, duration, highlights, createdAt, mediaRecords }
    init(id: String, authorID: String, category: String, title: String, location: String, story: String, likes: Int, comments: [Comment], likedBy: Set<String>, savedBy: Set<String>, duration: String = "Weekend", highlights: String = "", createdAt: Date = Date(), mediaRecords: [String] = []) { self.id = id; self.authorID = authorID; self.category = category; self.title = title; self.location = location; self.story = story; self.likes = likes; self.comments = comments; self.likedBy = likedBy; self.savedBy = savedBy; self.duration = duration; self.highlights = highlights.isEmpty ? title : highlights; self.createdAt = createdAt; self.mediaRecords = mediaRecords }
    init(from decoder: Decoder) throws { let c = try decoder.container(keyedBy: CodingKeys.self); id = try c.decode(String.self, forKey: .id); authorID = try c.decode(String.self, forKey: .authorID); category = try c.decode(String.self, forKey: .category); title = try c.decode(String.self, forKey: .title); location = try c.decode(String.self, forKey: .location); story = try c.decode(String.self, forKey: .story); likes = try c.decode(Int.self, forKey: .likes); comments = try c.decode([Comment].self, forKey: .comments); likedBy = try c.decode(Set<String>.self, forKey: .likedBy); savedBy = try c.decode(Set<String>.self, forKey: .savedBy); duration = try c.decodeIfPresent(String.self, forKey: .duration) ?? "Weekend"; highlights = try c.decodeIfPresent(String.self, forKey: .highlights) ?? title; createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date(); mediaRecords = try c.decodeIfPresent([String].self, forKey: .mediaRecords) ?? [] }
}

struct Comment: Codable, Hashable {
    let id: String
    let authorID: String
    let text: String
    var timestamp: Date = Date()
    private enum CodingKeys: String, CodingKey { case id, authorID, text, timestamp }
    init(id: String, authorID: String, text: String, timestamp: Date = Date()) { self.id = id; self.authorID = authorID; self.text = text; self.timestamp = timestamp }
    init(from decoder: Decoder) throws { let c = try decoder.container(keyedBy: CodingKeys.self); id = try c.decode(String.self, forKey: .id); authorID = try c.decode(String.self, forKey: .authorID); text = try c.decode(String.self, forKey: .text); timestamp = try c.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date() }
}

struct ChatRoom: Codable, Hashable {
    let id: String
    var name: String
    var online: Int
    var members: Set<String>
    var messages: [ChatMessage]
    var category: String
    var coverAsset: String
    var capacity: Int
    var participantCount: Int

    private enum CodingKeys: String, CodingKey { case id, name, online, members, messages, category, coverAsset, capacity, participantCount }
    init(id: String, name: String, online: Int, members: Set<String>, messages: [ChatMessage], category: String = "", coverAsset: String = "", capacity: Int = 12, participantCount: Int = 0) { self.id = id; self.name = name; self.online = online; self.members = members; self.messages = messages; self.category = category; self.coverAsset = coverAsset; self.capacity = capacity; self.participantCount = participantCount }
    init(from decoder: Decoder) throws { let c = try decoder.container(keyedBy: CodingKeys.self); id = try c.decode(String.self, forKey: .id); name = try c.decode(String.self, forKey: .name); online = try c.decode(Int.self, forKey: .online); members = try c.decode(Set<String>.self, forKey: .members); messages = try c.decode([ChatMessage].self, forKey: .messages); category = try c.decodeIfPresent(String.self, forKey: .category) ?? ""; coverAsset = try c.decodeIfPresent(String.self, forKey: .coverAsset) ?? ""; capacity = try c.decodeIfPresent(Int.self, forKey: .capacity) ?? 12; participantCount = try c.decodeIfPresent(Int.self, forKey: .participantCount) ?? members.count }
}

struct Conversation: Codable, Hashable {
    let id: String
    let peerID: String
    var messages: [ChatMessage]
    var unread: Int
    var ownerID: String = "user-test"
    private enum CodingKeys: String, CodingKey { case id, peerID, messages, unread, ownerID }
    init(id: String, peerID: String, messages: [ChatMessage], unread: Int, ownerID: String = "user-test") { self.id = id; self.peerID = peerID; self.messages = messages; self.unread = unread; self.ownerID = ownerID }
    init(from decoder: Decoder) throws { let c = try decoder.container(keyedBy: CodingKeys.self); id = try c.decode(String.self, forKey: .id); peerID = try c.decode(String.self, forKey: .peerID); messages = try c.decode([ChatMessage].self, forKey: .messages); unread = try c.decode(Int.self, forKey: .unread); ownerID = try c.decodeIfPresent(String.self, forKey: .ownerID) ?? "user-test" }
}

struct ChatMessage: Codable, Hashable {
    let id: String
    let senderID: String
    let text: String
    let timestamp: Date
    var isVoice: Bool
    var audioFileName: String?
    var voiceDuration: Double?

    init(id: String, senderID: String, text: String, timestamp: Date, isVoice: Bool, audioFileName: String? = nil, voiceDuration: Double? = nil) {
        self.id = id; self.senderID = senderID; self.text = text; self.timestamp = timestamp; self.isVoice = isVoice
        self.audioFileName = audioFileName; self.voiceDuration = voiceDuration
    }

    private enum CodingKeys: String, CodingKey { case id, senderID, text, timestamp, isVoice, audioFileName, voiceDuration }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id); senderID = try values.decode(String.self, forKey: .senderID)
        text = try values.decode(String.self, forKey: .text); timestamp = try values.decode(Date.self, forKey: .timestamp)
        isVoice = try values.decodeIfPresent(Bool.self, forKey: .isVoice) ?? false
        audioFileName = try values.decodeIfPresent(String.self, forKey: .audioFileName)
        voiceDuration = try values.decodeIfPresent(Double.self, forKey: .voiceDuration)
    }
}

struct ReportRecord: Codable, Hashable {
    let id: String
    let targetID: String
    let reason: String
    let detail: String
    let date: Date
}

struct PassportRecord: Codable, Hashable {
    let id: String
    let postID: String
    let template: String
}

private enum AdventureReplyLibrary {
    private struct Entry {
        let keywords: [String]
        let answer: String
    }

    // Compact, conservative guidance for common outdoor questions.
    private static let entries: [Entry] = [
        Entry(keywords: ["route", "trail", "hike", "hiking", "path", "where should i go"], answer: "A good choice is a well-marked route that fits your time and experience. Compare distance, elevation gain, terrain, daylight, and an easy turnaround point before deciding."),
        Entry(keywords: ["beginner", "first hike", "easy trail", "new to hiking", "simple route"], answer: "For a first trip, choose a popular out-and-back trail with modest elevation and clear signs. Start early, keep the plan short, and turn around before you feel tired."),
        Entry(keywords: ["how long", "duration", "distance", "miles", "kilometers", "time needed"], answer: "Allow more time than the distance alone suggests because elevation, terrain, breaks, and photos slow the pace. Add a generous buffer and set a firm turnaround time before dark."),
        Entry(keywords: ["gear", "equipment", "packing", "backpack", "what should i bring", "checklist"], answer: "For most day trips, bring grippy footwear, layers, water, food, navigation, sun protection, a light, a compact first-aid kit, and a charged phone. Add activity-specific gear for cold, water, or technical terrain."),
        Entry(keywords: ["shoes", "boots", "footwear", "traction"], answer: "Choose broken-in footwear with reliable grip and enough support for the terrain. Waterproofing helps in wet conditions, but comfort, fit, and traction are usually more important."),
        Entry(keywords: ["water", "hydration", "drink", "how much water"], answer: "Carry enough water for the planned effort plus a reserve. Increase it for heat, sun exposure, altitude, or steep terrain, and drink steadily instead of waiting until you feel very thirsty."),
        Entry(keywords: ["food", "snack", "meal", "energy", "what should i eat"], answer: "Pack familiar, easy-to-eat food with a mix of carbohydrates and something salty. Bring a little more than expected so a delay does not leave you without energy."),
        Entry(keywords: ["weather", "forecast", "rain", "storm", "thunder", "wind"], answer: "Check an official forecast close to departure and again before starting. If thunderstorms, strong wind, heavy rain, or rapidly changing conditions are likely, shorten the plan or postpone it."),
        Entry(keywords: ["hot", "heat", "sunny", "temperature", "summer"], answer: "In hot weather, start early, choose shade where possible, carry extra water and electrolytes, and take regular breaks. Head back if anyone develops dizziness, confusion, nausea, or unusual weakness."),
        Entry(keywords: ["cold", "snow", "ice", "winter", "freezing"], answer: "Cold conditions call for warm layers, dry backup clothing, gloves, suitable traction, and a shorter route. Avoid exposed or icy terrain unless your group has the right experience and equipment."),
        Entry(keywords: ["camp", "camping", "tent", "campsite", "overnight"], answer: "Choose an authorized campsite on durable, level ground away from falling branches, flood channels, and exposed ridges. Secure food, manage fire carefully, and leave the area clean."),
        Entry(keywords: ["night", "dark", "sunset", "evening", "headlamp"], answer: "Night travel is slower and harder to navigate. Carry a headlamp with spare power, stay on a familiar route, keep warm layers available, and tell someone when you expect to return."),
        Entry(keywords: ["safe", "safety", "danger", "emergency", "injury", "lost"], answer: "Share your plan, stay within your ability, keep navigation and emergency supplies accessible, and turn back when conditions become uncertain. For an immediate emergency, contact emergency services."),
        Entry(keywords: ["wildlife", "bear", "snake", "animal", "insects"], answer: "Give wildlife plenty of space, never feed animals, keep food secured, and avoid blocking an animal's escape route. If you are unsure how to respond, move away calmly and follow official guidance for that species."),
        Entry(keywords: ["solo", "alone", "by myself", "on my own"], answer: "For a solo trip, favor a familiar and well-used route, share your route and return time, keep communication and navigation ready, and use more conservative turnaround limits."),
        Entry(keywords: ["family", "kids", "children", "child"], answer: "For a family outing, choose a shorter route with simple navigation and frequent turnaround options. Plan extra breaks and carry suitable clothing, water, snacks, and sun protection for each person."),
        Entry(keywords: ["altitude", "elevation", "high mountain", "mountain sickness"], answer: "Gain elevation gradually, keep the pace easy, and watch for headache, nausea, dizziness, or unusual fatigue. Stop ascending if symptoms appear and descend if they worsen."),
        Entry(keywords: ["kayak", "kayaking", "paddle", "boat", "water conditions"], answer: "Wear a properly fitted life jacket, check wind and water conditions, stay close to a safe landing option, and choose a route within your paddling ability. Avoid uncertain conditions when alone."),
        Entry(keywords: ["climb", "climbing", "boulder", "rope", "belay"], answer: "Climbing requires route-specific skills, inspected equipment, and reliable partner checks. Use an experienced partner or qualified guide, especially for unfamiliar anchors, protection, or belay systems.")
    ]

    static func answer(to question: String) -> String {
        let normalized = question.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        let words = normalized.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        func matches(_ keyword: String) -> Bool {
            if keyword.contains(" ") { return normalized.contains(keyword) }
            return words.contains { word in word == keyword || (keyword.count >= 4 && word.hasPrefix(keyword)) }
        }
        let ranked = entries.compactMap { entry -> (Entry, Int)? in
            let score = entry.keywords.reduce(0) { result, keyword in
                guard matches(keyword) else { return result }
                return result + (keyword.contains(" ") ? 4 : 2)
            }
            return score > 0 ? (entry, score) : nil
        }.sorted { $0.1 > $1.1 }
        if let best = ranked.first?.0 { return best.answer }
        return "A cautious plan would be to choose an option within your experience, check the expected conditions, carry water and essential safety gear, leave extra time, and set a clear turnaround point. Tell me the activity, place, expected duration, and main concern, and I can make the suggestion more specific."
    }
}

enum SessionMode: String, Codable { case signedOut, guest, authenticated }

final class AppRepository {
    static let shared = AppRepository()
    static let changed = Notification.Name("WanooRepositoryChanged")

    private enum Key {
        static let snapshot = "wanoo.snapshot.v1"
        static let eula = "wanoo.eula.accepted"
        static let presetAccountZeroCoinsMigration = "wanoo.preset.123.initial-coins.0.v1"
        static let removeSeedChatMigration = "wanoo.remove-seeded-chat-content.v1"
        static let presetFollowerMigration = "wanoo.preset.123.default-follower.v1"
        static let csvSeedMigration = "wanoo.csv-seed.2026-08-13.v1"
        static let discoverRoomIDs = "wanoo.chatrooms.discover-five.v1"
    }

    private struct Snapshot: Codable {
        var users: [UserProfile]
        var posts: [AdventurePost]
        var rooms: [ChatRoom]
        var conversations: [Conversation]
        var reports: [ReportRecord]
        var passports: [PassportRecord]
        var blocked: Set<String>
        var blockedByUser: [String: Set<String>]?
        var session: SessionMode
        var currentUserID: String?
        var aiMessages: [ChatMessage]
        var aiFreeMessages: Int
        var aiMessagesByUser: [String: [ChatMessage]]?
        var aiFreeMessagesByUser: [String: Int]?
    }

    private(set) var users: [UserProfile] = []
    private(set) var posts: [AdventurePost] = []
    private(set) var rooms: [ChatRoom] = []
    private(set) var conversations: [Conversation] = []
    private(set) var reports: [ReportRecord] = []
    private(set) var passports: [PassportRecord] = []
    private var legacyBlocked: Set<String> = []
    private var blockedByUser: [String: Set<String>] = [:]
    private(set) var session: SessionMode = .signedOut
    private(set) var currentUserID: String?
    private var legacyAIMessages: [ChatMessage] = []
    private var legacyAIFreeMessages = 3
    private var aiMessagesByUser: [String: [ChatMessage]] = [:]
    private var aiFreeMessagesByUser: [String: Int] = [:]

    let categories = ["All", "Camping", "Hiking", "Rock Climbing", "Kayaking", "Birdwatching", "Stargazing", "Forest Discovery", "Waterfalls", "National Parks", "Weekend Trips"]
    let themes = ["Camping", "Hiking", "Rock Climbing", "Kayaking", "Birdwatching", "Stargazing", "Forest Discovery", "Waterfalls", "National Parks", "Weekend Trips"]
    let destinations = ["Yosemite", "Lake Tahoe"]
    let passportTemplates = ["Parks", "Vintage", "Mountain", "Forest", "Minimal"]
    let reportReasons = ["Dangerous activity or advice", "Harassment or hate", "Wildlife harm", "Illegal trespassing", "Spam or misleading content", "Private address or sensitive location", "Something else"]
    let explorationTypes = ["Camping", "Hiking", "Rock Climbing", "Kayaking", "Birdwatching", "Stargazing", "Forest Discovery", "Waterfalls", "National Parks", "Weekend Trips"]
    let durations = ["Half Day", "One Day", "Weekend", "Multi-day"]
    let publishCost = 5
    let passportCost = 12
    let aiMessageCost = 5

    var hasAcceptedEULA: Bool {
        get { UserDefaults.standard.bool(forKey: Key.eula) }
        set { UserDefaults.standard.set(newValue, forKey: Key.eula) }
    }

    var currentUser: UserProfile? {
        guard let id = currentUserID else { return nil }
        return users.first(where: { $0.id == id && !$0.deleted })
    }

    var blocked: Set<String> { guard let id = currentUserID else { return [] }; return blockedByUser[id] ?? [] }
    var aiMessages: [ChatMessage] { guard let id = currentUserID else { return [] }; return aiMessagesByUser[id] ?? [] }
    var aiFreeMessages: Int { guard let id = currentUserID else { return 3 }; return aiFreeMessagesByUser[id] ?? 3 }

    var visiblePosts: [AdventurePost] { posts.filter { !blocked.contains($0.authorID) } }
    var visibleRooms: [ChatRoom] {
        rooms.map { room in
            var copy = room
            copy.messages.removeAll { blocked.contains($0.senderID) }
            return copy
        }
    }
    var visibleConversations: [Conversation] { guard let owner = currentUserID else { return [] }; return conversations.filter { $0.ownerID == owner && !blocked.contains($0.peerID) } }
    var discoverRooms: [ChatRoom] {
        let available = visibleRooms.filter { !($0.members.contains(currentUserID ?? "")) }
        let existing = UserDefaults.standard.stringArray(forKey: Key.discoverRoomIDs) ?? []
        let valid = existing.filter { id in rooms.contains(where: { $0.id == id }) }
        let orderedIDs: [String]
        if valid.count == rooms.count { orderedIDs = valid }
        else {
            orderedIDs = rooms.shuffled().map(\.id)
            UserDefaults.standard.set(orderedIDs, forKey: Key.discoverRoomIDs)
        }
        return orderedIDs.compactMap { id in available.first(where: { $0.id == id }) }.prefix(5).map { $0 }
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: Key.snapshot),
           let value = try? JSONDecoder().decode(Snapshot.self, from: data) {
            apply(value)
            migratePresetAccountZeroCoinsIfNeeded()
            migrateSeededChatContentIfNeeded()
            migratePresetFollowerAndAvatarIfNeeded()
            migrateCSVSeedIfNeeded()
        } else {
            seed()
            persist()
        }
    }

    /// Applies the updated preset-account baseline once to existing installs.
    /// Future purchases and spending are preserved after this migration runs.
    private func migratePresetAccountZeroCoinsIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Key.presetAccountZeroCoinsMigration) else { return }
        if let index = users.firstIndex(where: { $0.email.lowercased() == "123@gmail.com" }) {
            users[index].coins = 0
            persist()
        }
        UserDefaults.standard.set(true, forKey: Key.presetAccountZeroCoinsMigration)
    }

    /// Removes only the development conversations/messages that shipped with
    /// earlier builds. User-created conversations and room messages are kept.
    private func migrateSeededChatContentIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Key.removeSeedChatMigration) else { return }
        let seededConversationIDs: Set<String> = ["chat-maya", "chat-chris", "chat-evelyn", "chat-mia", "chat-luna"]
        conversations.removeAll { seededConversationIDs.contains($0.id) }
        if let index = rooms.firstIndex(where: { $0.id == "room-stars" }),
           rooms[index].messages.count == 1,
           rooms[index].messages.first?.text == "The moonrise is at 8:42 tonight." {
            rooms[index].messages.removeAll()
        }
        UserDefaults.standard.set(true, forKey: Key.removeSeedChatMigration)
        persist()
    }

    private func migratePresetFollowerAndAvatarIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Key.presetFollowerMigration),
              let testIndex = users.firstIndex(where: { $0.email.lowercased() == "123@gmail.com" }),
              let followerIndex = users.firstIndex(where: { $0.id == "user-maya" }) else { return }
        let testID = users[testIndex].id
        users.indices.forEach {
            users[$0].followers.remove(testID)
            users[$0].following.remove(testID)
        }
        users[testIndex].following.removeAll()
        users[testIndex].followers = [users[followerIndex].id]
        users[followerIndex].following.insert(testID)
        UserDefaults.standard.removeObject(forKey: "profile-avatar-\(testID)")
        UserDefaults.standard.set(true, forKey: Key.presetFollowerMigration)
        persist()
    }

    /// Replaces only the obsolete bundled demonstration records. Accounts and
    /// content created by the user are preserved.
    private func migrateCSVSeedIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Key.csvSeedMigration) else { return }
        let obsoleteUsers: Set<String> = ["user-maya", "user-chris", "user-evelyn", "user-mia", "user-luna"]
        let obsoletePosts: Set<String> = ["post-forest", "post-camp"]
        let obsoleteRooms: Set<String> = ["room-stars", "room-weekend", "room-yosemite", "room-birdwatchers", "room-waterfalls", "room-rock-rope"]
        users.removeAll { obsoleteUsers.contains($0.id) }
        posts.removeAll { obsoletePosts.contains($0.id) || obsoleteUsers.contains($0.authorID) }
        rooms.removeAll { obsoleteRooms.contains($0.id) }
        conversations.removeAll { obsoleteUsers.contains($0.peerID) || obsoleteUsers.contains($0.ownerID) }
        users.indices.forEach {
            users[$0].following.subtract(obsoleteUsers)
            users[$0].followers.subtract(obsoleteUsers)
        }
        blockedByUser = blockedByUser.reduce(into: [:]) { result, entry in
            guard !obsoleteUsers.contains(entry.key) else { return }
            result[entry.key] = entry.value.subtracting(obsoleteUsers)
        }
        if currentUserID.map(obsoleteUsers.contains) == true { currentUserID = nil; session = .signedOut }
        installCSVSeedRecords()
        UserDefaults.standard.removeObject(forKey: Key.discoverRoomIDs)
        UserDefaults.standard.set(true, forKey: Key.csvSeedMigration)
        persist()
    }

    private func seed() {
        let test = UserProfile(id: "user-test", email: "123@gmail.com", password: "12345678", name: "Avery Brooks", bio: "Small escapes, big memories.", location: "San Francisco, CA", following: [], followers: [], coins: 0, deleted: false)
        users = [test]
        posts = []
        rooms = []
        installCSVSeedRecords()
        conversations = []
        reports = []
        passports = []
        blockedByUser = [:]
        session = .signedOut
        currentUserID = nil
        aiMessagesByUser = [:]
        aiFreeMessagesByUser = [test.id: 3]
    }

    private func installCSVSeedRecords() {
        let profiles: [UserProfile] = [
            UserProfile(id: "seed-lukas", email: "lukas@wanoo.example", password: "", name: "Lukas", bio: "Weekend camps and ocean views.", location: "Big Sur", following: ["user-test"], followers: [], coins: 0, deleted: false, gender: "Sir", avatarAsset: "m1"),
            UserProfile(id: "seed-sophie", email: "sophie@wanoo.example", password: "", name: "Sophie", bio: "Chasing light on every trail.", location: "Mt. Diablo", following: [], followers: [], coins: 0, deleted: false, gender: "Madam", avatarAsset: "w4"),
            UserProfile(id: "seed-jan", email: "jan@wanoo.example", password: "", name: "Jan", bio: "Sandstone, grip, and cool air.", location: "Castle Rock", following: [], followers: [], coins: 0, deleted: false, gender: "Sir", avatarAsset: "m2"),
            UserProfile(id: "seed-astrid", email: "astrid@wanoo.example", password: "", name: "Astrid", bio: "Clear water and mountain reflections.", location: "Lake Tahoe", following: [], followers: [], coins: 0, deleted: false, gender: "Madam", avatarAsset: "w2"),
            UserProfile(id: "seed-rossi", email: "rossi@wanoo.example", password: "", name: "Rossi", bio: "Patient mornings with wild birds.", location: "Palo Alto Baylands", following: [], followers: [], coins: 0, deleted: false, gender: "Sir", avatarAsset: "ab9940e16700104401695919fbd68158"),
            UserProfile(id: "seed-hannah", email: "hannah@wanoo.example", password: "", name: "Hannah", bio: "Always looking up after dark.", location: "Death Valley", following: [], followers: [], coins: 0, deleted: false, gender: "Madam", avatarAsset: "w3"),
            UserProfile(id: "seed-jasmine", email: "jasmine@wanoo.example", password: "", name: "Jasmine", bio: "Redwoods, moss, and quiet trails.", location: "Muir Woods", following: [], followers: [], coins: 0, deleted: false, gender: "Madam", avatarAsset: "w6"),
            UserProfile(id: "seed-april", email: "april@wanoo.example", password: "", name: "April", bio: "Waterfall mist and mountain air.", location: "Yosemite Valley", following: [], followers: [], coins: 0, deleted: false, gender: "Madam", avatarAsset: "w5"),
            UserProfile(id: "seed-dawn", email: "dawn@wanoo.example", password: "", name: "Dawn", bio: "Desert rocks at golden hour.", location: "Joshua Tree NP", following: [], followers: [], coins: 0, deleted: false, gender: "Sir", avatarAsset: "m5"),
            UserProfile(id: "seed-adela", email: "adela@wanoo.example", password: "", name: "Adela", bio: "Small weekend trips, endless views.", location: "Napa Valley", following: [], followers: [], coins: 0, deleted: false, gender: "Madam", avatarAsset: "w7")
        ]
        let profileIDs = Set(profiles.map(\.id))
        users.removeAll { profileIDs.contains($0.id) }
        users.append(contentsOf: profiles)
        if let testIndex = users.firstIndex(where: { $0.id == "user-test" }) { users[testIndex].followers.insert("seed-lukas") }

        let baseDate = Date(timeIntervalSince1970: 1_785_600_000)
        posts.removeAll { $0.id.hasPrefix("csv-post-") }
        posts = [
            AdventurePost(id: "csv-post-lukas", authorID: "seed-lukas", category: "Camping", title: "Weekend Camping Big Sur.", location: "Big Sur", story: "Camp with a ocean view. First time at Big Sur, worth every mile.", likes: 0, comments: [], likedBy: [], savedBy: [], duration: "Weekend", highlights: "Weekend Camping Big Sur.", createdAt: baseDate.addingTimeInterval(900), mediaRecords: ["asset|cp"]),
            AdventurePost(id: "csv-post-sophie", authorID: "seed-sophie", category: "Hiking", title: "Half-day Mt. Diablo Hike!", location: "Mt. Diablo", story: "Chasing light at Mt. Diablo. Perfect panoramic view of the SF Bay.", likes: 0, comments: [Comment(id: "csv-comment-sophie", authorID: "seed-jan", text: "What a view!", timestamp: baseDate.addingTimeInterval(1_820))], likedBy: [], savedBy: [], duration: "Half Day", highlights: "Half-day Mt. Diablo Hike!", createdAt: baseDate.addingTimeInterval(1_800), mediaRecords: ["asset|hk"]),
            AdventurePost(id: "csv-post-jan", authorID: "seed-jan", category: "Rock Climbing", title: "Castle Rock Bouldering.", location: "Castle Rock", story: "Tackling sandstone boulders today. Perfect friction and cool autumn weather.", likes: 0, comments: [Comment(id: "csv-comment-jan", authorID: "seed-astrid", text: "Perfect climbing weather!", timestamp: baseDate.addingTimeInterval(2_720))], likedBy: [], savedBy: [], duration: "Half Day", highlights: "Castle Rock Bouldering.", createdAt: baseDate.addingTimeInterval(2_700), mediaRecords: ["bundle-video|eb29f97b972d0e2f740e5e7038848871_720w.mp4"]),
            AdventurePost(id: "csv-post-astrid", authorID: "seed-astrid", category: "Kayaking", title: "Lake Tahoe Kayaking.", location: "Lake Tahoe", story: "Kayaking on glass. Clear turquoise water and epic mountain reflections at Tahoe.", likes: 0, comments: [Comment(id: "csv-comment-astrid", authorID: "seed-rossi", text: "Wow, that water looks impossibly clear!", timestamp: baseDate.addingTimeInterval(3_620))], likedBy: [], savedBy: [], duration: "One Day", highlights: "Lake Tahoe Kayaking.", createdAt: baseDate.addingTimeInterval(3_600), mediaRecords: ["asset|pht"]),
            AdventurePost(id: "csv-post-rossi", authorID: "seed-rossi", category: "Birdwatching", title: "Baylands Bird Spotting.", location: "Palo Alto Baylands", story: "Spotted a majestic Great Blue Heron at sunrise. Nature's patience pays off.", likes: 0, comments: [Comment(id: "csv-comment-rossi", authorID: "seed-hannah", text: "Incredible capture!", timestamp: baseDate.addingTimeInterval(4_520))], likedBy: [], savedBy: [], duration: "Half Day", highlights: "Baylands Bird Spotting.", createdAt: baseDate.addingTimeInterval(4_500), mediaRecords: ["asset|728cd182f773f9945acc1fa9284a17b2"]),
            AdventurePost(id: "csv-post-hannah", authorID: "seed-hannah", category: "Stargazing", title: "Night Sky at Death Valley.", location: "Death Valley", story: "Zero light pollution and millions of stars above. Milky Way in full display!", likes: 0, comments: [], likedBy: [], savedBy: [], duration: "Weekend", highlights: "Night Sky at Death Valley.", createdAt: baseDate.addingTimeInterval(5_400), mediaRecords: ["bundle-video|ddce60181ab2acbb75b919dd06b76f9d.mp4"]),
            AdventurePost(id: "csv-post-jasmine", authorID: "seed-jasmine", category: "Forest Discovery", title: "Deep Forest Therapy.", location: "Muir Woods", story: "Getting small among the towering redwoods. Fresh air and mossy trails.", likes: 0, comments: [], likedBy: [], savedBy: [], duration: "Half Day", highlights: "Deep Forest Therapy.", createdAt: baseDate.addingTimeInterval(6_300), mediaRecords: ["asset|2236838bd68c94ef6ec7598f98ceeec6"]),
            AdventurePost(id: "csv-post-april", authorID: "seed-april", category: "Waterfalls", title: "Vernal Fall Mist Trail.", location: "Yosemite Valley", story: "Feeling the roar and cold spray of Vernal Fall. Unbelievable water flow!", likes: 0, comments: [], likedBy: [], savedBy: [], duration: "One Day", highlights: "Vernal Fall Mist Trail.", createdAt: baseDate.addingTimeInterval(7_200), mediaRecords: ["asset|384c4771332d91ee649ae05af2e3799a"]),
            AdventurePost(id: "csv-post-dawn", authorID: "seed-dawn", category: "National Parks", title: "Desert Vibes in Joshua Tree.", location: "Joshua Tree NP", story: "Exploring unique rock formations and iconic Joshua Trees under golden hour light.", likes: 0, comments: [], likedBy: [], savedBy: [], duration: "Weekend", highlights: "Desert Vibes in Joshua Tree.", createdAt: baseDate.addingTimeInterval(8_100), mediaRecords: ["asset|60db78440af274bdaaa3650c94b7404a"]),
            AdventurePost(id: "csv-post-adela", authorID: "seed-adela", category: "Weekend Trips", title: "Pure Serenity", location: "Napa Valley", story: "Quick weekend trip! Endless views, delicious eats, and pure relaxation.", likes: 0, comments: [], likedBy: [], savedBy: [], duration: "Weekend", highlights: "Pure Serenity", createdAt: baseDate.addingTimeInterval(9_000), mediaRecords: ["bundle-video|6d0001b0073e943d10e6b06062c8da74.mp4"])
        ] + posts

        let definitions: [(String, String, String, String)] = [
            ("wild-camping-gear", "Wild Camping Gear", "Camping", "a46d099d52b9098c902f8af5d34b492d"), ("solo-hammock-life", "Solo Hammock Life", "Camping", "8fd2bc4cdc1c78fb720968d349b77511"),
            ("alpine-trail-seekers", "Alpine Trail Seekers", "Hiking", "ce0953b9d1d1ee45377aee27da62fee4"), ("ultralight-hikers-hub", "Ultralight Hikers Hub", "Hiking", "e0d810409495f0bff8f2a170821023d8"),
            ("bouldering-crew", "Bouldering Crew", "Rock Climbing", "93e9575f93d7e134ac83ca5217ed598f"), ("beginner-climbers-club", "Beginner Climbers Club", "Rock Climbing", "00b46d4d1af1fce7b9325544c65ab9ee"),
            ("sea-kayak-explorers", "Sea Kayak Explorers", "Kayaking", "3b2dd3eea1af733fed037898f6f69e94"), ("paddle-board-life", "Paddle Board Life", "Kayaking", "996c0f6661d99b809bfd0f14fedeb7c6"),
            ("forest-bird-lovers", "Forest Bird Lovers", "Birdwatching", "a71bb52209b1d37e829fb6a1ca5f7bf5"), ("rare-birds-spotting", "Rare Birds Spotting", "Birdwatching", "882eb70ceaea0453899c8d68c9e9ec84"),
            ("milky-way-hunters", "Milky Way Hunters", "Stargazing", "544d7d57d4efba2cf0451a0bc5356f9c"), ("meteor-chasers", "Meteor Chasers", "Stargazing", "161aee2f4648e29d11923a84e89e9860"),
            ("deep-woods-trails", "Deep Woods Trails", "Forest Discovery", "60239ee77f5774776d1d4f8a27704fac"), ("bushcraft-survival", "Bushcraft Survival", "Forest Discovery", "5996accf11fdb7a7bf7b9283768c05e3"),
            ("waterfall-photo-crew", "Waterfall Photo Crew", "Waterfalls", "d394675e87ee28d718fe22b51479282d"), ("hidden-cascades-club", "Hidden Cascades Club", "Waterfalls", "e5ab7f0a2e97dee376375b0c191bd6f7"),
            ("mountain-park-explorers", "Mountain Park Explorers", "National Parks", "14f0f7e6cea86fc0231272eedb6d6a06"), ("park-route-planners", "Park Route Planners", "National Parks", "f06ca08c0e353cca365029890be9daf3"),
            ("weekend-road-trips", "Weekend Road Trips", "Weekend Trips", "c9fad0c2e8d9149d3d6ef54ca4bbbdad"), ("local-micro-adventures", "Local Micro Adventures", "Weekend Trips", "84798c8584fd9a4279c5c5a95340dbad")
        ]
        rooms.removeAll { $0.id.hasPrefix("csv-room-") }
        rooms.append(contentsOf: definitions.enumerated().map { index, item in
            let capacity = 48 + ((index * 37 + 29) % 145)
            let participants = 8 + ((index * 23 + 11) % max(9, capacity - 8))
            let online = 4 + ((index * 17 + 7) % max(5, participants))
            return ChatRoom(id: "csv-room-" + item.0, name: item.1, online: online, members: [], messages: [], category: item.2, coverAsset: item.3, capacity: capacity, participantCount: participants)
        })
    }

    func reloadSeedData() { seed(); changedAndPersist() }

    @discardableResult
    func signIn(email: String, password: String) -> Bool {
        guard let user = users.first(where: { $0.email.lowercased() == email.lowercased() && $0.password == password && !$0.deleted }) else { return false }
        session = .authenticated
        currentUserID = user.id
        changedAndPersist()
        return true
    }

    func enterAsGuest() { session = .guest; currentUserID = nil; changedAndPersist() }
    func signOut() { session = .signedOut; currentUserID = nil; changedAndPersist() }

    @discardableResult
    func register(email: String, password: String, name: String) -> Bool {
        guard !users.contains(where: { $0.email.lowercased() == email.lowercased() && !$0.deleted }) else { return false }
        let user = UserProfile(id: UUID().uuidString, email: email, password: password, name: name, bio: "Ready for a new adventure.", location: "", following: [], followers: [], coins: 0, deleted: false)
        users.append(user)
        session = .authenticated
        currentUserID = user.id
        changedAndPersist()
        return true
    }

    @discardableResult
    func resetPassword(email: String, password: String) -> Bool {
        guard let index = users.firstIndex(where: { $0.email.lowercased() == email.lowercased() && !$0.deleted }) else { return false }
        users[index].password = password
        changedAndPersist()
        return true
    }

    func updateProfile(name: String, bio: String, location: String, birthday: String? = nil, gender: String? = nil) {
        guard let id = currentUserID, let index = users.firstIndex(where: { $0.id == id }) else { return }
        users[index].name = name
        users[index].bio = bio
        users[index].location = location
        if let birthday { users[index].birthday = birthday }
        if let gender { users[index].gender = gender }
        changedAndPersist()
    }

    func deleteCurrentAccount() {
        guard let id = currentUserID, let index = users.firstIndex(where: { $0.id == id }) else { return }
        users[index].deleted = true
        let mediaRecords = posts.filter { $0.authorID == id }.flatMap(\.mediaRecords)
        mediaRecords.filter { $0.hasPrefix("image|") || $0.hasPrefix("video|") }.forEach { try? FileManager.default.removeItem(atPath: String($0.dropFirst(6))) }
        UserDefaults.standard.removeObject(forKey: "profile-avatar-\(id)")
        posts.removeAll { $0.authorID == id }
        conversations.removeAll { $0.ownerID == id || $0.peerID == id }
        rooms.indices.forEach { rooms[$0].members.remove(id); rooms[$0].messages.removeAll { $0.senderID == id } }
        users.indices.forEach { users[$0].following.remove(id); users[$0].followers.remove(id) }
        posts.indices.forEach { posts[$0].likedBy.remove(id); posts[$0].savedBy.remove(id); posts[$0].comments.removeAll { $0.authorID == id } }
        blockedByUser.removeValue(forKey: id); blockedByUser.keys.forEach { blockedByUser[$0]?.remove(id) }
        aiMessagesByUser.removeValue(forKey: id); aiFreeMessagesByUser.removeValue(forKey: id)
        passports.removeAll { passport in !posts.contains(where: { $0.id == passport.postID }) }
        session = .signedOut
        currentUserID = nil
        changedAndPersist()
    }

    func user(id: String) -> UserProfile? { users.first(where: { $0.id == id && !$0.deleted }) }
    func post(id: String) -> AdventurePost? { visiblePosts.first(where: { $0.id == id }) }

    func toggleLike(postID: String) {
        guard let userID = currentUserID, let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        if posts[index].likedBy.remove(userID) == nil { posts[index].likedBy.insert(userID); posts[index].likes += 1 }
        else { posts[index].likes = max(0, posts[index].likes - 1) }
        changedAndPersist()
    }

    func toggleSaved(postID: String) {
        guard let userID = currentUserID, let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        if posts[index].savedBy.remove(userID) == nil { posts[index].savedBy.insert(userID) }
        changedAndPersist()
    }

    @discardableResult
    func deletePost(postID: String) -> Bool {
        guard let userID = currentUserID,
              let index = posts.firstIndex(where: { $0.id == postID }),
              posts[index].authorID == userID else { return false }
        posts.remove(at: index)
        passports.removeAll { $0.postID == postID }
        UserDefaults.standard.removeObject(forKey: "wanoo.post.media." + postID)
        changedAndPersist()
        return true
    }

    func addComment(postID: String, text: String) {
        guard let userID = currentUserID, let index = posts.firstIndex(where: { $0.id == postID }), !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        posts[index].comments.append(Comment(id: UUID().uuidString, authorID: userID, text: text, timestamp: Date()))
        changedAndPersist()
    }

    func toggleFollow(userID: String) {
        guard let me = currentUserID, me != userID,
              let mine = users.firstIndex(where: { $0.id == me }),
              let theirs = users.firstIndex(where: { $0.id == userID }) else { return }
        if users[mine].following.remove(userID) == nil {
            users[mine].following.insert(userID)
            users[theirs].followers.insert(me)
        } else {
            users[theirs].followers.remove(me)
        }
        changedAndPersist()
    }

    func isMutual(userID: String) -> Bool {
        guard let me = currentUser else { return false }
        return me.following.contains(userID) && (user(id: userID)?.following.contains(me.id) == true)
    }

    func block(userID: String) { guard let me = currentUserID, me != userID else { return }; blockedByUser[me, default: []].insert(userID); toggleFollowOffIfNeeded(me: me, userID: userID); changedAndPersist() }
    func unblock(userID: String) { guard let me = currentUserID else { return }; blockedByUser[me, default: []].remove(userID); changedAndPersist() }
    private func toggleFollowOffIfNeeded(me: String, userID: String) { guard let mine = users.firstIndex(where: { $0.id == me }), let theirs = users.firstIndex(where: { $0.id == userID }) else { return }; users[mine].following.remove(userID); users[mine].followers.remove(userID); users[theirs].following.remove(me); users[theirs].followers.remove(me) }

    func report(targetID: String, reason: String, detail: String) {
        reports.append(ReportRecord(id: UUID().uuidString, targetID: targetID, reason: reason, detail: detail, date: Date()))
        changedAndPersist()
    }

    func join(roomID: String) {
        guard let userID = currentUserID, let index = rooms.firstIndex(where: { $0.id == roomID }) else { return }
        rooms[index].members.insert(userID)
        changedAndPersist()
    }

    func enter(roomID: String) {
        guard let index = rooms.firstIndex(where: { $0.id == roomID }) else { return }
        rooms[index].online += 1
        rooms[index].participantCount += 1
        rooms[index].capacity += 1
        changedAndPersist()
    }

    func leave(roomID: String) {
        guard let index = rooms.firstIndex(where: { $0.id == roomID }) else { return }
        rooms[index].online = max(0, rooms[index].online - 1)
        rooms[index].participantCount = max(0, rooms[index].participantCount - 1)
        rooms[index].capacity = max(rooms[index].participantCount, rooms[index].capacity - 1)
        changedAndPersist()
    }

    func sendRoomMessage(roomID: String, text: String, isVoice: Bool = false, audioFileName: String? = nil, voiceDuration: Double? = nil) {
        guard let userID = currentUserID, let index = rooms.firstIndex(where: { $0.id == roomID }), !text.isEmpty else { return }
        rooms[index].messages.append(ChatMessage(id: UUID().uuidString, senderID: userID, text: text, timestamp: Date(), isVoice: isVoice, audioFileName: audioFileName, voiceDuration: voiceDuration))
        changedAndPersist()
    }

    func sendDirectMessage(peerID: String, text: String, isVoice: Bool = false, audioFileName: String? = nil, voiceDuration: Double? = nil) {
        guard let userID = currentUserID, !blocked.contains(peerID), !text.isEmpty else { return }
        let message = ChatMessage(id: UUID().uuidString, senderID: userID, text: text, timestamp: Date(), isVoice: isVoice, audioFileName: audioFileName, voiceDuration: voiceDuration)
        if let index = conversations.firstIndex(where: { $0.ownerID == userID && $0.peerID == peerID }) { conversations[index].messages.append(message); conversations[index].unread = 0 }
        else { conversations.append(Conversation(id: UUID().uuidString, peerID: peerID, messages: [message], unread: 0, ownerID: userID)) }
        changedAndPersist()
    }

    @discardableResult
    func spendCoins(_ amount: Int) -> Bool {
        guard let id = currentUserID, let index = users.firstIndex(where: { $0.id == id }), users[index].coins >= amount else { return false }
        users[index].coins -= amount
        changedAndPersist()
        return true
    }

    func addCoins(_ amount: Int) {
        guard let id = currentUserID, let index = users.firstIndex(where: { $0.id == id }) else { return }
        users[index].coins += amount
        changedAndPersist()
    }

    func sendAIMessage(_ text: String) {
        guard let userID = currentUserID else { return }
        aiMessagesByUser[userID, default: []].append(ChatMessage(id: UUID().uuidString, senderID: userID, text: text, timestamp: Date(), isVoice: false))
        if aiFreeMessages > 0 { aiFreeMessagesByUser[userID] = aiFreeMessages - 1 }
        let response = AdventureReplyLibrary.answer(to: text)
        aiMessagesByUser[userID, default: []].append(ChatMessage(id: UUID().uuidString, senderID: "assistant", text: response, timestamp: Date(), isVoice: false))
        changedAndPersist()
    }

    func publish(category: String, title: String, location: String, story: String, duration: String = "Weekend", highlights: String? = nil, mediaRecords: [String] = []) -> String? {
        guard let id = currentUserID, !title.isEmpty, !story.isEmpty else { return nil }
        let post = AdventurePost(id: UUID().uuidString, authorID: id, category: category, title: title, location: location, story: story, likes: 0, comments: [], likedBy: [], savedBy: [], duration: duration, highlights: highlights ?? title, createdAt: Date(), mediaRecords: mediaRecords)
        posts.insert(post, at: 0)
        changedAndPersist()
        return post.id
    }

    func savePassport(postID: String, template: String) {
        passports.append(PassportRecord(id: UUID().uuidString, postID: postID, template: template))
        changedAndPersist()
    }

    private func changedAndPersist() {
        persist()
        NotificationCenter.default.post(name: Self.changed, object: self)
    }

    private func persist() {
        let value = Snapshot(users: users, posts: posts, rooms: rooms, conversations: conversations, reports: reports, passports: passports, blocked: legacyBlocked, blockedByUser: blockedByUser, session: session, currentUserID: currentUserID, aiMessages: legacyAIMessages, aiFreeMessages: legacyAIFreeMessages, aiMessagesByUser: aiMessagesByUser, aiFreeMessagesByUser: aiFreeMessagesByUser)
        if let data = try? JSONEncoder().encode(value) { UserDefaults.standard.set(data, forKey: Key.snapshot) }
    }

    private func apply(_ value: Snapshot) {
        users = value.users; posts = value.posts; rooms = value.rooms; conversations = value.conversations
        reports = value.reports; passports = value.passports; legacyBlocked = value.blocked; session = value.session
        currentUserID = value.currentUserID; legacyAIMessages = value.aiMessages; legacyAIFreeMessages = value.aiFreeMessages
        blockedByUser = value.blockedByUser ?? (value.currentUserID.map { [$0: value.blocked] } ?? [:])
        aiMessagesByUser = value.aiMessagesByUser ?? (value.currentUserID.map { [$0: value.aiMessages] } ?? [:])
        aiFreeMessagesByUser = value.aiFreeMessagesByUser ?? (value.currentUserID.map { [$0: value.aiFreeMessages] } ?? [:])
        conversations = conversations.map { value in var copy = value; if copy.ownerID.isEmpty { copy.ownerID = currentUserID ?? "user-test" }; return copy }
        // Older builds stored fake voice bubbles with no audio file. They are
        // deliberately discarded so every visible voice message is playable.
        conversations = conversations.map { value in var copy = value; copy.messages.removeAll { $0.isVoice && $0.audioFileName == nil }; return copy }
        rooms = rooms.map { value in var copy = value; copy.messages.removeAll { $0.isVoice && $0.audioFileName == nil }; return copy }
    }
}
