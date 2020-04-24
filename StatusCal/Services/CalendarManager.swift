//
//  CalendarManager.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 21.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import EventKit


class CalendarManager {
    
    static let shared = CalendarManager()
    
    private var eventStore: EKEventStore = EKEventStore()
    
    init() {
        
    }
    
    func storeStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            completion(granted)
        }
    }
    
    func containsEvents(startDate: Date, endDate: Date, calendar: EKCalendar) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        return eventStore.events(matching: predicate).count  > 0
    }
}
