//
//  SettingViewController.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/4.
//

import UIKit

class SettingViewController: UIViewController {
    private let viewModel: MusicEditorViewModel
    weak var coordinator: MainCoordinator?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // Total Track Length Section
    private let totalDurationLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Track Length (seconds)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let totalDurationTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.placeholder = "e.g., 80.0"
        return textField
    }()

    // KeyTime Points Section
    private let keyTimesLabel: UILabel = {
        let label = UILabel()
        label.text = "KeyTime Points (as % of total length)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let keyTimesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    private let addKeyTimeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add KeyTime Point", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        return button
    }()

    // Timeline Length Section
    private let timelineLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "Timeline Length (% of total, optional)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let timelineLengthTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.placeholder = "e.g., 12.5"
        return textField
    }()

    // Action Buttons
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Constants
    private enum UIConstants {
        static let textFieldHeight: CGFloat = 44
        static let deleteButtonWidth: CGFloat = 70
        static let buttonSpacing: CGFloat = 12
    }

    // MARK: - Initialization
    init(viewModel: MusicEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardToolbar()
        loadCurrentSettings()
        setupActions()
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Settings"

        // Add scrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        // Add sections to stack view
        let totalDurationSection = createSection(label: totalDurationLabel, content: totalDurationTextField)
        contentStackView.addArrangedSubview(totalDurationSection)

        let keyTimesSection = createKeyTimesSection()
        contentStackView.addArrangedSubview(keyTimesSection)

        let timelineLengthSection = createSection(label: timelineLengthLabel, content: timelineLengthTextField)
        contentStackView.addArrangedSubview(timelineLengthSection)

        // Add action buttons
        view.addSubview(saveButton)
        view.addSubview(backButton)

        // Setup constraints
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),

            // ContentStackView
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),

            // Save Button
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -12),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            // Back Button
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            backButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func createSection(label: UILabel, content: UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        label.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        container.addSubview(content)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            content.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])

        return container
    }

    private func createKeyTimesSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        keyTimesLabel.translatesAutoresizingMaskIntoConstraints = false
        keyTimesStackView.translatesAutoresizingMaskIntoConstraints = false
        addKeyTimeButton.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(keyTimesLabel)
        container.addSubview(keyTimesStackView)
        container.addSubview(addKeyTimeButton)

        NSLayoutConstraint.activate([
            keyTimesLabel.topAnchor.constraint(equalTo: container.topAnchor),
            keyTimesLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            keyTimesLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            keyTimesStackView.topAnchor.constraint(equalTo: keyTimesLabel.bottomAnchor, constant: 8),
            keyTimesStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            keyTimesStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            addKeyTimeButton.topAnchor.constraint(equalTo: keyTimesStackView.bottomAnchor, constant: 12),
            addKeyTimeButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            addKeyTimeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            addKeyTimeButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        return container
    }

    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))

        toolbar.items = [flexSpace, doneButton]

        totalDurationTextField.inputAccessoryView = toolbar
        timelineLengthTextField.inputAccessoryView = toolbar
    }

    private func loadCurrentSettings() {
        let settings = viewModel.getCurrentSettings()

        // Load total duration
        totalDurationTextField.text = String(format: "%.1f", settings.totalDuration)

        // Load keyTimes as percentages
        for percentage in settings.keyTimePercentages {
            addKeyTimeRow(percentage: percentage)
        }

        // Load timeline length (selectedRange duration) as percentage
        if let timelinePercentage = settings.timelineLengthPercentage {
            timelineLengthTextField.text = String(format: "%.1f", timelinePercentage)
        }
    }

    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        addKeyTimeButton.addTarget(self, action: #selector(addKeyTimeButtonTapped), for: .touchUpInside)
    }

    // MARK: - KeyTime Row Management
    private func addKeyTimeRow(percentage: Double? = nil) {
        let rowContainer = UIView()
        rowContainer.translatesAutoresizingMaskIntoConstraints = false

        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.placeholder = "e.g., 12.5"
        textField.text = percentage.map { String(format: "%.1f", $0) }
        textField.translatesAutoresizingMaskIntoConstraints = false

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar

        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteKeyTimeRow(_:)), for: .touchUpInside)

        rowContainer.addSubview(textField)
        rowContainer.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor),
            textField.centerYAnchor.constraint(equalTo: rowContainer.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -UIConstants.buttonSpacing),
            textField.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),

            deleteButton.trailingAnchor.constraint(equalTo: rowContainer.trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: rowContainer.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: UIConstants.deleteButtonWidth),

            rowContainer.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight)
        ])

        keyTimesStackView.addArrangedSubview(rowContainer)
    }
    
    private func showAlert(message: String, title: String = "Invalid Input") {
        coordinator?.showAlert(title: title, message: message)
    }

    @objc private func deleteKeyTimeRow(_ sender: UIButton) {
        guard let rowContainer = sender.superview,
              let _ = keyTimesStackView.arrangedSubviews.firstIndex(of: rowContainer) else {
            return
        }

        keyTimesStackView.removeArrangedSubview(rowContainer)
        rowContainer.removeFromSuperview()
    }

    @objc private func addKeyTimeButtonTapped() {
        addKeyTimeRow()
    }

    // MARK: - Actions
    @objc private func saveButtonTapped() {
        dismissKeyboard()

        do {
            let settings = try collectInputData()
            try viewModel.applySettings(settings)
            showAlert(message: "Settings saved successfully!", title: "Success")
        } catch let error as SettingsValidator.ValidationError {
            showAlert(message: error.localizedDescription)
        } catch {
            showAlert(message: "An unexpected error occurred")
        }
    }

    // MARK: - Data Collection
    private func collectInputData() throws -> MusicEditorSettings {
        // Collect total duration
        guard let totalDurationText = totalDurationTextField.text,
              let totalDuration = Double(totalDurationText) else {
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

        for rowContainer in keyTimesStackView.arrangedSubviews {
            guard let textField = rowContainer.subviews.first(where: { $0 is UITextField }) as? UITextField,
                  let text = textField.text,
                  !text.isEmpty else {
                continue
            }

            guard let percentage = Double(text) else {
                throw SettingsValidator.ValidationError.invalidKeyTimePercentage
            }

            percentages.append(CGFloat(percentage))
        }

        return percentages
    }

    private func collectTimelinePercentage() -> CGFloat? {
        guard let text = timelineLengthTextField.text,
              !text.isEmpty,
              let percentage = Double(text) else {
            return nil
        }
        return CGFloat(percentage)
    }

    @objc private func backButtonTapped() {
        coordinator?.back()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
