//
//  NetworkManager.swift
//  Infobus Tracker
//
//  Created by Mag on 12.09.2025.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager() // синглтон
    private init() {}

    private let baseURL = "https://infobus.kz/api"

    // Универсальный метод для загрузки и декодирования
    private func fetchData<T: Decodable>(from endpoint: String,
                                         completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "BadURL", code: -1)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    // MARK: - API Методы

    func getCountries(completion: @escaping (Result<[Country], Error>) -> Void) {
        fetchData(from: "/countries", completion: completion)
    }

    func getCities(countryId: Int, completion: @escaping (Result<[CityShort], Error>) -> Void) {
        fetchData(from: "/countries/\(countryId)/cities", completion: completion)
    }

    func getCityInfo(cityId: Int, completion: @escaping (Result<CityDetail, Error>) -> Void) {
        fetchData(from: "/cities/\(cityId)", completion: completion)
    }

    func getRoutes(cityId: Int, completion: @escaping (Result<[Route], Error>) -> Void) {
        fetchData(from: "/cities/\(cityId)/routes", completion: completion)
    }

    func getStations(cityId: Int, completion: @escaping (Result<[Station], Error>) -> Void) {
        fetchData(from: "/cities/\(cityId)/stations", completion: completion)
    }

    func getRouteStations(cityId: Int, completion: @escaping (Result<[RouteStation], Error>) -> Void) {
        fetchData(from: "/cities/\(cityId)/routestations", completion: completion)
    }

    func getRouteStationsDetail(cityId: Int, routeId: Int,
                                completion: @escaping (Result<[RouteStationDetail], Error>) -> Void) {
        fetchData(from: "/cities/\(cityId)/routes/\(routeId)/stations", completion: completion)
    }

    func getBusses(cityId: Int, routeId: Int,
                   completion: @escaping (Result<[Bus], Error>) -> Void) {
        fetchData(from: "/cities/\(cityId)/routes/\(routeId)/busses", completion: completion)
    }

    func getRoutesAtStation(cityId: Int, stationId: Int,
                            completion: @escaping (Result<RoutesAtStation, Error>) -> Void) {
        fetchData(from: "/cities/\(cityId)/stations/\(stationId)/routesatstation", completion: completion)
    }

    func getPredictions(cityId: Int, stationId: Int,
                        completion: @escaping (Result<[Prediction], Error>) -> Void) {
        fetchData(from: "/cities/\(cityId)/stations/\(stationId)/prediction", completion: completion)
    }
}

