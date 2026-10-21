//
//  CobrowseDemoApp.swift
//  CobrowseDemo
//
//  Marketing demo for the AssistCobrowse SDK. A fake bank ("ZoBank")
//  showcasing on-device redaction during a live cobrowse session.
//

import SwiftUI
import AssistCobrowse

@main
struct CobrowseDemoApp: App {
    @StateObject private var session = CobrowseSession()
    @StateObject private var store   = AppStore()

    init() {
        ZAssistCobrowseSession.shared.logHandler = { message in
            print("[AssistCobrowseLogs] \(message)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(session)
                .environmentObject(store)
        }
    }
}
