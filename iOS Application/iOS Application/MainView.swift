//
//  MainView.swift
//  iOS Application
//
//  Created by JungJiyoung on 2021/07/19.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView{
            VStack{
                Text("Hello").navigationTitle("첫번째 페이지")
                NavigationLink(destination: ContentView(),
                    label :{
                        Text("Navigate")
                    }
                )
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
