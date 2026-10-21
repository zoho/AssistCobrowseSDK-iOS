//
//  HomeView.swift
//  CobrowseDemo
//
//  Landing + sign-in on one screen. The password field is redacted in
//  cobrowse capture; "Contact Support" starts a screen-sharing session.
//

import SwiftUI
import AssistCobrowse

struct HomeView: View {
    @EnvironmentObject var session: CobrowseSession
    @EnvironmentObject var store: AppStore

    @State private var path: [Route] = []
    @State private var showSupport = false
    @State private var username = "kishore.n"
    @State private var password = "secret123"

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                SharingBanner()

                Form {
                    Section {
                        VStack(spacing: 8) {
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.tint)
                            Text("ZoBank").font(.largeTitle.bold())
                            Text("Banking made simple").foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .listRowBackground(Color.clear)
                    }

                    Section("Sign in") {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)

                        SecureField("Password", text: $password)
                            .cobrowseRedacted()   // hidden from the support agent

                        Button {
                            store.isLoggedIn = true
                            path = [.dashboard]
                        } label: {
                            Text("Sign In").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Section {
                        Button {
                            showSupport = true
                        } label: {
                            Label("Contact Support", systemImage: "headphones")
                                .frame(maxWidth: .infinity)
                        }
                    } footer: {
                        Label("Your password is masked for support agents",
                              systemImage: "lock.shield")
                            .font(.footnote)
                    }
                }
            }
            .selectionDisabled(true)   // no cell-selection highlight when the agent taps
            .navigationTitle("ZoBank")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .dashboard: DashboardView(path: $path)
                case .profile:   ProfileView()
                }
            }
            .sheet(isPresented: $showSupport) { SupportSheet() }
        }
    }
}
