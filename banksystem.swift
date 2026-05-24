//
//  Untitled.swift
//  Piggy Bank Savings!
//
//  Created by Parchment on 2/27/26.
//
import Foundation

final class BankSystem: Codable {
    private(set) var users: [User] = []
    private(set) var currentUserID: UUID? = nil

    // MARK: - Auth
    func registerUser(username: String, password: String, startingBalance: Double) throws {
        guard !username.isEmpty else { throw BankError.invalidUsername }
        guard startingBalance >= 0 else { throw BankError.invalidAmount }
        guard findUserIndex(username: username) == nil else { throw BankError.usernameTaken }

        let hash = Self.hashPassword(password)
        var user = User(username: username, passwordHash: hash, startingBalance: startingBalance)
        user.history.append("Account created. Starting balance: \(startingBalance)")
        users.append(user)
    }

    func login(username: String, password: String) throws {
        guard let idx = findUserIndex(username: username) else { throw BankError.loginFailed }
        let hash = Self.hashPassword(password)
        guard users[idx].passwordHash == hash else { throw BankError.loginFailed }
        currentUserID = users[idx].id
    }

    func logout() {
        currentUserID = nil
    }

    // MARK: - Banking
    func deposit(_ amount: Double) throws {
        guard amount > 0 else { throw BankError.invalidAmount }
        guard let idx = currentUserIndex() else { throw BankError.notLoggedIn }

        users[idx].balance += amount
        users[idx].history.append("Deposit: +\(amount) | Balance: \(users[idx].balance)")
    }

    func withdraw(_ amount: Double) throws {
        guard amount > 0 else { throw BankError.invalidAmount }
        guard let idx = currentUserIndex() else { throw BankError.notLoggedIn }
        guard users[idx].balance >= amount else { throw BankError.insufficientFunds }

        users[idx].balance -= amount
        users[idx].history.append("Withdraw: -\(amount) | Balance: \(users[idx].balance)")
    }

    func currentUser() -> User? {
        guard let idx = currentUserIndex() else { return nil }
        return users[idx]
    }

    // MARK: - Helpers
    private func findUserIndex(username: String) -> Int? {
        users.firstIndex { $0.username == username }
    }

    private func currentUserIndex() -> Int? {
        guard let id = currentUserID else { return nil }
        return users.firstIndex { $0.id == id }
    }

    // Simple FNV-1a hash (learning-friendly, not “real security”)
    static func hashPassword(_ password: String) -> UInt64 {
        var h: UInt64 = 1469598103934665603
        for byte in password.utf8 {
            h ^= UInt64(byte)
            h &*= 1099511628211
        }
        return h
    }
}

enum BankError: LocalizedError {
    case invalidUsername
    case usernameTaken
    case loginFailed
    case notLoggedIn
    case invalidAmount
    case insufficientFunds

    var errorDescription: String? {
        switch self {
        case .invalidUsername: return "Username can’t be empty."
        case .usernameTaken: return "That username is already taken."
        case .loginFailed: return "Login failed. Check username/password."
        case .notLoggedIn: return "You must be logged in."
        case .invalidAmount: return "Amount must be greater than 0."
        case .insufficientFunds: return "Insufficient funds."
        }
    }
}
