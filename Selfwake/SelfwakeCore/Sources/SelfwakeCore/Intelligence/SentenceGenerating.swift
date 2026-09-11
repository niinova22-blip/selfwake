import Foundation

/// Bölüm 8'deki her üretici bu protokole uyar. View katmanı hangi
/// üreticinin AI mı kural tabanlı mı çalıştığını bilmez.
public protocol SentenceGenerating {
    func generate() async -> String
}
