//
//  ContentView.swift
//  Piggy Bank Savings!
//
//  Created by Parchment on 2/27/26.
//

import SwiftUI
import UIKit
import GoogleMobileAds

struct ContentView: View {
    @StateObject private var vm = PiggyBankViewModel()
    @State private var selectedLoggedInWallpaper: String = "accountWallpaper"

    private enum Field: Hashable {
        case username, password, startingBalance, amount
    }

    @FocusState private var focusedField: Field?

    private func bind(_ keyPath: ReferenceWritableKeyPath<PiggyBankViewModel, String>) -> Binding<String> {
        Binding(
            get: { vm[keyPath: keyPath] },
            set: { vm[keyPath: keyPath] = $0 }
        )
    }

    private func bindInt32(_ keyPath: ReferenceWritableKeyPath<PiggyBankViewModel, Int32>) -> Binding<String> {
        Binding(
            get: { String(vm[keyPath: keyPath]) },
            set: { newValue in
                // Allow empty while typing; treat as 0
                if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    vm[keyPath: keyPath] = 0
                    return
                }
                vm[keyPath: keyPath] = Int32(newValue) ?? 0
            }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {

                Image(vm.isLoggedIn ? selectedLoggedInWallpaper : "menuWallpaper")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                
                ScrollView(.vertical) {
                    VStack(spacing: 16) {
                        Text("Piggy Bank Savings!")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(vm.isLoggedIn ? .primary : .white)
                            .multilineTextAlignment(.center)

                        if vm.isLoggedIn {
                            bankingView
                        } else {
                            authView
                        }

                        if let msg = vm.errorMessage {
                            Text(msg)
                                .foregroundStyle(.red)
                                .font(.callout)
                        }

                        // Extra scroll room when keyboard is up
                        Color.clear
                            .frame(height: focusedField == nil ? 0 : 320)
                    }
                    .frame(maxWidth: 520)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 16)
                    .padding(.top, vm.isLoggedIn ? 24 : 8)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)
            }
            .onChange(of: vm.isLoggedIn) { _, loggedIn in
                if loggedIn {
                    let options = ["accountWallpaper", "accountWallpaper2"]
                    selectedLoggedInWallpaper = options.randomElement() ?? "accountWallpaper"
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            // Banner shown on both login + account screens
            AdMobBannerView(adUnitID: AdMobConfig.testBannerAdUnitID)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
        }
    }

    private var authView: some View {
        VStack(spacing: 12) {
            TextField("Username", text: bind(\.username))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(maxWidth: .infinity)
                .focused($focusedField, equals: .username)
                .id(Field.username)

            SecureField("Password", text: bind(\.password))
                .textFieldStyle(.roundedBorder)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(maxWidth: .infinity)
                .focused($focusedField, equals: .password)
                .id(Field.password)

            TextField("Starting balance (register)", text: bind(\.startingBalance))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(maxWidth: .infinity)
                .focused($focusedField, equals: .startingBalance)
                .id(Field.startingBalance)

            HStack {
                Button("Register") {
                    focusedField = nil
                    vm.register()
                }
                .buttonStyle(.borderedProminent)

                Button("Login") {
                    focusedField = nil
                    vm.login()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 10)
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var bankingView: some View {
        VStack(alignment: .center, spacing: 12) {
            if let user = vm.currentUser {
                Text("Welcome, \(user.username)")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Text("Balance: $\(user.balance, specifier: "%.2f")")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }

            Text("Amount")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            TextField("Enter amount", text: bind(\.amount))
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundColor(.black)
                .focused($focusedField, equals: .amount)
                .id(Field.amount)
                .frame(maxWidth: .infinity)

            HStack {
                Button("Deposit") {
                    focusedField = nil
                    vm.deposit()
                }
                .buttonStyle(.borderedProminent)

                Button("Withdraw") {
                    focusedField = nil
                    vm.withdraw()
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Divider().padding(.vertical, 6)

            NavigationLink("View History") {
                HistoryView(history: vm.currentUser?.history ?? [])
            }
            .buttonStyle(.bordered)

            Button("Logout") {
                focusedField = nil
                vm.logout()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 10)
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct HistoryView: View {
    let history: [String]

    var body: some View {
        List {
            if history.isEmpty {
                Text("No transactions yet.")
            } else {
                ForEach(Array(history.enumerated()), id: \.offset) { _, item in
                    Text(item)
                }
            }
        }
        .navigationTitle("History")
    }
}

#Preview {
    ContentView()
}

// MARK: - AdMob Banner (SwiftUI)

private enum AdMobConfig {
    // Use Google's demo banner unit ID for development/testing.
    // Replace with your real Ad Unit ID before publishing.
    static let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
}

private struct AdMobBannerView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let width = UIScreen.main.bounds.width
        // Anchored adaptive banner size (API name may vary by SDK version)
        let adSize = largeAnchoredAdaptiveBanner(width: width)

        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.topMostViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // Keep root VC in sync (can change during navigation)
        uiView.rootViewController = UIApplication.shared.topMostViewController
    }
}

private extension UIApplication {
    var topMostViewController: UIViewController? {
        guard let scene = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let root = window.rootViewController
        else {
            return nil
        }

        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
