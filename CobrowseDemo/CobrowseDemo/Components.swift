//
//  Components.swift
//  CobrowseDemo
//
//  Small shared views: the "screen sharing" banner and the support-code sheet.
//

import SwiftUI
import UIKit

/// A SwiftUI button backed by a real `UIButton` (a `UIControl`), so the
/// cobrowse SDK's remote-tap dispatch (`UIControl.sendActions`) can fire it.
/// Plain SwiftUI `Button`s aren't individual UIViews and can't be remote-tapped.
struct UIKitButton: UIViewRepresentable {
    let title: String
    var systemImage: String? = nil
    var prominent: Bool = false
    let action: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(action) }

    func makeUIView(context: Context) -> UIButton {
        var config: UIButton.Configuration = prominent ? .borderedProminent() : .bordered()
        config.imagePadding = 6
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        button.addTarget(context.coordinator, action: #selector(Coordinator.fire), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        return button
    }

    func updateUIView(_ button: UIButton, context: Context) {
        context.coordinator.action = action
        button.configuration?.title = title
        button.configuration?.image = systemImage.flatMap { UIImage(systemName: $0) }
    }

    final class Coordinator {
        var action: () -> Void
        init(_ action: @escaping () -> Void) { self.action = action }
        @objc func fire() { action() }
    }
}

/// Thin banner shown while a cobrowse session is live.
struct SharingBanner: View {
    @EnvironmentObject var session: CobrowseSession

    var body: some View {
        if session.isSharing {
            HStack(spacing: 8) {
                Circle().fill(.green).frame(width: 8, height: 8)
                Text("Screen sharing with support is active")
                    .font(.footnote.weight(.medium))
                Spacer()
                Button("End") { session.stop() }
                    .font(.footnote.weight(.semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.green.opacity(0.12))
            .foregroundStyle(.green)
        }
    }
}

/// Sheet that collects the support code and starts the session.
struct SupportSheet: View {
    @EnvironmentObject var session: CobrowseSession
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Support code", text: $code)
                        .textInputAutocapitalization(.characters)
                        .disableAutocorrection(true)
                } header: {
                    Text("Contact Support")
                } footer: {
                    Text("Enter the code shared by our support agent to start a guided screen-sharing session.")
                }

                if let err = session.errorMessage {
                    Text(err).foregroundStyle(.red).font(.footnote)
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        session.start(code: code)
                        dismiss()
                    }
                    .disabled(code.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
