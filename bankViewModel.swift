//
//  bankViewModel.swift
//  Piggy Bank Savings!
//
//  Created by Parchment on 2/27/26.
//
import Foundation
import SwiftUI
import Combine

@MainActor
final class PiggyBankViewModel: ObservableObject {
    @Published private(set) var system: BankSystem
    @Published var errorMessage: String? = nil
    @Published private var refreshTick: Int = 0

    // UI fields
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var startingBalance: String = ""

    @Published var amount: String = ""

    init() {
        self.system = Self.load() ?? BankSystem()
        refreshUI()
    }

    var isLoggedIn: Bool { system.currentUser() != nil }
    var currentUser: User? { system.currentUser() }

    func register() {
        do {
            let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
            let p = password
            let start = Double(startingBalance) ?? 0

            try system.registerUser(username: u, password: p, startingBalance: start)
            // Auto-login after registering so the UI moves into the banking screen
            try system.login(username: u, password: p)

            save()
            clearAuthFields()
            errorMessage = nil
            refreshUI()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func login() {
        do {
            try system.login(username: username, password: password)
            save()
            clearAuthFields()
            errorMessage = nil
            refreshUI()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        system.logout()
        save()
        refreshUI()
    }

    func deposit() {
        do {
            let x = Double(amount) ?? 0
            try system.deposit(x)
            save()
            amount = ""
            errorMessage = nil
            refreshUI()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func withdraw() {
        do {
            let x = Double(amount) ?? 0
            try system.withdraw(x)
            save()
            amount = ""
            errorMessage = nil
            refreshUI()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func clearAuthFields() {
        username = ""
        password = ""
        startingBalance = ""
    }

    private func refreshUI() {
        refreshTick &+= 1
    }

    // MARK: - Save/Load
    private static func fileURL() -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("bank_data.json")
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(system)
            try data.write(to: Self.fileURL(), options: [.atomic])
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }
    }

    private static func load() -> BankSystem? {
        do {
            let url = fileURL()
            guard FileManager.default.fileExists(atPath: url.path) else { return nil }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(BankSystem.self, from: data)
        } catch {
            return nil
        }
    }
}
