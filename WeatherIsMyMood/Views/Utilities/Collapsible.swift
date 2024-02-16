//
//  Collapsible.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/16/24.
//

import SwiftUI

struct Collapsible<Content: View>: View {
    @State var label: () -> Text
    @State var content: () -> Content
    
    @State private var collapsed: Bool = true
    
    var body: some View {
        VStack {
            Button(
                action: { self.collapsed.toggle() },
                label: {
                    HStack {
                        self.label()
                        Spacer()
                        Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
                    }
                    .padding(.bottom, 1)
                    .background(Color.white.opacity(0.01))
                }
            )
            .buttonStyle(PlainButtonStyle())
            
            VStack {
                self.content()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            .clipped()
            .animation(.easeInOut(duration: 0.2), value: collapsed)
            .transition(.slide)
        }
        .background {
            Color.red
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
                .clipped()
                .animation(.easeInOut(duration: 0.2), value: collapsed)
                .transition(.slide)
        }
        
    }
}

#Preview {
    Collapsible(
        label: {
            Text("This is collapsible!")
        }, content: {
            VStack {
                Text("1asd;fkjas;dfka;sdfka;sdkfja;ldkfj")
                Text("11asd;fkjas;dfka;sdfka;sdkfja;ldkfj")
                Text("11asd;fkjas;dfka;sdfka;sdkfja;ldkfj")
                Text("11asd;fkjas;dfka;sdfka;sdkfja;ldkfj")
                Text("11asd;fkjas;dfka;sdfka;sdkfja;ldkfj")
            }

        }
    )
    .background {
        Color.red
    }
}
