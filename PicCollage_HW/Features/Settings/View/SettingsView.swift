//
//  SettingsView.swift
//  PicCollage_HW
//
//  Created by Claude Code on 2025/11/14.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: MusicEditorViewModel
    var onBack: () -> Void

    // MARK: - State
    @State private var totalDurationText: String = ""
    @State private var keyTimeFields: [KeyTimeField] = []
    @State private var timelineLengthText: String = ""

    @State private var showAlert = false
    @State private var alertTitle = "Invalid Input"
    @State private var alertMessage = ""

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Total Track Length Section
                totalDurationSection

                // KeyTime Points Section
                keyTimesSection

                // Timeline Length Section
                timelineLengthSection

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemBackground))
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .bottom) {
            actionButtons
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            loadCurrentSettings()
            // Pause playback when entering settings
            if viewModel.isPlaying {
                viewModel.togglePlayPause()
            }
        }
    }
}

// MARK: - View Components
extension SettingsView {
    private var totalDurationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Track Length (seconds)")
                .font(.system(size: 16, weight: .semibold))

            TextField("e.g., 80.0", text: $totalDurationText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(height: 44)
        }
    }

    private var keyTimesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("KeyTime Points (as % of total length)")
                .font(.system(size: 16, weight: .semibold))

            ForEach(keyTimeFields) { field in
                keyTimeRow(field: field)
            }

            Button {
                addKeyTimeField()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add KeyTime Point")
                }
                .font(.system(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
        }
    }

    private func keyTimeRow(field: KeyTimeField) -> some View {
        HStack(spacing: 12) {
            TextField("e.g., 12.5", text: binding(for: field))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(height: 44)

            Button {
                deleteKeyTimeField(field)
            } label: {
                Text("Delete")
                    .foregroundColor(.red)
                    .frame(width: 70)
            }
        }
    }

    private var timelineLengthSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Timeline Length (% of total)")
                .font(.system(size: 16, weight: .semibold))

            TextField("e.g., 12.5", text: $timelineLengthText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(height: 44)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                saveSettings()
            } label: {
                Text("Save Changes")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            Button {
                onBack()
            } label: {
                Text("Back")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Private Methods
extension SettingsView {
    private func loadCurrentSettings() {
        let settings = viewModel.getCurrentSettings()

        // Load total duration
        totalDurationText = String(format: "%.1f", settings.totalDuration)

        // Load keyTimes as percentages
        keyTimeFields = settings.keyTimePercentages.map { percentage in
            KeyTimeField(value: String(format: "%.1f", percentage))
        }

        // Load timeline length percentage
        if let timelinePercentage = settings.timelineLengthPercentage {
            timelineLengthText = String(format: "%.1f", timelinePercentage)
        }
    }

    private func addKeyTimeField() {
        keyTimeFields.append(KeyTimeField(value: ""))
    }

    private func deleteKeyTimeField(_ field: KeyTimeField) {
        keyTimeFields.removeAll { $0.id == field.id }
    }

    private func binding(for field: KeyTimeField) -> Binding<String> {
        guard let index = keyTimeFields.firstIndex(where: { $0.id == field.id }) else {
            return .constant("")
        }

        return Binding(
            get: { keyTimeFields[index].value },
            set: { keyTimeFields[index].value = $0 }
        )
    }

    private func saveSettings() {
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        do {
            let settings = try collectInputData()
            try viewModel.applySettings(settings)
            showAlertMessage(title: "Success", message: "Settings saved successfully!")
        } catch let error as SettingsValidator.ValidationError {
            showAlertMessage(title: "Invalid Input", message: error.localizedDescription)
        } catch {
            showAlertMessage(title: "Error", message: "An unexpected error occurred")
        }
    }

    private func collectInputData() throws -> MusicEditorSettings {
        // Collect total duration
        guard let totalDuration = Double(totalDurationText) else {
            throw SettingsValidator.ValidationError.invalidTotalDuration
        }

        // Collect keyTime percentages
        let keyTimePercentages = try collectKeyTimePercentages()

        // Collect timeline length percentage (optional)
        let timelinePercentage = collectTimelinePercentage()

        return MusicEditorSettings(
            totalDuration: CGFloat(totalDuration),
            keyTimePercentages: keyTimePercentages,
            timelineLengthPercentage: timelinePercentage
        )
    }

    private func collectKeyTimePercentages() throws -> [CGFloat] {
        var percentages: [CGFloat] = []

        for field in keyTimeFields {
            guard !field.value.isEmpty else {
                continue
            }

            guard let percentage = Double(field.value) else {
                throw SettingsValidator.ValidationError.invalidKeyTimePercentage
            }

            percentages.append(CGFloat(percentage))
        }

        return percentages
    }

    private func collectTimelinePercentage() -> CGFloat? {
        guard !timelineLengthText.isEmpty,
              let percentage = Double(timelineLengthText) else {
            return nil
        }
        return CGFloat(percentage)
    }

    private func showAlertMessage(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Supporting Types
struct KeyTimeField: Identifiable, Equatable {
    let id = UUID()
    var value: String
}

// MARK: - Preview
#Preview {
    let musicState = MusicStateModel(
        totalDuration: 80.0,
        currentTime: 0.0,
        keyTimes: [16.0, 40.0, 48.0, 72.0],
        selectedRange: TrimmerRangeModel(start: 0.0, duration: 10.0)
    )
    let viewModel = MusicEditorViewModel(state: musicState)

    SettingsView(viewModel: viewModel) {
        print("Back tapped")
    }
}
