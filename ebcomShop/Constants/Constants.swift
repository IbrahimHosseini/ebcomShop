import Foundation

typealias ResponseResult<T> = Result<T, NetworkError>

enum Constants {
    
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
}
