import SwiftUI

struct ReminderSetupStep: View {
    @Binding var reminderTime: Date

    var body: some View {
        VStack(spacing: 20) {
            Text("Ritüel hatırlatıcısı")
                .font(.title2.bold())
            Text("Her gece bu saatte, ritüele başlaman için nazik bir hatırlatma.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
