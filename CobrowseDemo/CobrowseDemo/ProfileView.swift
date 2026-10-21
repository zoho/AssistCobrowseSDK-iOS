//
//  ProfileView.swift
//  CobrowseDemo
//
//  Customer profile. Phone, PAN, home & work address are redacted in
//  cobrowse capture — both when displayed and while being edited. The
//  "Edit details" button lives at the bottom of the page.
//

import SwiftUI
import AssistCobrowse

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var session: CobrowseSession

    @State private var isEditing = false
    @State private var showSupport = false

    // Draft copies so Cancel can discard.
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var pan = ""
    @State private var address = ""
    @State private var workAddress = ""
    @State private var gender = ""
    @State private var married = false

    var body: some View {
        VStack(spacing: 0) {
            SharingBanner()

            Form {
                // Photo + name + email header — inside the Form so it
                // scrolls with the rest. (Edit/Save live in the nav bar.)
                Section {
                    nameCard
                }
                .listRowBackground(Color.clear)

                Section("Personal details") {
                    row("Name", value: $name, redacted: false)
                    row("Email", value: $email, redacted: false)
                    row("Phone", value: $phone, redacted: true)
                    row("PAN", value: $pan, redacted: true)
                    row("Home address", value: $address, redacted: true)
                    row("Work address", value: $workAddress, redacted: true)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gender").foregroundStyle(.secondary)
                        Picker("Gender", selection: $gender) {
                            ForEach(AppStore.genders, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .disabled(!isEditing)
                    }

                    Toggle("Married", isOn: $married)
                        .disabled(!isEditing)
                }

                Section {
                    Label("Phone, PAN and addresses stay masked for support agents — even while you edit them.",
                          systemImage: "eye.slash")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        showSupport = true
                    } label: {
                        Label("Contact Support", systemImage: "headphones")
                    }
                }
            }
        }
        .selectionDisabled(true)   // no cell-selection highlight when the agent taps
        .sheet(isPresented: $showSupport) { SupportSheet() }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)   // Cancel takes the leading slot while editing
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { loadDraft(); isEditing = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { commit(); isEditing = false }.fontWeight(.semibold)
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") { loadDraft(); isEditing = true }
                }
            }
        }
        .onAppear(perform: loadDraft)
    }

    // MARK: - Name card

    private var nameCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .resizable().scaledToFit()
                .frame(width: 90, height: 90)
                .foregroundStyle(.tint)
            Text(name).font(.title2.bold())
            Text(email).font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    // MARK: - Row

    @ViewBuilder
    private func row(_ title: String, value: Binding<String>, redacted: Bool) -> some View {
        if isEditing {
            LabeledContent(title) {
                let field = TextField("", text: value).multilineTextAlignment(.trailing)
                if redacted { field.cobrowseRedacted() } else { field }
            }
        } else {
            HStack(alignment: .top) {
                Text(title).foregroundStyle(.secondary)
                Spacer()
                Group {
                    if redacted { Text(value.wrappedValue).cobrowseRedacted() }
                    else { Text(value.wrappedValue) }
                }
                .multilineTextAlignment(.trailing)
            }
        }
    }

    // MARK: - Draft <-> store

    private func loadDraft() {
        name = store.name; email = store.email; phone = store.phone; pan = store.pan
        address = store.address; workAddress = store.workAddress
        gender = store.gender; married = store.married
    }

    private func commit() {
        store.name = name; store.email = email; store.phone = phone; store.pan = pan
        store.address = address; store.workAddress = workAddress
        store.gender = gender; store.married = married
    }
}
