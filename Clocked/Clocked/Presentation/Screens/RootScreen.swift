//
//  RootScreen.swift
//  Clocked
//
//  Created by Sumangala Rao on 10/9/2026.
//
import SwiftUI

/// The app's tabs, in the order the student reaches for them.
struct RootScreen: View {
    let dependencies: AppDependencies

    var body: some View {
        TabView {
            FortnightMeterScreen(dependencies: dependencies)
                .tabItem { Label("Fortnight", systemImage: "gauge.medium") }

            ShiftOfferCheckScreen(dependencies: dependencies)
                .tabItem { Label("Check a shift", systemImage: "questionmark.circle") }

            RecordShiftScreen(dependencies: dependencies)
                .tabItem { Label("Add shift", systemImage: "plus.circle") }

            WorkRecordScreen(dependencies: dependencies)
                .tabItem { Label("Record", systemImage: "list.bullet.rectangle") }
        }
        .tint(ClockedTheme.accent)
        // The palette is a light reading of the pitch deck. Locking the appearance keeps it
        // intact until a dark variant is designed properly.
        .preferredColorScheme(.light)
    }
}

#Preview {
    RootScreen(dependencies: .withSampleData())
}
