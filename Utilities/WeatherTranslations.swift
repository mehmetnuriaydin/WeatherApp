import Foundation

func translateWeatherCondition(_ condition: String) -> String {
    switch condition.lowercased() {
    case "clear sky":
        return "Açık Gökyüzü"
    case "sunny":
        return "Güneşli"
    case "few clouds":
        return "Az Bulutlu"
    case "scattered clouds":
        return "Parçalı Bulutlu"
    case "broken clouds":
        return "Dağınık Bulutlar"
    case "cloudy":
        return "Bulutlu"
    case "shower rain":
        return "Sağanak Yağmur"
    case "rain":
        return "Yağmurlu"
    case "thunderstorm":
        return "Fırtına"
    case "snow":
        return "Karlı"
    case "mist":
        return "Sisli"
    case "overcast clouds":
        return "Kapalı Bulutlu"
    default:
        return condition.capitalized // Bilinmeyen durumlar için orijinal açıklamayı döndür
    }
}
