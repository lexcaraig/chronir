import SwiftUI

struct TimesOfDayPicker: View {
    @Binding var times: [TimeOfDay]
    @State private var editingIndex: Int?
    @State private var isEditing = false
    @State private var editDate = Date()
    @State private var isAdding = false
    @State private var addDate = Date()

    private let maxTimes = 5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ChronirText("Times", style: .labelMedium, color: ColorTokens.textSecondary)
                .accessibilityAddTraits(.isHeader)
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

    /// The edit chip and its remove button are siblings (never a button inside a button), so each
    /// has its own 44pt target and VoiceOver reaches both.
    private func timeChip(_ time: TimeOfDay, at index: Int) -> some View {
        HStack(spacing: 0) {
            ChronirChip(
                time.formatted,
                isSelected: true,
                isToggle: false,
                accessibilityLabel: "Alarm time \(time.formatted)"
            ) {
                editDate = time.asDateToday()
                editingIndex = index
                isEditing = true
            }
            .accessibilityHint("Edit this time")
            .accessibilityAction(named: "Remove") {
                if times.count > 1 { remove(at: index) }
            }

            if times.count > 1 {
                Button {
                    remove(at: index)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundStyle(ColorTokens.textSecondary)
                        .frame(minWidth: SpacingTokens.touchMinTarget, minHeight: SpacingTokens.touchMinTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove \(time.formatted)")
            }
        }
        .contextMenu {
            if times.count > 1 {
                Button("Remove \(time.formatted)", systemImage: "trash", role: .destructive) {
                    remove(at: index)
                }
            }
        }
    }

    private var addButton: some View {
        ChronirChip(
            "Add",
            systemImage: "plus",
            isSelected: false,
            isToggle: false,
            accessibilityLabel: "Add alarm time"
        ) {
            addDate = Date()
            isAdding = true
        }
    }

    private func remove(at index: Int) {
        let animation = AnimationTokens.resolved(
            AnimationTokens.spring,
            reduceMotion: reduceMotion,
            reducedFallback: AnimationTokens.fast
        )
        withAnimation(animation) {
            removeTime(at: index)
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

private struct TimesOfDayPickerPreview: View {
    @State var times: [TimeOfDay]

    var body: some View {
        TimesOfDayPicker(times: $times)
            .padding()
    }
}

#Preview("Light") {
    TimesOfDayPickerPreview(times: [
        TimeOfDay(hour: 9, minute: 0),
        TimeOfDay(hour: 12, minute: 0),
        TimeOfDay(hour: 17, minute: 0)
    ])
    .background(ColorTokens.backgroundPrimary)
}

#Preview("Dark — Single Time") {
    DarkPreview { TimesOfDayPickerPreview(times: [TimeOfDay(hour: 8, minute: 0)]) }
}
