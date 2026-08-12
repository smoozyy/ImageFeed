import Foundation
import WebKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
    private var oauth2TokenStorage = OAuth2TokenStorage.shared
    private var profileService = ProfileService.shared
    private var profileImageService = ProfileImageService.shared
    private var imagesListService = ImagesListService.shared
  
   private init() { }

   func logout() {
      cleanCookies()
       oauth2TokenStorage.token = nil
       profileService.clean()
       profileImageService.clean()
       imagesListService.clean()
       
       DispatchQueue.main.async { [weak self] in
           guard let self else {return}
           switchToSplashViewController()
       }
   }
    
   private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            
         }
      }
   }
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({$0 as? UIWindowScene})
            .flatMap({$0.windows})
            .first(where: {$0.isKeyWindow}) else {return}
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}
    
