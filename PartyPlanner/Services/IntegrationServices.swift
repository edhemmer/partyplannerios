import Foundation
import MapKit
import EventKit
import UserNotifications

enum CalendarIntegration {
    static func eventStoreAuthorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }
}

enum DirectionsIntegration {
    static func mapItem(for venue: Venue) -> MKMapItem {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: venue.coordinate))
        item.name = venue.name
        return item
    }
}

enum NotificationIntegration {
    static func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }
}

extension Venue {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude ?? 40.7128, longitude: longitude ?? -74.0060)
    }
}
