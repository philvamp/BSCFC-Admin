//
//  Model.swift
//  BSCFC Admin App
//
//  Created by Phil Vamplew on 21/09/2023.
//

import Foundation


class Note : Identifiable, ObservableObject {
    var id          : String
    var name        : String
    var description : String?
    var tdate       : String?
    var agegroup    : String?
    var gender      : String?
    var location    : String?
    var realdate    : Date? = Date()
    var pitch       : String?
    var createdAt   : Date?
    @MainActor @Published var imageURL : URL?
    
    init(id: String,
         name        : String,
         description : String? = nil,
         tdate       : String? = nil,
         agegroup    : String? = nil,
         gender      : String? = nil,
         location    : String? = nil,
         realdate    : Date? = nil,
         pitch       : String? = nil,
         createdAt   : Date? = nil)
    {
        self.id          = id
        self.name        = name
        self.description = description
        self.tdate       = tdate
        self.agegroup    = agegroup
        self.gender      = gender
        self.location    = location
        self.realdate    = realdate
        self.pitch       = pitch
        self.createdAt   = createdAt
    }
    
    // convert from backend data struct to our model
    convenience init(from data: NoteData) {
        self.init(id: data.id,
                  name: data.name,
                  description: data.description,
                  tdate: data.tdate,
                  agegroup: data.agegroup,
                  gender: data.gender,
                  location: data.location,
                  realdate: data.realdate?.foundationDate,
                  pitch: data.pitch,
                  createdAt: data.createdAt?.foundationDate)
    }
    
    // convert our model to backend data format
    var data: NoteData {
        get {
            return NoteData(id:             self.id,
                            name:           self.name,
                            description:    self.description,
                            agegroup:       self.agegroup,
                            gender:         self.gender,
                            location:       self.location,
                            tdate :         self.tdate, 
                            realdate:       .init(self.realdate ?? Date.now),
                            pitch:          self.pitch,
                           createdAt:       .init(self.createdAt ?? Date.now))
        }
    }
    
    
    
    // provide a display ready representatin of the date
    var date: String {
        get {
            if let date = self.createdAt {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return formatter.string(from: date)
            } else {
                return ""
            }
        }
    }
    
    
}
