//
//  SettingsView.swift
//  Infobus Tracker
//
//  Created by Mag on 02.09.2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var countries: [Country] = []
    @State private var cities: [CityShort] = []
    
    @State private var selectedCountryId: Int?
    @State private var selectedCityId: Int?
    @State private var onlyAccessibleBuses: Bool = false
    
    @State private var isLoadingCountries = true
    @State private var isLoadingCities = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Регион")) {
                    if isLoadingCountries {
                        ProgressView("Загрузка стран…")
                    } else {
                        Picker("Страна", selection: $selectedCountryId) {
                            ForEach(countries, id: \.id) { country in
                                Text(country.name).tag(Optional(country.id))
                            }
                        }
                        .onChange(of: selectedCountryId) { newValue in
                            if let id = newValue {
                                loadCities(for: id)
                            }
                        }
                    }
                    
                    if isLoadingCities {
                        ProgressView("Загрузка городов…")
                    } else {
                        Picker("Город", selection: $selectedCityId) {
                            ForEach(cities, id: \.id) { city in
                                Text(city.name).tag(Optional(city.id))
                            }
                        }
                        .onChange(of: selectedCityId) { newValue in
                            if let id = newValue {
                                print("✅ selectedCityId: \(id)")
                            }
                        }
                    }
                }
                
                Section(header: Text("Маршруты")) {
                    Text("История маршрутов будет здесь")
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Доступность")) {
                    Toggle("Только автобусы с пандусом", isOn: $onlyAccessibleBuses)
                }
                
                Section(header: Text("Обратная связь")) {
                    HStack {
                        Text("Код приложения")
                        Spacer()
                        Text("ABC12345") // пока заглушка
                            .foregroundColor(.gray)
                            .onTapGesture {
                                UIPasteboard.general.string = "ABC12345"
                            }
                    }
                    Button("Написать в поддержку") {
                        // TODO: открыть почту или чат
                    }
                }
            }
            .navigationTitle("Настройки")
            .onAppear {
                loadCountries()
            }
        }
    }
    
    // MARK: - Network
    
    private func loadCountries() {
        isLoadingCountries = true
        NetworkManager.shared.getCountries { result in
            DispatchQueue.main.async {
                isLoadingCountries = false
                switch result {
                case .success(let data):
                    self.countries = data
                    print("📥 Загрузили страны: \(data.map { $0.name })")
                    
                    if let first = data.first {
                        self.selectedCountryId = first.id
                        loadCities(for: first.id)
                    }
                case .failure(let error):
                    print("❌ Ошибка загрузки стран: \(error)")
                }
            }
        }
    }
    
    private func loadCities(for countryId: Int) {
        isLoadingCities = true
        NetworkManager.shared.getCities(countryId: countryId) { result in
            DispatchQueue.main.async {
                isLoadingCities = false
                switch result {
                case .success(let data):
                    self.cities = data
                    print("📥 Загрузили города: \(data.map { $0.name })")
                    
                    if let first = data.first {
                        self.selectedCityId = first.id
                    }
                case .failure(let error):
                    print("❌ Ошибка загрузки городов: \(error)")
                }
            }
        }
    }
}
