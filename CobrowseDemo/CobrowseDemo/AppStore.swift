//
//  AppStore.swift
//  CobrowseDemo
//
//  In-memory app state for the demo: auth flag + editable profile.
//

import Foundation

@MainActor
final class AppStore: ObservableObject {

    @Published var isLoggedIn = false

    // Editable profile (phone / pan / home & work address are redacted in capture).
    @Published var name        = "Kishore N"
    @Published var email       = "kishore.n@zylker.com"
    @Published var phone       = "+91 98765 43210"
    @Published var pan         = "ABCDE1234F"
    @Published var address     = "42, MG Road, Bengaluru 560001"
    @Published var workAddress = "Zylker Towers, Whitefield, Bengaluru 560066"
    @Published var gender      = "Men"
    @Published var married     = false

    static let genders = ["Men", "Women", "Other"]

    // Dummy financial data for the dashboard.
    let accountNumber = "5012 3456 7890 1122"
    let balance       = "₹ 4,82,650.00"
    let cardNumber    = "4111 1111 1111 1111"

    func logout() { isLoggedIn = false }
}

/// Screens pushed onto the demo's navigation stack.
enum Route: Hashable {
    case dashboard
    case profile
}
