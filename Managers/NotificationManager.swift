import UserNotifications
import Foundation

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func schedule(id: String, petName: String, recordName: String,
                  type: HealthRecordType, date: Date) {
        let title = "\(petName) — \(type.rawValue)"
        fire(id: id, title: title, body: "Está na altura: \(recordName)", date: date)

        if let reminder = Calendar.current.date(byAdding: .day, value: -3, to: date),
           reminder > .now {
            fire(id: "\(id)_3d", title: "\(petName) — Lembrete",
                 body: "\(recordName) em 3 dias", date: reminder)
        }
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id, "\(id)_3d"])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }

    private func fire(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        comps.hour = 9
        comps.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
