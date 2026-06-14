import SwiftUI
import MapKit

struct VenueMapView: View {
    var venue: Venue
    @State private var position: MapCameraPosition

    init(venue: Venue) {
        self.venue = venue
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: venue.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Venue", icon: "map", color: .blue)
            Map(position: $position) {
                Marker(venue.name, coordinate: venue.coordinate)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(venue.name)
                    .font(.headline)
                Text(venue.address)
                    .foregroundStyle(.secondary)
                Label(venue.arrivalWindow, systemImage: "clock")
                Label(venue.parkingNotes, systemImage: "parkingsign.circle")
            }
            .font(.subheadline)
        }
    }
}

#Preview {
    VenueMapView(venue: PartyEvent.summerBirthday.venue)
}
