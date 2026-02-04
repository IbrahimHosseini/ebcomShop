// MARK: - View-ready section items (order preserved from API)

enum HomeSectionItem: Sendable {
    case category(title: String?, items: [CategoryModel])
    case banner(items: [BannerModel])
    case shop(title: String?, items: [ShopModel])
    case fixedBanner(title: String?, items: [BannerModel])
}