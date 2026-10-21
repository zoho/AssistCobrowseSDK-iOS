//
//  CobrowseSession.swift
//  CobrowseDemo
//
//  Thin ObservableObject bridge over the AssistCobrowse SDK for the
//  marketing demo. Starts a session from a support code and mirrors the
//  SDK's live state into SwiftUI.
//

import Foundation
import Combine
import UIKit
import AssistCobrowse

@MainActor
final class CobrowseSession: ObservableObject, ZAssistCobrowseSessionListener {

    // Static per-install config (same values the sample app uses).
    private static let widgetCode = "<your-widget-code>"
    private static let baseURL    = "https://assist.zoho.com"

    @Published private(set) var state: ZAssistCobrowseSession.State = .idle
    @Published var errorMessage: String?

    /// True once frames are flowing to a technician.
    var isSharing: Bool { state == .capturing || state == .backgrounded }

    init() {
        ZAssistCobrowseSession.shared.listener = self
        state = ZAssistCobrowseSession.shared.state
        ZAssistCobrowseSession.shared.logHandler = { log in
            print("[log] \(log)")
        }
    }

    /// Register with the support code and start screen capture.
    func start(code: String) {
        errorMessage = nil
        let key = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !key.isEmpty else { errorMessage = "Enter a support code"; return }

        let config = ZAssistCobrowseConfig(sessionKey: key,
                                           widgetCode: Self.widgetCode,
                                           baseURL: Self.baseURL)
        ZAssistCobrowseSession.shared.register(config: config) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                do { try ZAssistCobrowseSession.shared.startCapture() }
                catch { self.errorMessage = error.localizedDescription }
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }

    func stop() {
        ZAssistCobrowseSession.shared.endSession()
    }

    // MARK: - ZAssistCobrowseSessionListener (fires on main)

    nonisolated func cobrowseSession(_ session: ZAssistCobrowseSession,
                                     didChangeState state: ZAssistCobrowseSession.State) {
        Task { @MainActor in self.state = state }
    }

    nonisolated func cobrowseSessionDidEnd(_ session: ZAssistCobrowseSession,
                                           reason: ZAssistCobrowseEndReason) {
        Task { @MainActor in self.state = ZAssistCobrowseSession.shared.state }
    }

    nonisolated func cobrowseSession(_ session: ZAssistCobrowseSession,
                                     didReceiveControlRequest viewer: ZAssistCobrowseViewer,
                                     reply: @escaping (_ accept: Bool) -> Void) {
        let who = viewer.displayName ?? "The support agent"
        Task { @MainActor in Self.presentControlAlert(who: who, reply: reply) }
    }

    /// Present the Allow/Deny prompt on the window's top-most view controller
    /// so it always appears over whatever SwiftUI screen/sheet is showing.
    @MainActor
    private static func presentControlAlert(who: String, reply: @escaping (Bool) -> Void) {
        guard let presenter = topViewController() else { reply(false); return }
        let alert = UIAlertController(
            title: "Allow remote control?",
            message: "Malcolm@zylker.com wants to control your screen. They can control the application untill the session end",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Deny", style: .cancel) {
            _ in reply(false) })
        alert.addAction(UIAlertAction(title: "Allow", style: .default) { _ in reply(true) })
        presenter.present(alert, animated: true)
    }

    /// Top-most VC of the active foreground window scene.
    @MainActor
    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        guard let window = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
        else { return nil }
        var top = window.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
}
