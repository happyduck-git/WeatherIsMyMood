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
                Text("We cannot use your location.\nPlease go to Settings \nand give permission to us\nso that we can provide you weather services!")
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
                Button(action: retryAction, label: { Text("Retry").bold() })
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
