//
//  ContentView.swift
//  SwiftUIExpandableNavigationAndSearch Bar
//
//  Created by Hakob Ghlijyan on 12.11.2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            Home()
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    MainView()
}
