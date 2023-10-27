//
//  BSCFC_Admin_AppApp.swift
//  BSCFC Admin App
//
//  Created by Phil Vamplew on 21/09/2023.
//

import SwiftUI

@main
struct BSCFC_Admin_AppApp: App {

        // trigger initialization of the Backend
        let backend = Backend.shared

        var body: some Scene {

            WindowGroup {
                ContentView().environmentObject(ViewModel())
            }
        }
    }
