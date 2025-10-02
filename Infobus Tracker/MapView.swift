//
//  MapView.swift
//  Infobus Tracker
//
//  Created by Mag on 02.09.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .region(.defaultRegion)
    @State private var selectedRoutes: [Route] = []
    @State private var cityDetail: CityDetail?
    
    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            
            // Отображаем маршруты напрямую
            ForEach(selectedRoutes, id: \.id) { route in
                let coordinates = parseCoordinates(from: route.location)
                if !coordinates.isEmpty {
                    let colors: [Color] = [.red, .blue, .green, .orange, .purple]
                    let selectedRouteIds = SettingsStorage.shared.selectedRouteIds
                    let colorIndex = selectedRouteIds.firstIndex(of: route.id) ?? 0
                    let color = colors[colorIndex % colors.count]
                    
                    MapPolyline(coordinates: coordinates)
                        .stroke(color, lineWidth: 4)
                }
            }
            
            // Маркер выбранного города
            if let city = cityDetail {
                Annotation(city.name, coordinate: CLLocationCoordinate2D(latitude: city.lat, longitude: city.lon)) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title)
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onAppear {
            loadCityAndRoutes()
        }
        .navigationTitle("map_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("map_title".localized)
                        .font(.headline)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.horizontal)
                }
            }
        }
    }
    
    private func loadCityAndRoutes() {
        guard let cityId = SettingsStorage.shared.selectedCityId else {
            print("❌ Город не выбран")
            return
        }
        
        // Загружаем информацию о городе
        NetworkManager.shared.getCityInfo(cityId: cityId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let city):
                    self.cityDetail = city
                    // Позиционируем карту на выбранном городе
                    let region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: city.lat, longitude: city.lon),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    self.cameraPosition = .region(region)
                    print("📍 Карта позиционирована на городе: \(city.name) (\(city.lat), \(city.lon))")
                    
                case .failure(let error):
                    print("❌ Ошибка загрузки информации о городе: \(error)")
                    // Если не удалось загрузить город, используем выбранные маршруты для позиционирования
                    self.loadSelectedRoutes()
                }
            }
        }
        
        // Загружаем выбранные маршруты
        loadSelectedRoutes()
    }
    
    private func loadSelectedRoutes() {
        let selectedRouteIds = SettingsStorage.shared.selectedRouteIds
        print("🎯 Выбранные маршруты IDs: \(selectedRouteIds)")
        
        // Загрузи маршруты из кэша
        let allRoutes = SettingsStorage.shared.cachedRoutes
        let selectedRoutes = allRoutes.filter { selectedRouteIds.contains($0.id) }
        
        print("🎯 Найдено маршрутов: \(selectedRoutes.count)")
        
        for route in selectedRoutes {
            let coordinates = parseCoordinates(from: route.location)
            print("📍 Маршрут \(route.routeNumber) - \(coordinates.count) точек")
        }
        
        self.selectedRoutes = selectedRoutes
        
        // Если город не загрузился, позиционируем по первому маршруту
        if cityDetail == nil && !selectedRoutes.isEmpty,
           let firstRoute = selectedRoutes.first {
            let coordinates = parseCoordinates(from: firstRoute.location)
            if let firstCoordinate = coordinates.first {
                let region = MKCoordinateRegion(
                    center: firstCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                cameraPosition = .region(region)
                print("📍 Карта позиционирована по первому маршруту")
            }
        }
    }
    
    private func parseCoordinates(from locationString: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        
        // Разделяем по запятым и пробелам
        let components = locationString.components(separatedBy: CharacterSet(charactersIn: ", "))
            .compactMap { Double($0) }
        
        // Координаты идут парами: lon, lat, lon, lat, ...
        for i in stride(from: 0, to: components.count - 1, by: 2) {
            let lon = components[i]
            let lat = components[i + 1]
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            coordinates.append(coordinate)
        }
        
        return coordinates
    }
}

// Создайте отдельный класс для управления геолокацией
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Запрашиваем разрешение
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Разрешение получено")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("❌ Доступ запрещён")
        case .notDetermined:
            print("⏳ Ожидание ответа пользователя")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Ошибка локации: \(error.localizedDescription)")
    }
}

extension MKCoordinateRegion {
    static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.1605, longitude: 71.4704),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
}
