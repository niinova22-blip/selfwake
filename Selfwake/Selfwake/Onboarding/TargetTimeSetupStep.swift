import SwiftUI

struct TargetTimeSetupStep: View {
    @Binding var targetTime: Date

    var body: some View {
        VStack(spacing: 20) {
            Text("İlk hedefin")
                .font(.title2.bold())
            Text("Yarın sabah uyanmak istediğin saat.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
            DatePicker("", selection: $targetTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
