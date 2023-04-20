//
//  Bundle-Decodable.swift
//  HWSPortfolio
//
//  Created by Денис Трясунов on 20.04.2023.
//

import Foundation

extension Bundle {
    
    func decode<T: Decodable>(
        _ file: String,
        as type: T.Type = T.self,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T {
        
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate '\(file)' in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load '\(file)' from bundle.")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode '\(file)' from bundle data due to missing key '\(key.stringValue)' - \(context.debugDescription).")
        } catch DecodingError.typeMismatch(let type, let context) {
            fatalError("Failed to decode '\(file)' from bundle data due to mismatch for type '\(type)' - \(context.debugDescription).")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode '\(file)' from bundle data due to value not found for type '\(type)' - \(context.debugDescription).")
        } catch DecodingError.dataCorrupted(let context) {
            fatalError("Failed to decode '\(file)' from bundle data due to corrupted/invalid JSON data - \(context.debugDescription).")
        } catch {
            fatalError("Failed to decode '\(file)' from bundle data with error: \(error.localizedDescription).")
        }
    }
}
