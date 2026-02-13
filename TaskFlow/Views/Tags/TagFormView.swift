//
//  TagView.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//

import SwiftUI

struct TagFormView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: TagFormViewModel
    
    var body: some View {
        Form {
            
            // Infos principales
            Section(header: Text("Tag")) {
                
                TextField("Tag", text: $vm.tagName)
                    .textInputAutocapitalization(.sentences)
                

            }
            

        }
    }
}
