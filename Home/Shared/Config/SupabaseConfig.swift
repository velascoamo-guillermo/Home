// Home/Shared/Config/SupabaseConfig.swift
import Foundation

enum SupabaseConfig {
    static let url: URL = {
        guard let str = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
              let url = URL(string: str) else {
            fatalError("SUPABASE_URL missing from Info.plist — add it from Config.xcconfig")
        }
        return url
    }()

    static let anonKey: String = {
        guard let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
              !key.isEmpty else {
            fatalError("SUPABASE_ANON_KEY missing from Info.plist — add it from Config.xcconfig")
        }
        return key
    }()
}
