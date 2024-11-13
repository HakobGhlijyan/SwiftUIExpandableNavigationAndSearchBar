//
//  Home.swift
//  SwiftUIExpandableNavigationAndSearch Bar
//
//  Created by Hakob Ghlijyan on 12.11.2024.
//

import SwiftUI

struct Home: View {
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var namespace
    @FocusState private var isSearching: Bool
    @State private var searchText: String = ""
    @State private var activeTab: Tab = .all
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 15) {
                DummyMessagesView()
            }
            .safeAreaPadding(15)
            .safeAreaInset(edge: .top, spacing: 0) {
                ExpandableNavigationBar()
            }
            .animation(.snappy(duration: 0.3, extraBounce: 0), value: isSearching)
        }
        .background(.gray.opacity(0.1))
        .scrollTargetBehavior(CustomScrollTargetBehaviour())
        .contentMargins(.top, 190, for: .scrollIndicators)
    }
    
    //MARK: - Expandable Navigation Bar
    @ViewBuilder func ExpandableNavigationBar(_ title: String = "Messages") -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
            let progress = isSearching ? 1 : max(min(-minY / 70, 1), 0)
            let scrollViewHeigth = proxy.bounds(of: .scrollView(axis: .vertical))?.height ?? 0
            let scaleProgress = minY > 0 ? (1 + max(min(minY / scrollViewHeigth, 1), 0) * 2) : 1
            
            VStack(spacing: 10) {
                Text(title)
                    .font(.largeTitle.bold())
                    .scaleEffect(scaleProgress, anchor: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                    
                    TextField("Search Conservation", text: $searchText)
                        .focused($isSearching)
                    
                    if isSearching {
                        Button {
                            isSearching = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                        }
                    }
                }
                .foregroundStyle(Color.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 15 - (progress * 15))
                .frame(height: 45)
                .clipShape(Capsule())
                .background(
                    RoundedRectangle(cornerRadius: 25 - (progress * 25))
                        .fill(.background)
                        .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
                        .padding(.top, -progress * 190)
                        .padding(.bottom, -progress * 65)
                        .padding(.horizontal, -progress * 15)
                )

                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(Tab.allCases, id: \.rawValue) { tab in
                            Button {
                                withAnimation(.snappy) {
                                    activeTab = tab
                                }
                            } label: {
                                Text(tab.rawValue)
                                    .font(.callout)
                                    .foregroundStyle(activeTab == tab ? (colorScheme == .dark ? .black : .white) : Color .primary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 15)
                                    .background {
                                        if activeTab == tab {
                                            Capsule()
                                                .fill(Color.primary)
                                                .matchedGeometryEffect(id: "CircleID", in: namespace)
                                        } else {
                                            Capsule()
                                                .fill(.background)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: 50)
            }
            .padding(.top, 25)
            .safeAreaPadding(.horizontal, 15)
            .offset(y: minY < 0 || isSearching ? -minY : 0)
            .offset(y: -progress * 64)
        }
        .frame(height: 190)
        .padding(.bottom, 10)
        .padding(.bottom, isSearching ? -65 : 0)
    }
    
    //MARK: - Dummy View
    @ViewBuilder func DummyMessagesView() -> some View {
        ForEach(0 ..< 20, id: \.self) { _ in
            HStack {
                Circle().frame(width:  55, height: 55)
                
                VStack(alignment: .leading, spacing: 6) {
                    Rectangle().frame(width: 140, height: 8)
                    Rectangle().frame(height: 8)
                    Rectangle().frame(width: 80, height: 8)
                }
            }
            .foregroundStyle(Color(.systemGray4))
            .padding(.horizontal, 15)
        }
    }
}

struct CustomScrollTargetBehaviour: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect .minY < 70 {
            if target.rect.minY < 35 {
                target.rect.origin = .zero
            } else {
                target.rect.origin = .init(x: 0, y: 70)
            }
        }
    }
}

#Preview {
    MainView()
}
