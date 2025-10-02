//
//  RoutesView.swift
//  Infobus Tracker
//
//  Created by Mag on 02.09.2025.
//

import SwiftUI

struct RoutesView: View {
    @State private var routes: [Route] = []
    @State private var selectedRoutes: [Int: Color] = [:]
    
    private let colors: [Color] = [.red, .blue, .green, .orange, .purple]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(routes, id: \.id) { route in
                    RouteTile(
                        route: route,
                        isSelected: selectedRoutes.keys.contains(route.id),
                        color: selectedRoutes[route.id]
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            showStops(route)
                        } label: {
                            Image(systemName: "mappin.circle")
                            Text("stops_button".localized)
                        }
                        .tint(.green)
                        
                        Button {
                            showRouteInfo(route)
                        } label: {
                            Image(systemName: "info.circle")
                            Text("info_button".localized)
                        }
                        .tint(.blue)
                    }
                    .onTapGesture {
                        toggleSelection(for: route)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .background(Color(.systemBackground))
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("routes_title".localized)
                            .font(.headline)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                            .padding(.horizontal)
                    }
                }
            }
            .onAppear {
                loadRoutes()
            }
        }
    }
    
    private func showRouteInfo(_ route: Route) {
        print("Инфо маршрута: \(route.routeName)")
    }
    
    private func showStops(_ route: Route) {
        print("Остановки маршрута: \(route.routeNumber)")
    }
    
    private func toggleSelection(for route: Route) {
        var selectedIds = SettingsStorage.shared.selectedRouteIds
        
        if selectedIds.contains(route.id) {
            // Убираем маршрут
            selectedIds.removeAll { $0 == route.id }
            selectedRoutes.removeValue(forKey: route.id)
        } else {
            // Добавляем маршрут (макс 5)
            guard selectedIds.count < 5 else { return }
            selectedIds.append(route.id)
            
            if let color = colors.first(where: { !selectedRoutes.values.contains($0) }) {
                selectedRoutes[route.id] = color
            }
        }
        
        SettingsStorage.shared.selectedRouteIds = selectedIds
        
        // Сохраняем в историю
        var history = SettingsStorage.shared.recentRoutes
        if !history.contains(route.routeNumber) {
            history.insert(route.routeNumber, at: 0)
        }
        if history.count > 5 {
            history = Array(history.prefix(5))
        }
        SettingsStorage.shared.recentRoutes = history
    }
    
    private func loadRoutes() {
        guard let cityId = SettingsStorage.shared.selectedCityId else {
            print("❌ Город не выбран")
            return
        }
        
        // ПРОВЕРЯЕМ КЭШ: если город тот же и есть сохраненные маршруты
        if SettingsStorage.shared.cachedCityId == cityId && !SettingsStorage.shared.cachedRoutes.isEmpty {
            print("📂 Загружаем маршруты из кэша")
            self.routes = SettingsStorage.shared.cachedRoutes
            // ВОССТАНАВЛИВАЕМ ВЫБРАННЫЕ МАРШРУТЫ
            self.restoreSelectedRoutes()
            return
        }
        
        // ИНАЧЕ грузим с сервера
        print("🌐 Загружаем маршруты с сервера")
        NetworkManager.shared.getRoutes(cityId: cityId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.routes = data
                    // СОХРАНЯЕМ В КЭШ
                    SettingsStorage.shared.cachedRoutes = data
                    SettingsStorage.shared.cachedCityId = cityId
                    // ВОССТАНАВЛИВАЕМ ВЫБРАННЫЕ МАРШРУТЫ
                    self.restoreSelectedRoutes()
                    print("📥 Загружено и сохранено маршрутов: \(data.count)")
                case .failure(let error):
                    print("❌ Ошибка загрузки маршрутов: \(error)")
                }
            }
        }
    }
    
    private func restoreSelectedRoutes() {
        let selectedIds = SettingsStorage.shared.selectedRouteIds
        for (index, id) in selectedIds.enumerated() {
            if index < colors.count {
                selectedRoutes[id] = colors[index]
            }
        }
    }
}

struct RouteTile: View {
    let route: Route
    let isSelected: Bool
    let color: Color?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(route.routeNumber)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(route.routeName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if isSelected {
                        Circle()
                            .fill(color ?? .gray)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(String(format: "buses_count".localized, route.bussesOnRoute))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? (color ?? .gray) : .gray.opacity(0.3), lineWidth: 2)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
