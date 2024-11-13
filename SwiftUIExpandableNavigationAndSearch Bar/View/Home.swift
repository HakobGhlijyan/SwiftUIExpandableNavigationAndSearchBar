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
    @FocusState private var isSearching: Bool                       //7. rejim focusa na textfield
    
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
            .animation(.snappy(duration: 0.3, extraBounce: 0), value: isSearching)   //7. budet poyavlyatsya s animaciey
        }
        .background(.gray.opacity(0.1))
        .scrollTargetBehavior(CustomScrollTargetBehaviour())   //10!!!!!!!!
        .contentMargins(.top, 190, for: .scrollIndicators)
        // peremechenie inficatora scroll vniz na 190 chtob on bil tam gde content nachinalsya
    }
    
    //MARK: - Expandable Navigation Bar
    @ViewBuilder func ExpandableNavigationBar(_ title: String = "Messages") -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
            //Как вы можете видеть, даже при использовании LazyStack заголовок остается вверху без проблем. Давайте теперь изменим размер фона строки поиска, чтобы он полностью заполнял верхнюю область при пролистывании.
//            let progress = max(min(-minY / 70, 1), 0)
            //Это просто случайное значение, которое вы можете изменить в соответствии со своими потребностями. Имейте в виду, что чем меньше значение, тем быстрее будет анимация прокрутки, и наоборот.
            let progress = isSearching ? 1 : max(min(-minY / 70, 1), 0)
            //Это просто случайное значение, которое вы можете изменить в соответствии со своими потребностями. Имейте в виду, что чем меньше значение, тем быстрее будет анимация прокрутки, и наоборот.
            //Поскольку мы сделали панель навигации расширяемой при прокрутке, мы можем просто применить некоторые небольшие изменения, чтобы расширить панель навигации, когда текстовое поле поиска активно.
            
            //11. Давайте добавим немного анимации масштабирования к заголовку навигации, как на панели навигации по умолчанию.
            let scrollViewHeigth = proxy.bounds(of: .scrollView(axis: .vertical))?.height ?? 0
            let scaleProgress = minY > 0 ? (1 + max(min(minY / scrollViewHeigth, 1), 0) * 0.5) : 1
            
            
            VStack(spacing: 10) {
                //Title
                Text(title)
                    .font(.largeTitle.bold())
                    .scaleEffect(scaleProgress, anchor: .topLeading)  //11. -> MESSAGES budet sachtabirovatsya pri scrolle vniz
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                //Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                    
                    TextField("Search Conservation", text: $searchText)
                        .focused($isSearching)                  //7. focus jerim na nem
                    
                    if isSearching {                            //7knopka x chtob otkluchit rejim focusa
                        Button {
                            isSearching = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                        }
                    }
                }
                .foregroundStyle(Color.primary)             //9.
                .padding(.vertical, 10)                                     // NASHALNOE SOSTOYANIE
                .padding(.horizontal, 15 - (progress * 15))               //4.2 uberot tot hor padding
//                .padding(.horizontal, 15)                               //4.1 stariy !!! ...
                .frame(height: 45)
                .clipShape(Capsule())                       //9.
                .background(
                    RoundedRectangle(cornerRadius: 25 - (progress * 25))    // 6. radius zakrugleniya !!!
                        .fill(.background)
                        .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)  // i shadow dobavim
                        .padding(.top, -progress * 190)                    //1. verx pri scroll vitenitsya
                        .padding(.bottom, -progress * 65)                  //2. nix pri scroll vniz poysdet
                        .padding(.horizontal, -progress * 15)              //3. horizontal vitenyatsya i ves ekran budet
                    //Давайте переместим вид вверх на ту же величину отступа, которую мы установили в нижней части фона.
                )
                
                //Custom Segmented Picker
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
            //Add issearching -> Чтобы панель навигации всегда отображалась вверху, пока активна строка поиска.
            .offset(y: -progress * 64)                                      //5. i vest ego na vex zdvig
        }
        .frame(height: 190) //Поскольку компоненты на панели навигации имеют фиксированную высоту, 190 - это сумма их всех.
        .padding(.bottom, 10)
        .padding(.bottom, isSearching ? -65 : 0) //8. sdvig nijney scroll veiw pri aknivnom search
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

//10.... Изображение может отображаться неравномерно, если пользователь прекращает прокрутку в середине перехода к прокрутке. При определенных обстоятельствах мы можем использовать новое целевое поведение прокрутки, чтобы определить, когда перетаскивание завершено, что позволяет нам либо вернуть переход к начальной фазе, либо завершить его, основываясь на конечном целевом значении.
// DLYA TOGO CHTOB KOGDA SCROLLIM VERX OPREDELIT ROSTOYANIE OT KOTOROGO AUTOMATICHESKI OV POYDET VERX A PRI KAKOM V NIZZ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
