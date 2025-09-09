//
//  SettingsView.swift
//  Infobus Tracker
//
//  Created by Mag on 02.09.2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedCountry = SettingsManager.shared.country
    @State private var selectedCity = SettingsManager.shared.city
    @State private var onlyAccessibleBuses = SettingsManager.shared.onlyAccessibleBuses
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Регион")) {
                    Picker("Страна", selection: $selectedCountry) {
                        Text("Казахстан").tag("Казахстан")
                        Text("Россия").tag("Россия")
                        Text("Узбекистан").tag("Узбекистан")
                    }
                    .onChange(of: selectedCountry) { newValue in
                        SettingsManager.shared.country = newValue
                    }
                    
                    Picker("Город", selection: $selectedCity) {
                        if selectedCountry == "Казахстан" {
                            Text("Алматы").tag("Алматы")
                            Text("Астана").tag("Астана")
                            Text("Актобе").tag("Актобе")
                        } else if selectedCountry == "Россия" {
                            Text("Москва").tag("Москва")
                            Text("Казань").tag("Казань")
                        }
                    }
                    .onChange(of: selectedCity) { newValue in
                        SettingsManager.shared.city = newValue
                    }
                }
                
                Section(header: Text("Маршруты")) {
                    if !SettingsManager.shared.recentRoutes.isEmpty {
                        ForEach(SettingsManager.shared.recentRoutes, id: \.self) { route in
                            Text("Маршрут \(route)")
                        }
                        Button("Очистить историю") {
                            SettingsManager.shared.recentRoutes = []
                        }
                        .foregroundColor(.red)
                    } else {
                        Text("Нет сохранённых маршрутов")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Доступность")) {
                    Toggle("Только автобусы с пандусом", isOn: $onlyAccessibleBuses)
                        .onChange(of: onlyAccessibleBuses) { newValue in
                            SettingsManager.shared.onlyAccessibleBuses = newValue
                        }
                }
                
                Section(header: Text("Обратная связь")) {
                    HStack {
                        Text("Код приложения")
                        Spacer()
                        Text(SettingsManager.shared.appCode.prefix(8)) // короткий ID
                            .foregroundColor(.gray)
                            .onTapGesture {
                                UIPasteboard.general.string = SettingsManager.shared.appCode
                            }
                    }
                    Button("Написать в поддержку") {
                        // TODO: открыть почту или чат
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }
}
