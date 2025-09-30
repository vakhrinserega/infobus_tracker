//
//  StopsView.swift
//  Infobus Tracker
//
//  Created by Mag on 02.09.2025.
//

import SwiftUI

struct StopsView: View {
    @State private var stations: [Station] = []
    @State private var routesAtStations: [Int: [Int]] = [:]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(stations, id: \.id) { station in
                    StopTile(
                        station: station,
                        routeIds: routesAtStations[station.id] ?? []
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            showStopOnMap(station)
                        } label: {
                            Image(systemName: "map")
                            Text("map_button".localized)
                        }
                        .tint(.orange)
                        
                        Button {
                            showStopInfo(station)
                        } label: {
                            Image(systemName: "info.circle")
                            Text("info_button".localized)
                        }
                        .tint(.blue)
                    }
                    .onTapGesture {
                        selectStop(station)
                    }
                    .onAppear {
                        // Загружаем маршруты только когда плитка появляется на экране
                        if routesAtStations[station.id] == nil {
                            loadRoutesForStation(station)
                        }
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
                        Text("stops_title".localized)
                            .font(.headline)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                            .padding(.horizontal)
                    }
                }
            }
            .onAppear {
                loadStops()
            }
        }
    }
    
    private func showStopInfo(_ station: Station) {
        print("Инфо остановки: \(station.name)")
    }
    
    private func showStopOnMap(_ station: Station) {
        print("Показать на карте: \(station.name)")
    }
    
    private func selectStop(_ station: Station) {
        print("Выбрана остановка: \(station.name)")
    }
    
    private func loadStops() {
        guard let cityId = SettingsStorage.shared.selectedCityId else {
            print("❌ Город не выбран")
            return
        }
        
        // ПРОВЕРЯЕМ КЭШ: если город тот же и есть сохраненные остановки
        if SettingsStorage.shared.cachedCityId == cityId && !SettingsStorage.shared.cachedStations.isEmpty {
            print("📂 Загружаем остановки из кэша")
            self.stations = SettingsStorage.shared.cachedStations
            return
        }
        
        // ИНАЧЕ грузим с сервера
        print("🌐 Загружаем остановки с сервера")
        NetworkManager.shared.getStations(cityId: cityId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.stations = data
                    // СОХРАНЯЕМ В КЭШ
                    SettingsStorage.shared.cachedStations = data
                    SettingsStorage.shared.cachedCityId = cityId
                    print("📥 Загружено и сохранено остановок: \(data.count)")
                case .failure(let error):
                    print("❌ Ошибка загрузки остановок: \(error)")
                }
            }
        }
    }
    
    private func loadRoutesForStation(_ station: Station) {
        guard let cityId = SettingsStorage.shared.selectedCityId else { return }
        
        NetworkManager.shared.getRoutesAtStation(cityId: cityId, stationId: station.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let routeIds):
                    self.routesAtStations[station.id] = routeIds
                case .failure(let error):
                    print("❌ Ошибка загрузки маршрутов для остановки \(station.id): \(error)")
                }
            }
        }
    }
}

struct StopTile: View {
    let station: Station
    let routeIds: [Int]
    
    private var routeNumbers: [String] {
        routeIds.map { String($0) }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(station.name)
                    .font(.headline)
                    .lineLimit(2)
                
                if !routeNumbers.isEmpty {
                    Text("Маршруты: \(routeNumbers.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text("no_routes".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
