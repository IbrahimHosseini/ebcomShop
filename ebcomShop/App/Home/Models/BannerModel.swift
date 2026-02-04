// MARK: - Banners

struct BannerModel: Decodable, Sendable, Identifiable {
    let id: String
    let imageUrl: String
}