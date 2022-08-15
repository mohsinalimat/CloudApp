//
//  UserDefaultsService.swift
//  CollectionViewTest
//
//  Created by Timofey on 14/8/22.
//

import Foundation



class UserDefaultsService {
  
  enum Constants {
    static let layoutKey = "layout"
  }
  
  static let shared = UserDefaultsService()
  
  private let st = UserDefaults.standard
  
  private init() {}
  
  func getLayoutType() -> LayoutType {
    
    let rawValue = st.integer(forKey: Constants.layoutKey)
    guard let layout = LayoutType(rawValue: rawValue) else {
      return .grid
    }
    return layout
  }
  
  func setLayout(to type: LayoutType) {
    st.setValue(type.rawValue, forKey: Constants.layoutKey)
  }
}
