//
//  CityCurrentWeatherView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import SwiftUI
import WeatherKit
import UIKit.UIImage
import PDFKit

struct CityCurrentWeatherView: View {
    
    private let fireStoreManager = FirestoreManager.shared
    
    //MARK: - Properties
    @Binding var weather: Weather?
    @Binding var cityName: String
    @State var weatherImage: UIImage?
    
    //MARK: - View
    var body: some View {
        if let weather {
            ZStack {
                if let weatherImage {
                    Image(uiImage: weatherImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.5)
                } else {
                    Circle()
                        .fill(.clear)
                        .background {
                            LinearGradient(
                                colors: [.clear,
                                         .white.opacity(0.6),
                                         .clear],
                                startPoint: .top,
                                endPoint: .bottomTrailing
                            )
                            
                            .clipShape(Circle())
                        }
                }
                
                VStack {
                    TitleView(cityName: $cityName,
                              weather: $weather)
                    
                    HStack {
                        SunStatusTimeView(dailyWeather: weather.dailyForecast[0], status: .sunrise)
                            .padding()
                        SunStatusTimeView(dailyWeather: weather.dailyForecast[0], status: .sunset)
                            .padding()
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.3))
                    }
                    
                }
            }
            .task(id: self.weather) {
                
                do {
                    let condition = WeatherCondition.getWeatherIconName(of: weather.currentWeather.condition.rawValue)
                    let data = try await fireStoreManager.fetchBackground(condition)
                    if let image = pdfToImage(pdfData: data) {
                        self.weatherImage = image
                    } else {
                        self.weatherImage = UIImage(resource: .weatherMorningBright)
                    } 
                    
                } catch {
                    print(error)
                }
                
            }
        }
            
    }
}

extension CityCurrentWeatherView {

    func pdfToImage(pdfData: Data) -> UIImage? {
        // Create a PDF document from the data
        guard let pdfDocument = PDFDocument(data: pdfData) else {
            return nil
        }

        // Get the first page of the PDF
        guard let pdfPage = pdfDocument.page(at: 0) else {
            return nil
        }

        // Determine the size of the PDF page
        let pdfPageBounds = pdfPage.bounds(for: .mediaBox)
        let pdfPageRect = CGRect(origin: .zero, size: pdfPageBounds.size)

        // Create a UIGraphicsImageRenderer to draw the PDF into an image
        let renderer = UIGraphicsImageRenderer(size: pdfPageRect.size)
        let img = renderer.image { ctx in
            // Draw the PDF page into the image context
            ctx.cgContext.translateBy(x: 0.0, y: pdfPageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            ctx.cgContext.drawPDFPage(pdfPage.pageRef!)
        }

        return img
    }

}

#Preview {
    WeatherView()
}
