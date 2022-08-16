//
//  FilesViewController.swift
//  CloudApp
//
//  Created by Timofey on 15/8/22.
//

import Foundation
import UIKit
import RxSwift



class FilesViewController: UIViewController {
  
  private enum Constants {
    static let horizontalMarginMult: CGFloat = 0.0555
  }
  
  private let bag = DisposeBag()
  // UI properties
  private var searchBar: UISearchBar!
  private var filesLabel: UILabel!
  private var filesCollectionController: FilesCollectionViewController!
  private var layoutSlider: LayoutSwitcherView!
  // Datasource properties
  var foldername: String
  
  // State properties
  private var layoutType: LayoutType {
    didSet {
      UserDefaultsService.shared.setLayout(to: layoutType)
    }
  }
  
  init(foldername: String, layoutType type: LayoutType) {
    self.foldername = foldername
    self.layoutType = type
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupObserver()
  }
  
  private func setupObserver() {
    FolderFileActionView.eventRelay.subscribe(onNext: { [weak self] eventType in
      switch eventType {
      case .createFolder:
        self?.tryAddFolder()
      case .addFile:
        self?.addFile()
      case .addMedia:
        self?.addMedia()
      }
    })
      .disposed(by: bag)
    
    layoutSlider.switchRelay.subscribe(onNext: { [weak self] type in
      self?.filesCollectionController.viewModel.output.send(.changeLayout(type: type))
    })
      .disposed(by: bag)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
// MARK: - MyView actions
extension FilesViewController {
  
  private func addFile() {
    
  }
  
  private func addMedia() {
    
  }
  
  private func tryAddFolder() {
    DispatchQueue.main.async {
      let alertController = AlertFactory.getErrorAlert(message: "Cant create folder inside a folder")
      self.present(alertController, animated: true)
    }
  }
}

// MARK: - UISearchBarDelegate
extension FilesViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    filesCollectionController.output.send(.filterFiles(text: searchText))
  }
}

// MARK: - Setup UI
extension FilesViewController {
  
  private func setupUI() {
    view.backgroundColor = .mainBg
    setupLayoutView()
    setupCollectionView()
    setupLabel()
    setupSearchBar()
    setupConstraints()
  }
  
  private func setupLayoutView() {
    layoutSlider = LayoutSwitcherView(type: layoutType)
  }
  
  private func setupCollectionView() {
    let viewModel = FilesListViewModel(foldername: foldername)
    filesCollectionController = FilesCollectionViewController(
      viewModel: viewModel,
      layoutType: layoutType
    )
  }
  
  private func setupLabel() {
    filesLabel = UILabel(
      text: "Files",
      fontSize: 16,
      weight: .bold,
      textColor: .lightTextColor
    )
  }
  
  private func setupSearchBar() {
    searchBar = UISearchBar()
    searchBar.delegate = self
    searchBar.placeholder = "Find in Root Folder"
    if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
      textFieldInsideSearchBar.textColor = .white
    }
    self.navigationItem.titleView = searchBar
  }
  
  private func setupConstraints() {
    let width = view.bounds.width
    
    view.addSubview(filesLabel)
    
    filesLabel.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
        .offset(40)
      make.horizontalEdges
        .equalToSuperview()
        .inset(Constants.horizontalMarginMult * width)
    }
    
    view.addSubview(layoutSlider)
    
    layoutSlider.snp.makeConstraints { make in
      make.centerY.equalTo(filesLabel)
      make.width.equalTo(103)
      make.height.equalTo(23)
      make.trailing
        .equalToSuperview()
        .offset(-Constants.horizontalMarginMult * width)
    }
    
    view.addSubview(filesCollectionController.view)
    
    filesCollectionController.view.snp.makeConstraints { make in
      make.horizontalEdges
        .equalToSuperview()
        .inset(Constants.horizontalMarginMult * width)
      make.top
        .equalTo(filesLabel.snp.bottom)
        .offset(20)
      make.bottom.equalToSuperview()
    }
  }
}