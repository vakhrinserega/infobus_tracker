//
//  MainTabView.swift
//  Infobus Tracker
//
//  Created by Mag on 02.09.2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label(NSLocalizedString("tab.map", comment: ""), systemImage: "map")
                }
            
            RoutesView()
                .tabItem {
                    Label(NSLocalizedString("tab.routes", comment: ""), systemImage: "bus")
                }
            
            StopsView()
                .tabItem {
                    Label(NSLocalizedString("tab.stops", comment: ""), systemImage: "mappin")
                }
            
            SearchView()
                .tabItem {
                    Label(NSLocalizedString("tab.search", comment: ""), systemImage: "magnifyingglass")
                }
            
            SettingsView()
                .tabItem {
                    Label(NSLocalizedString("tab.settings", comment: ""), systemImage: "gear")
                }
        }
    }
}


// Заглушки для экранов
struct MapScreen: View {
    var body: some View {
        Text("Здесь будет карта")
    }
}

struct RoutesScreen: View {
    var body: some View {
        Text("Список маршрутов")
    }
}

struct StopsScreen: View {
    var body: some View {
        Text("Список остановок")
    }
}

struct SearchScreen: View {
    var body: some View {
        Text("Поиск маршрута")
    }
}

struct SettingsScreen: View {
    var body: some View {
        Text("Настройки приложения")
    }
}
