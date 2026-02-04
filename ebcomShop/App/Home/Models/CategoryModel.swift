
// MARK: - Categories

struct CategoryModel: Decodable, Sendable, Identifiable {
    let id: String
    let title: String
    let iconUrl: String
    let status: String?
}