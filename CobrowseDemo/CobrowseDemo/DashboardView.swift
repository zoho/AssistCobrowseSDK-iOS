//
//  DashboardView.swift
//  CobrowseDemo
//
//  Dummy financial dashboard. Account number, balance and card number are
//  redacted in cobrowse capture; the statement stays visible.
//

import SwiftUI
import AssistCobrowse

struct DashboardView: View {
    @EnvironmentObject var store: AppStore
    @Binding var path: [Route]

    private struct Txn: Identifiable {
        let id = UUID()
        let date: String
        let title: String
        let amount: String
        let credit: Bool
    }

    private let statement: [Txn] = [
        .init(date: "25 Aug", title: "Salary credit",     amount: "+ ₹ 85,000.00", credit: true),
        .init(date: "24 Aug", title: "Amazon",            amount: "- ₹ 1,299.00",  credit: false),
        .init(date: "23 Aug", title: "Electricity bill",  amount: "- ₹ 2,140.00",  credit: false),
        .init(date: "22 Aug", title: "Refund – Flipkart", amount: "+ ₹ 3,499.00",  credit: true),
        .init(date: "21 Aug", title: "Coffee Day",        amount: "- ₹ 180.00",    credit: false),
        .init(date: "20 Aug", title: "UPI from Rahul",    amount: "+ ₹ 1,500.00",  credit: true),
        .init(date: "19 Aug", title: "Swiggy",            amount: "- ₹ 640.00",    credit: false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            SharingBanner()

            List {
                Section("Account") {
                    labeled("Account number", store.accountNumber)
                    labeled("Available balance", store.balance)
                    labeled("Debit card", store.cardNumber)
                }

                Section("Statement") {
                    ForEach(statement) { tx in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tx.title)
                                Text(tx.date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(tx.amount)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)   // matches redaction fill so it's fully hidden
                                .cobrowseRedacted()          // hide amounts from the agent
                        }
                    }
                }
            }
        }
        .selectionDisabled(true)   // no cell-selection highlight when the agent taps
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    path.append(.profile)
                } label: {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sign Out", role: .destructive) {
                    store.logout()
                    path = []   // back to the sign-in page
                }
            }
        }
    }

    // Account fields are redacted from the support agent.
    @ViewBuilder
    private func labeled(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).cobrowseRedacted()
        }
    }
}
