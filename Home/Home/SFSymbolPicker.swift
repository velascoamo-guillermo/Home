import SwiftUI

struct SFSymbolPicker: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                    ForEach(filtered, id: \.self) { sym in
                        Button {
                            selection = sym
                            dismiss()
                        } label: {
                            Image(systemName: sym)
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .foregroundStyle(selection == sym ? .white : .primary)
                                .background(selection == sym ? Color.accentColor : Color(.secondarySystemFill))
                                .clipShape(.rect(cornerRadius: 10))
                        }
                        .accessibilityLabel(sym)
                    }
                }
                .padding()
            }
            .searchable(text: $query, prompt: "Search symbols")
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var filtered: [String] {
        query.isEmpty ? Self.symbols : Self.symbols.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    static let symbols: [String] = [
        // Home & Rooms
        "house", "house.fill", "house.lodge", "house.lodge.fill",
        "building.2", "building.2.fill", "building.columns", "building.columns.fill",
        "door.left.hand.open", "door.left.hand.closed",
        "window.casement.open", "window.casement.closed",
        "window.vertical.open", "window.shade.open",
        "bed.double", "bed.double.fill", "sofa", "sofa.fill",
        "chair.lounge", "chair.lounge.fill",
        "table.furniture", "table.furniture.fill",
        "bathtub", "bathtub.fill", "shower", "shower.fill", "toilet", "toilet.fill",

        // Utilities
        "drop", "drop.fill", "flame", "flame.fill",
        "bolt", "bolt.fill", "bolt.circle", "bolt.circle.fill",
        "thermometer.medium", "thermometer.sun", "thermometer.sun.fill",
        "thermometer.snowflake",
        "fan", "fan.fill", "fan.ceiling", "fan.ceiling.fill",
        "lightbulb", "lightbulb.fill", "lightbulb.circle", "lightbulb.circle.fill",
        "lightbulb.led", "lightbulb.led.fill",
        "power", "powerplug", "powerplug.fill",
        "air.purifier", "air.purifier.fill",
        "humidity", "humidity.fill",
        "wind", "snowflake",

        // Tools & Repairs
        "wrench", "wrench.fill",
        "wrench.and.screwdriver", "wrench.and.screwdriver.fill",
        "wrench.adjustable", "wrench.adjustable.fill",
        "hammer", "hammer.fill", "hammer.circle", "hammer.circle.fill",
        "screwdriver", "screwdriver.fill",
        "pliers",
        "ruler", "ruler.fill",
        "paintbrush", "paintbrush.fill", "paintbrush.pointed", "paintbrush.pointed.fill",
        "level", "level.fill",

        // Cleaning
        "trash", "trash.fill",
        "bubbles.and.sparkles", "bubbles.and.sparkles.fill",
        "sparkle", "sparkles",
        "shower.handheld", "shower.handheld.fill",
        "washer", "washer.fill", "dryer", "dryer.fill",
        "vacuum", "vacuum.fill",

        // Garden & Nature
        "leaf", "leaf.fill", "leaf.circle", "leaf.circle.fill",
        "tree", "tree.fill", "tree.circle", "tree.circle.fill",
        "flower", "flower.fill", "flower.circle",
        "sun.max", "sun.max.fill", "sun.and.horizon", "sun.and.horizon.fill",
        "moon", "moon.fill", "moon.stars", "moon.stars.fill",
        "cloud.rain", "cloud.rain.fill", "cloud.snow", "cloud.snow.fill",
        "cloud.sun", "cloud.sun.fill",
        "scissors", "scissors.fill",
        "shovel", "shovel.fill",
        "sprinkler.and.droplets", "sprinkler.and.droplets.fill",

        // Pets & Animals
        "pawprint", "pawprint.fill", "pawprint.circle", "pawprint.circle.fill",
        "cat", "cat.fill", "cat.circle", "cat.circle.fill",
        "dog", "dog.fill", "dog.circle", "dog.circle.fill",
        "bird", "bird.fill", "bird.circle", "bird.circle.fill",
        "fish", "fish.fill", "fish.circle", "fish.circle.fill",
        "hare", "hare.fill",
        "tortoise", "tortoise.fill",
        "lizard", "lizard.fill",
        "ant", "ant.fill", "ant.circle", "ant.circle.fill",
        "ladybug", "ladybug.fill",

        // Kitchen & Food
        "fork.knife", "fork.knife.circle", "fork.knife.circle.fill",
        "cup.and.saucer", "cup.and.saucer.fill",
        "mug", "mug.fill",
        "refrigerator", "refrigerator.fill",
        "stove", "stove.fill",
        "oven", "oven.fill",
        "microwave", "microwave.fill",
        "dishwasher", "dishwasher.fill",
        "wineglass", "wineglass.fill",
        "birthday.cake", "birthday.cake.fill",

        // Storage & Organization
        "shippingbox", "shippingbox.fill",
        "archivebox", "archivebox.fill",
        "tray", "tray.fill", "tray.2", "tray.2.fill",
        "folder", "folder.fill",
        "cabinet", "cabinet.fill",
        "books.vertical", "books.vertical.fill",
        "basket", "basket.fill",

        // Security
        "lock", "lock.fill", "lock.open", "lock.open.fill",
        "key", "key.fill", "key.horizontal", "key.horizontal.fill",
        "bell", "bell.fill", "bell.badge", "bell.badge.fill",
        "shield", "shield.fill", "shield.checkered",
        "camera", "camera.fill",
        "video", "video.fill",
        "eye", "eye.fill",

        // Finance & Bills
        "creditcard", "creditcard.fill",
        "banknote", "banknote.fill",
        "cart", "cart.fill",
        "dollarsign.circle", "dollarsign.circle.fill",
        "eurosign.circle", "eurosign.circle.fill",
        "bag", "bag.fill",
        "chart.bar", "chart.bar.fill",
        "chart.pie", "chart.pie.fill",

        // Health & Safety
        "cross", "cross.fill", "cross.case", "cross.case.fill",
        "cross.circle", "cross.circle.fill",
        "bandage", "bandage.fill",
        "heart", "heart.fill", "heart.circle", "heart.circle.fill",
        "smoke", "smoke.fill",
        "staroflife", "staroflife.fill",
        "pill", "pill.fill", "pill.circle", "pill.circle.fill",
        "stethoscope", "stethoscope.circle",
        "syringe", "syringe.fill",

        // Transport & Car
        "car", "car.fill", "car.2", "car.2.fill",
        "car.circle", "car.circle.fill",
        "fuelpump", "fuelpump.fill", "fuelpump.circle", "fuelpump.circle.fill",
        "bicycle", "scooter", "bus", "bus.fill",
        "tram", "tram.fill",
        "airplane", "airplane.circle", "airplane.circle.fill",
        "ferry", "ferry.fill",

        // Technology
        "wifi", "wifi.circle", "wifi.circle.fill",
        "network",
        "antenna.radiowaves.left.and.right",
        "tv", "tv.fill", "tv.circle", "tv.circle.fill",
        "desktopcomputer", "laptopcomputer",
        "printer", "printer.fill",
        "phone", "phone.fill", "iphone",
        "gamecontroller", "gamecontroller.fill",
        "headphones", "headphones.circle",
        "speaker.wave.2", "speaker.wave.2.fill",
        "music.note", "music.note.list",

        // People & Family
        "person", "person.fill", "person.circle", "person.circle.fill",
        "person.2", "person.2.fill", "person.2.circle", "person.2.circle.fill",
        "person.3", "person.3.fill",
        "figure.child", "figure.child.circle",
        "figure.walk", "figure.walk.circle",
        "figure.run", "figure.run.circle",
        "figure.2.and.child.holdinghands",

        // Miscellaneous
        "star", "star.fill", "star.circle", "star.circle.fill",
        "checkmark.circle", "checkmark.circle.fill",
        "clock", "clock.fill", "alarm", "alarm.fill",
        "calendar", "calendar.badge.plus", "calendar.circle", "calendar.circle.fill",
        "note.text", "list.bullet", "list.bullet.clipboard", "checklist",
        "tag", "tag.fill", "tag.circle", "tag.circle.fill",
        "flag", "flag.fill", "flag.circle", "flag.circle.fill",
        "bookmark", "bookmark.fill",
        "mappin", "mappin.fill", "mappin.circle", "mappin.circle.fill",
        "map", "map.fill",
        "paintpalette", "paintpalette.fill",
        "gear", "gearshape", "gearshape.fill", "gearshape.2", "gearshape.2.fill",
        "magnifyingglass", "magnifyingglass.circle",
        "envelope", "envelope.fill", "envelope.circle",
        "gift", "gift.fill", "gift.circle", "gift.circle.fill",
        "party.popper", "party.popper.fill",
        "house.and.flag", "house.and.flag.fill",
    ]
}
