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

    @State private var selectedCountryId: Int? = SettingsStorage.shared.selectedCountryId
    @State private var selectedCityId: Int? = SettingsStorage.shared.selectedCityId
    @State private var onlyAccessibleBuses: Bool = SettingsStorage.shared.onlyAccessibleBuses

    @State private var isLoadingCountries = false
    @State private var isLoadingCities = false

    private let settings = SettingsStorage.shared

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("region_section".localized)) {
                    if isLoadingCountries {
                        ProgressView("loading_countries".localized)
                    } else {
                        Picker("country_label".localized, selection: $selectedCountryId) {
                            ForEach(countries, id: \.id) { country in
                                Text(country.name).tag(Optional(country.id))
                            }
                        }
                        .onChange(of: selectedCountryId) { newValue in
                            if let id = newValue {
                                settings.selectedCountryId = id
                                loadCities(for: id)
                            }
                        }
                    }

                    if isLoadingCities {
                        ProgressView("loading_cities".localized)
                    } else {
                        Picker("city_label".localized, selection: $selectedCityId) {
                            ForEach(cities, id: \.id) { city in
                                Text(city.name).tag(Optional(city.id))
                            }
                        }
                        .onChange(of: selectedCityId) { newValue in
                            if let id = newValue {
                                settings.selectedCityId = id
                            }
                        }
                    }
                }

                Section(header: Text("routes_section".localized)) {
                    Text("routes_placeholder".localized)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("accessibility_section".localized)) {
                    Toggle("only_accessible_buses".localized, isOn: $onlyAccessibleBuses)
                        .onChange(of: onlyAccessibleBuses) { newValue in
                            settings.onlyAccessibleBuses = newValue
                        }
                }

                Section(header: Text("feedback_section".localized)) {
                    HStack {
                        Text("app_code".localized)
                        Spacer()
                        Text(settings.appCode)
                            .foregroundColor(.gray)
                            .onTapGesture {
                                UIPasteboard.general.string = settings.appCode
                            }
                    }
                    Button("support_button".localized) {
                        // TODO: открыть почту или чат
                    }
                }
            }
            .navigationTitle("settings_title".localized)
            .onAppear {
                settings.ensureAppCode()
                loadCountriesIfNeeded()
            }
        }
    }

    // MARK: - Network

    private func loadCountriesIfNeeded() {
        if countries.isEmpty {
            loadCountries()
        }
    }

    private func loadCountries() {
        isLoadingCountries = true
        NetworkManager.shared.getCountries { result in
            DispatchQueue.main.async {
                isLoadingCountries = false
                switch result {
                case .success(let data):
                    self.countries = data
                    if let savedId = settings.selectedCountryId,
                       let found = data.first(where: { $0.id == savedId }) {
                        self.selectedCountryId = found.id
                        loadCities(for: found.id)
                    } else if let first = data.first {
                        self.selectedCountryId = first.id
                        settings.selectedCountryId = first.id
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
                    if let savedId = settings.selectedCityId,
                       let found = data.first(where: { $0.id == savedId }) {
                        self.selectedCityId = found.id
                    } else if let first = data.first {
                        self.selectedCityId = first.id
                        settings.selectedCityId = first.id
                    }
                case .failure(let error):
                    print("❌ Ошибка загрузки городов: \(error)")
                }
            }
        }
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
