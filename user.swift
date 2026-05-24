//
//  Untitled.swift
//  Piggy Bank Savings!
//
//  Created by Parchment on 2/27/26.
//
import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var username: String
    var passwordHash: UInt64
    var balance: Double
    var history: [String]

    init(username: String, passwordHash: UInt64, startingBalance: Double) {
        self.id = UUID()
        self.username = username
        self.passwordHash = passwordHash
        self.balance = startingBalance
        self.history = []
    }
}
