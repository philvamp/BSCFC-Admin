//
//  ViewModel.swift
//  BSCFC Admin App
//
//  Created by Phil Vamplew on 22/09/2023.
//

import Foundation
import SwiftUI

enum AppState {
    case signedOut
    case loading
    case dataAvailable([Note])
    case error(Error)
}

// singleton object to store user data
@MainActor
class ViewModel : ObservableObject {
    
    @Published var state : AppState = .signedOut
    
    // MARK: Manage the notes
    
    // just a local cache
    var notes : [Note] = []
    
    // load notes from the backend
    @discardableResult
    func loadNotes() async -> [Note] {
        if self.notes.isEmpty {
            self.notes = await Backend.shared.queryNotes()
        }
        self.state = .dataAvailable(self.notes)
        return self.notes
    }

    // add a note to the mode and the backend
    func addNote(name: String, description: String?, tdate: String?, agegroup: String?, gender: String?, location: String?,  realdate: Date?, pitch: String?) async {
        
      
        let note = Note(id : UUID().uuidString,
                        name: name,
                        description: description,
                        tdate: tdate,
                        agegroup: agegroup,
                        gender: gender,
                        location: location,
                        realdate: realdate,
                        pitch: pitch,
                        createdAt: Date.now)

        // asynchronously store the note (and assume it will succeed)
        Task {
            await Backend.shared.createNote(note: note)
        }
        self.notes.append(note)
        
        // force UI update
        self.state = .dataAvailable(self.notes)
    }
    
    // delete a node from the model and the backend
    func deleteNote(at: Int) {

        let note = self.notes.remove(at: at)
        
        // asynchronously remove from database
        Task {
            await Backend.shared.deleteNote(note: note)

        }
    }
    
    // MARK: Authentication
    
    public func getInitialAuthStatus() async throws {
        
        // when running swift UI preview - do not change isSignedIn flag
        if !EnvironmentVariable.isPreview {
            
            let status = try await Backend.shared.getInitialAuthStatus()
            print("INITIAL AUTH STATUS is \(status)")
            switch status {
            case .signedIn: self.state = .loading
            case .signedOut, .sessionExpired:  self.state = .signedOut
            }
        }
    }
    
    public func listenAuthUpdate() async {
            for try await status in await Backend.shared.listenAuthUpdate() {
                print("AUTH STATUS LOOP yielded \(status)")
                switch status {
                case .signedIn:
                    self.state = .loading
                case .signedOut, .sessionExpired:
                    self.notes = []
                    self.state = .signedOut
                }
            }
            print("==== EXITED AUTH STATUS LOOP =====")
    }
    
    // asynchronously sign in
    // change of sttaus will be picked up by `listenAuthUpdate`
    // that will trigger the UI update
    public func signIn() {
        Task {
            await Backend.shared.signIn()
        }
    }
    
    // asynchronously sign out
    // change of sttaus will be picked up by `listenAuthUpdate`
    // that will trigger the UI update
    public func signOut() {
        Task {
            await Backend.shared.signOut()
        }
    }
}

extension ViewModel {
    static var mock : ViewModel = mockedData(isSignedIn: true)
    static var signedOutMock : ViewModel = mockedData(isSignedIn: false)

    private static func mockedData(isSignedIn: Bool) -> ViewModel {
        let model = ViewModel()
    //    let desc = "this is a very long description that should fit on multiiple lines.\nit even has a line break\nor two."
        
    //    let n1 = Note(id: "01", name: "Hello world", description: desc, image: "mic")
    //    let n2 = Note(id: "02", name: "A new note", description: desc, image: "phone")
    //    model.notes = [ n1, n2 ]
        if isSignedIn {
            model.state = .dataAvailable(model.notes)
        } else {
            model.state = .signedOut
        }

   //     n1.imageURL = Bundle.main.url(forResource: "4BC64B0D-A56E-4218-9993-C5C4EDF9C044", withExtension: "png")
   //     n2.imageURL = Bundle.main.url(forResource: "27F5F399-2D1D-476F-84BB-E50913535352", withExtension: "png")

        return model
    }
}
