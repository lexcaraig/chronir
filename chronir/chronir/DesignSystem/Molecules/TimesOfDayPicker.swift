import SwiftUI

struct TimesOfDayPicker: View {
    @Binding var times: [TimeOfDay]
    @State private var editingIndex: Int?
    @State private var isEditing = false
    @State private var editDate = Date()
    @State private var isAdding = false
    @State private var addDate = Date()

    private let maxTimes = 5

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Times", style: .labelMedium, color: ColorTokens.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpacingTokens.sm) {
                    ForEach(Array(sortedTimes.enumerated()), id: \.element) { index, time in
                        timeChip(time, at: index)
                    }
                    if sortedTimes.count < maxTimes {
                        addButton
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            timeEditSheet
        }
        .sheet(isPresented: $isAdding) {
            addTimeSheet
        }
    }

    private var sortedTimes: [TimeOfDay] {
        times.sorted()
    }

    private func timeChip(_ time: TimeOfDay, at index: Int) -> some View {
        Button {
            editDate = time.asDateToday()
            editingIndex = index
            isEditing = true
        } label: {
            HStack(spacing: SpacingTokens.xxs) {
                Text(time.formatted)
                    .chronirFont(.labelLarge)
                if times.count > 1 {
                    Button {
                        withAnimation { removeTime(at: index) }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .chronirFont(.labelSmall)
                    }
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, SpacingTokens.md)
            .padding(.vertical, SpacingTokens.sm)
            .chronirGlassTintedCapsule(tint: ColorTokens.primary)
        }
    }

    private var addButton: some View {
        Button {
            addDate = Date()
            isAdding = true
        } label: {
            Image(systemName: "plus")
                .chronirFont(.labelLarge)
                .foregroundStyle(ColorTokens.textSecondary)
                .padding(.horizontal, SpacingTokens.md)
                .padding(.vertical, SpacingTokens.sm)
                .chronirGlassCapsule()
        }
    }

    private var timeEditSheet: some View {
        NavigationStack {
            DatePicker("Time", selection: $editDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                .navigationTitle("Edit Time")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { isEditing = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            if let index = editingIndex {
                                let newTime = TimeOfDay(from: editDate)
                                updateTime(at: index, to: newTime)
                            }
                            isEditing = false
                        }
                        .foregroundStyle(ColorTokens.primary)
                    }
                }
        }
        .presentationDetents([.medium])
    }

    private var addTimeSheet: some View {
        NavigationStack {
            DatePicker("Time", selection: $addDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                .navigationTitle("Add Time")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { isAdding = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let newTime = TimeOfDay(from: addDate)
                            addTime(newTime)
                            isAdding = false
                        }
                        .foregroundStyle(ColorTokens.primary)
                    }
                }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Actions

    private func removeTime(at index: Int) {
        let sorted = sortedTimes
        guard sorted.count > 1 else { return }
        let timeToRemove = sorted[index]
        times.removeAll { $0 == timeToRemove }
    }

    private func updateTime(at index: Int, to newTime: TimeOfDay) {
        let sorted = sortedTimes
        guard index < sorted.count else { return }
        let oldTime = sorted[index]
        if let existing = times.firstIndex(of: oldTime) {
            times[existing] = newTime
        }
        // Deduplicate
        times = Array(Set(times))
    }

    private func addTime(_ time: TimeOfDay) {
        guard times.count < maxTimes else { return }
        if !times.contains(time) {
            times.append(time)
        }
    }
}

#Preview {
    @Previewable @State var times: [TimeOfDay] = [
        TimeOfDay(hour: 9, minute: 0),
        TimeOfDay(hour: 12, minute: 0),
        TimeOfDay(hour: 17, minute: 0)
    ]
    TimesOfDayPicker(times: $times)
        .padding()
        .background(ColorTokens.backgroundPrimary)
}

#Preview("Single Time") {
    @Previewable @State var times: [TimeOfDay] = [TimeOfDay(hour: 8, minute: 0)]
    TimesOfDayPicker(times: $times)
        .padding()
        .background(ColorTokens.backgroundPrimary)
}
