import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("[DEBUG] iOS - 🚀 Application launching...")
    
    // Configure Firebase
    do {
      FirebaseApp.configure()
      print("[DEBUG] iOS - ✅ Firebase configured successfully")
    } catch {
      print("[ERROR] iOS - ❌ Firebase configuration failed: \(error)")
    }
    
    // Configure Push Notifications
    print("[DEBUG] iOS - 🔔 Setting up push notifications...")
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self
    
    // Request authorization for notifications
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound]
    ) { granted, error in
      if granted {
        print("[DEBUG] iOS - ✅ Notification authorization granted")
        DispatchQueue.main.async {
          print("[DEBUG] iOS - 🔄 Registering for remote notifications...")
          application.registerForRemoteNotifications()
        }
      } else {
        print("[ERROR] iOS - ❌ Notification authorization denied: \(error?.localizedDescription ?? "Unknown error")")
      }
    }
    
    // Check current notification settings
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      print("[DEBUG] iOS - 📱 Current notification settings:")
      print("  - Authorization status: \(settings.authorizationStatus.rawValue)")
      print("  - Sound enabled: \(settings.soundSetting.rawValue)")
      print("  - Badge enabled: \(settings.badgeSetting.rawValue)")
      print("  - Alert enabled: \(settings.alertSetting.rawValue)")
      print("  - Notification center enabled: \(settings.notificationCenterSetting.rawValue)")
      print("  - Lock screen enabled: \(settings.lockScreenSetting.rawValue)")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle updated APNS token
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Convert token to string for logging
    let tokenParts = deviceToken.map { data -> String in
      return String(format: "%02.2hhx", data)
    }
    let token = tokenParts.joined()
    print("[DEBUG] iOS - 📱 APNs token received: \(token)")
    
    // Set APNs token for Firebase
    print("[DEBUG] iOS - 🔄 Setting APNs token in Firebase...")
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    
    // Verify token was set
    if let currentToken = Messaging.messaging().apnsToken {
      print("[DEBUG] iOS - ✅ APNs token verified in Firebase")
    } else {
      print("[ERROR] iOS - ❌ Failed to verify APNs token in Firebase")
    }
  }
  
  // Handle APNS registration errors
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("[ERROR] iOS - ❌ Failed to register for remote notifications:")
    print("  - Error: \(error.localizedDescription)")
    print("  - Error code: \((error as NSError).code)")
    print("  - Error domain: \((error as NSError).domain)")
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("[DEBUG] iOS - 🔑 FCM Token received: \(fcmToken ?? "none")")
    
    // Log additional information about the token
    if let token = fcmToken {
      print("[DEBUG] iOS - 📊 FCM Token details:")
      print("  - Length: \(token.count) characters")
      print("  - Format: \(token.prefix(10))...\(token.suffix(10))")
    }
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate {
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    print("[DEBUG] iOS - 📬 Received notification in foreground:")
    print("  - Title: \(notification.request.content.title)")
    print("  - Body: \(notification.request.content.body)")
    print("  - User Info: \(userInfo)")
    
    // Show notification even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
  
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("[DEBUG] iOS - 👆 Notification tapped:")
    print("  - Title: \(response.notification.request.content.title)")
    print("  - Body: \(response.notification.request.content.body)")
    print("  - User Info: \(userInfo)")
    
    // Send data to Flutter
    if let flutterVC = window?.rootViewController as? FlutterViewController {
      print("[DEBUG] iOS - 🔄 Sending notification data to Flutter...")
      let channel = FlutterMethodChannel(
        name: "com.omnidoc.regulation/notification",
        binaryMessenger: flutterVC.binaryMessenger
      )
      channel.invokeMethod("openScreen", arguments: userInfo)
    } else {
      print("[ERROR] iOS - ❌ Failed to get FlutterViewController")
    }
    
    completionHandler()
  }
}
