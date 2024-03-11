//
//  ErrorView.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 3/9/24.
//

import SwiftUI
import CoreLocation

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        self.makeView()
    }
}

extension ErrorView {
    @ViewBuilder
    private func makeView() -> some View {
        switch error {
        case LocationError.notAuthorized, CLError.denied, CLError.geocodeCanceled:
            VStack {
                Image(.surprised)
                    .resizable()
                    .frame(width: 50, height: 50)
                Text(WeatherConstants.locationError)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        default:
            VStack {
                Image(.surprised)
                    .resizable()
                    .frame(width: 50, height: 50)
                Text(error.localizedDescription)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40).padding()
                Button(action: retryAction, label: { Text(WeatherConstants.retry).bold() })
            }
  
        }
    }
}

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: NSError(domain: "", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "Something went wrong"]),
                  retryAction: { })
    }
}
#endif
