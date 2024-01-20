//
//  DemoWidget.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 1/20/24.
//

import SwiftUI
import WidgetKit
import AppIntents

struct DemoWidgetEntry: TimelineEntry {
    var date: Date
    let title: String
}

struct DemoWidget: Widget {
    var body: some WidgetConfiguration {
        makeWidgetConfiguration()
    }
    
    func makeWidgetConfiguration() -> some WidgetConfiguration {
        // Dynamic Config
        if #available(iOS 17.0, *) {
            return AppIntentConfiguration(kind: "DemoWidgetConfig",
                                   intent: DemoCustomAppIntent.self,
                                   provider: DemoWppIntentProvider()) { entry in
                DemoWidgetView(entry: entry)
            }.supportedFamilies([.systemSmall])
            
        } else {
            return IntentConfiguration(kind: "DemoWidgetConfig",
                                intent: DemoWidgetConfigIntent.self,
                                provider: DemoSiriKitAppIntentProvider()) { entry in
                DemoWidgetView(entry: entry)
            }.supportedFamilies([.systemSmall])
        }
        
        
        // Static Config
       
//        StaticConfiguration(kind: "DemoWidgetConfig",
//                            provider: DemoWidgetTimelineProvider()) { entry in
//            DemoWidgetView(entry: entry)
//        }.supportedFamilies([.systemSmall])
  
    }
}

struct DemoWidgetView: View {
    var entry: DemoWidgetEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            Text("\(entry.title)")
                .widgetBackground2()
        default:
            Text("Default")
                .widgetBackground2()
        }
    }
}


/* Dynamic */
struct DemoCustomAppIntent: WidgetConfigurationIntent {
    static var intentClassName: String = "DemoAppIntentClass"
    static var title: LocalizedStringResource = "DemoAppIntentTitle"
//    static var description = IntentDescription("Type in Quote")
    
    @Parameter(title: "Personal Quote")
    var title: String?
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct DemoWppIntentProvider: AppIntentTimelineProvider {

    typealias Entry = DemoWidgetEntry
    
    typealias Intent = DemoCustomAppIntent
    
    func placeholder(in context: Context) -> DemoWidgetEntry {
        DemoWidgetEntry(date: Date(), title: "PlaceholderTitle")
    }
    
    func snapshot(for configuration: DemoCustomAppIntent, in context: Context) async -> DemoWidgetEntry {
        return DemoWidgetEntry(date: Date(), title: configuration.title ?? "no-text")
    }
    
    func timeline(for configuration: DemoCustomAppIntent, in context: Context) async -> Timeline<DemoWidgetEntry> {
        let entry = DemoWidgetEntry(date: Date(), title: configuration.title ?? "no-text")
        return Timeline(entries: [entry], policy: .atEnd)
    }

}

struct DemoSiriKitAppIntentProvider: IntentTimelineProvider {
    
    typealias Entry = DemoWidgetEntry
    typealias Intent = DemoWidgetConfigIntent
    
    func placeholder(in context: Context) -> DemoWidgetEntry {
        return DemoWidgetEntry(date: Date(), title: "PlaceholderTitle")
    }
    
    func getSnapshot(for configuration: DemoWidgetConfigIntent, in context: Context, completion: @escaping (DemoWidgetEntry) -> Void) {
        completion(DemoWidgetEntry(date: Date(), title: configuration.title ?? "no-text"))
    }
    
    func getTimeline(for configuration: DemoWidgetConfigIntent, in context: Context, completion: @escaping (Timeline<DemoWidgetEntry>) -> Void) {
        let entry = DemoWidgetEntry(date: Date(), title: configuration.title ?? "no-text")
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
}

/* Static */
struct DemoWidgetTimelineProvider: TimelineProvider {

    typealias Entry = DemoWidgetEntry
    
    func placeholder(in context: Context) -> DemoWidgetEntry {
        return DemoWidgetEntry(date: Date(), title: "PlaceholderTitle")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DemoWidgetEntry) -> Void) {
        let entry = DemoWidgetEntry(date: Date(), title: "SnapshotTitle")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DemoWidgetEntry>) -> Void) {
        let entry = DemoWidgetEntry(date: Date(), title: "TimelineTitle")
        completion(Timeline(entries: [entry],
                            policy: .atEnd))
    }
    
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    DemoWidget()
} timeline: {
    DemoWidgetEntry(date: Date(), title: "PreviewTimelineTitle")
}

extension View {
    func widgetBackground2() -> some View {
         if #available(iOS 17.0, *) {
            
             return containerBackground(for: .widget) {
                 Color.pink
             }
         } else {
             return background {
                 Color.green
             }
         }
    }
}
