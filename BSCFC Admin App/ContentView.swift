//
//  ContentView.swift
//  BSCFC Admin App
//
//  Created by Phil Vamplew on 21/09/2023.
//


import SwiftUI
import Foundation

struct ContentView: View {
    @EnvironmentObject public var model: ViewModel
    @State var showCreateNote = false
    

    
    var body: some View {

        ZStack {
            switch(model.state) {
            case .signedOut:
                VStack {
                    SignInButton(model : self.model)
                        .padding(.bottom)
                    SignOutButton(model : self.model)
                }
                
            case .loading:
                ProgressView()
                    .task() {
                        await self.model.loadNotes()
                    }
                
            case .dataAvailable(let notes):
                navigationView(notes: notes)
                
            case .error(let error):
                Text("There was an error: \(error.localizedDescription)")
            }

        }
        .task {
            
            // get the initial authentication status. This call will change app state according to result
            try? await self.model.getInitialAuthStatus()
            
            // start a long polling to listen to auth updates
            await self.model.listenAuthUpdate()
        }
    }
    
    @ViewBuilder
    func navigationView(notes: [Note]) -> some View {
        NavigationView {
            List {
                ForEach(notes) { note in
                    ListRow(note: note)
                }.onDelete { indices in
                    indices.forEach {
                        self.model.deleteNote(at: $0)
                    }
                }
            }
            .navigationTitle(Text("Current Bookings"))

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    SignOutButton(model: self.model)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showCreateNote.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateNote) {
            AddNoteView(isPresented: self.$showCreateNote, model: self.model)
        }
    }
}

struct ListRow: View {
    @ObservedObject var note : Note
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if let tdate = note.tdate {
                Text(tdate)
                .bold()
            }
            Group {
                Text(note.name)
                    .bold()
                if let description = note.description {
                    Text(description)
                        .foregroundColor(.gray)
                }
                if let agegroup = note.agegroup {
                    if let gender = note.gender {
                        Text(agegroup + " " + gender)
                            .foregroundColor(.gray)
                }}

                if let location = note.location {
                    if let pitch = note.pitch   {
                        Text(location + " " + pitch)
                            .foregroundColor(.gray)
                }}
            }
        }
        .padding([.top, .bottom], 5)
        
    }
}

struct AddNoteView: View {
    @Binding var isPresented: Bool
    var model: ViewModel

    @State var name : String        = ""
    
    @State var description : String = ""

    @State var agegroup : String    = "U8"
    @State var gender : String      = "Boys"

    
    @State var tdate = Date.now
    @State private var selectedGender = "Boys"
    @State private var location = "Friedberg Ave"
    @State private var pitch = "7v7"
    
    var genders = ["Boys", "Girls"]
    var agegroups = ["U8", "U9", "U10", "U11", "U12", "U13", "U14", "U15", "U16", "U17"]
    var locations = ["Albury", "Birchwood", "College", "Friedberg Ave", "Grange Paddocks",  "Jobbers Wood", "Pearce House", "Other"]
    var pitches = ["7v7", "Senior Pitch", "3G", "9v9", "Junior",  "Match Pitch", "Pitch 1", "Pitch 2", "Pitch 3", "Pitch 6+7", "MS1", "MS2", "J1", "J2", "S1", "S2", "S3", "Top Pitch", "Lower Pitch", "Other"]


    var body: some View {
        Form {
        
            Section(header: Text("BSCFC Sports Camera Booking System")) {
                 
               DatePicker(selection: $tdate, in: Date.now..., displayedComponents: [.date, .hourAndMinute]) {

                    Text("Select date")
                }
                TextField("Managers Name", text: $name)
                TextField("Team Name", text: $description)

                Picker("Select age group", selection: $agegroup) {
                     ForEach(agegroups, id: \.self) {
                         Text($0)
                     }
                }
                Picker("Select gender", selection: $gender) {
                    ForEach(genders, id: \.self) {
                        Text($0)
                    }
                }
                Picker("Select location", selection: $location) {
                    ForEach(locations, id: \.self) {
                        Text($0)
                    }
                }
                Picker("Select pitch", selection: $pitch) {
                    ForEach(pitches, id: \.self) {
                        Text($0)
                    }
                }
            }

            Section {
                Button(action: {
                    self.isPresented = false
                
                    withAnimation {
                        let _ = Task { await self.model.addNote(name: self.name,
                                                                description: self.description,
                                                                tdate: tdate.formatted(date: .abbreviated, time: .shortened),
                                                                agegroup : agegroup,
                                                                gender : gender,
                                                                location: location,
                                                                realdate: tdate,
                                                                pitch:pitch)
                        }
                    }
                }) {
                    Text("Create booking")
                }
            }
        }
    }
}
    
struct SignInButton: View {
    var model : ViewModel
    var body: some View {
        Button(action: { self.model.signIn() }){
            HStack {
                Image(systemName: "person.fill")
                    .scaleEffect(2)
                    .padding()
                Text("Sign In")
                    .font(.largeTitle)
                    .bold()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(30)
        }
    }
}

struct SignOutButton : View {
    var model : ViewModel
    var body: some View {
        Button(action: { self.model.signOut() }) {
                Text("Sign Out")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {

        let user1 = ViewModel.mock
        let user2 = ViewModel.signedOutMock
        return Group {
            ContentView().environmentObject(user1)
            ContentView().environmentObject(user2)
            AddNoteView(isPresented: .constant(true), model: user1)
        }
    }
}
