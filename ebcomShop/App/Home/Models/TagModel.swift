// MARK: - Tags & Labels (minimal for display)

struct TagModel: Decodable, Sendable, Identifiable {
    let id: String
    let title: String?
    let iconUrl: String?
    let status: String?
}

struct LabelModel: Decodable, Sendable, Identifiable {
    let id: String
    let title: String?
    let status: String?
}