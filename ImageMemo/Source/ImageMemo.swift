//
//  ImageMemoApp.swift
//  ImageMemo
//
//  Created by Ven Jandhyala on 1/1/24.
//

/**************************************************************************************\

  .----------------------------------------.
  *.          Model | View <-> Core         .*
  ,========================================,
  |                                         |
  |                                         |
  |     ( ViewController -----[ View ] )    |
  |     |                                   |
  |    {App} --------+                      |
  |      |           |                      |
  |   /----\    +-----------+    .------.   |
  |  | Core | --+  Reactor  +---[ System ]  |
  |   \----/    +-----------+    '------'   |
  |      |           |                      |
  |   {Source} ------+                      |
  |      |                                  |
  |     ( ModelController ---[ Model ] )    |
  |                                         |
  |,                                       ,|
  .'====================================='.
  *         Abstract Architecture          *
  '---------------------------------------'
 
\**************************************************************************************/


import Combine
import Observation
import os
import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif


//**************************************************************************************
// MARK: - App

@main
struct ImageMemo:
  App,
  AppMappable
{
  let core: CoreType = CoreType()
  var source: SourceType = SourceType()
  
  var map: AppMapType = .init()
    
  var body: some Scene {
    WindowGroup {
      AppView(core: core)
    }
  }
  
  init()
  {
    self.core.source = source
    self.source.core = core
  }
}


typealias AppType              = ImageMemo
typealias AppMapType           = NavMap

typealias CoreType             = ImageCore
typealias ReactorType          = SignalReactor
typealias SystemType           = SystemCommand

typealias SourceType           = ImageSource
typealias SourceElementType    = ImageSourceElement
typealias SourceKeyElementType = ImageType

typealias ModelTypes           = [any Modelable]
typealias ModelControllerTypes = [any SourceModelController]

typealias ViewTypes            = [any Viewable]
typealias ViewControllerTypes  = [any AppViewController]



//**************************************************************************************
// MARK: - App Map

struct NavMap:
  AppMap
{
  var state: AppMapState = .init()
}


//**************************************************************************************
// MARK: - App Core

final
class ImageCore:
  Core
{
  typealias CoreApp = AppType
  typealias CoreSource = SourceType
  typealias CoreReactor = ReactorType
  typealias CoreSystem = SystemType
  
  var app: CoreApp?
  var source: CoreSource?
  let reactor: CoreReactor
  let system: CoreSystem
  
  var log: Log
  var mon: Mon
  
  init()
  {
    self.reactor = ReactorType()
    self.system = SystemType()
    
    self.log = Log()
    self.mon = Mon()
  }
}


final
class SignalReactor:
  Reactor
{
  typealias ReactorCore = CoreType
}


final
class SystemCommand:
  System
{
  let main: IMSystem = .main()
  
  var reactor: SignalReactor = .init()
  
  var jobs: JobsCom = .init()
  
  var mem: MemCom = .init()
  var cpu: CPUCom = .init()
  var gpu: GPUCom = .init()
  var net: NetCom = .init()
  
  var io: IOCom = .init()
  
  // SystemCommand Modules --------------------------------------------------
  
  class JobsCom:
    SystemJobsCom
  {}

  
  @objc
  class NetCom:
    NSObject,
    URLSessionDelegate,
    URLSessionDataDelegate,
    URLSessionDownloadDelegate,
    SystemNetCom
  {
    func urlSession(
      _ session: URLSession,
      downloadTask: URLSessionDownloadTask,
      didFinishDownloadingTo location: URL
    ) {
      print("test")
    }
  }

  
  class MemCom:
    SystemMemCom
  {
    func stats() 
      -> [String: Int]
    {
      return [:]
    }
    
    func cacheAdd<T> (
      _ object: T,
      forKey key: String
    ) throws -> Bool
    {
      return false
    }
  }

  
  class CPUCom:
    SystemCPUCom
  {}

  class GPUCom:
    SystemGPUCom
  {}
  
  class IOCom:
    SystemIOCom
  {}
}


//**************************************************************************************
// MARK: - App Source

@Observable
final
class ImageSource:
  Source
{
  var elementTypes: [any SourceElement.Type] = [
    ImageType.self
  ]
  var elements: [ElementMetatypeID: [any SourceElement]] = [:]
  
  var keyElements: [SourceKeyElementType] {
    get {
      guard 
        let keyElements = elements[SourceKeyElementType.metatypeID]
          as? [SourceKeyElementType]
      else { return [] }
      return keyElements
    }
    
    set {
      elements[KeyElement.metatypeID] = newValue
    }
  }
  // TODO: count and keyCount should be separate.
  var count: Int               { keyElements.count }
  var focused: SourceKeyElementType?
  var selected: Set<SourceKeyElementType> = .init()
  var selectedCount: Int       { selected.count }
  
  @ObservationIgnored
  var core: CoreType?
  
  init()
  {
    self.elements = [
      ImageType.metatypeID: [
        ImageType("lotus"),
        ImageType("forest"),
        ImageType("space"),
      ]
    ]
  }
}


protocol ImageSourceElement:
  SourceElement
{}


struct ImageType:
  ImageSourceElement
{
  let id: UUID = UUID()
  
  var name: String
  var image: Image?
  
  init(
    _ name: String
  ) {
    self.name = name
  }
  
  static
  func == (
    lhs: ImageType,
    rhs: ImageType
  ) -> Bool
  {
    // TODO: compare Hash of Image File Data, but not including Memo Data.
    return true
  }
  
  static
  func < (
    lhs: ImageType,
    rhs: ImageType
  ) -> Bool
  {
    // TODO: maybe compare File Sizes or
    return true
  }
}


//**************************************************************************************
// MARK: - App

protocol AppMappable
{
  associatedtype AppMapType: AppMap
  
  var map: AppMapType { get set }
}


protocol AppMap
{
  var state: AppMapState { get set }
}


struct AppMapState
{
  struct Place
  {}
  
  struct Transition
  {}
  
  struct Context
  {}
  
  struct Token
  {}
}


//**************************************************************************************
// MARK: - Core

protocol Core:
  AnyObject
{
  associatedtype CoreApp: App
  associatedtype CoreSource: Source
  associatedtype CoreReactor: Reactor
  associatedtype CoreSystem: System
  
  var app: CoreApp? { get set }
  var source: CoreSource? { get set }
  var reactor: CoreReactor { get }
  var system: CoreSystem { get }
  
  var log: Log { get set }
  var mon: Mon { get set }
}


protocol Reactor:
  AnyObject
{
  associatedtype ReactorCore: Core
}


protocol System:
  AnyObject
{
  associatedtype SystemReactor: Reactor
  associatedtype SystemJobs: SystemJobsCom
  associatedtype SystemMem: SystemMemCom
  associatedtype SystemCPU: SystemCPUCom
  associatedtype SystemGPU: SystemGPUCom
  associatedtype SystemNet: SystemNetCom
  associatedtype SystemIO: SystemIOCom
  
  var main: IMSystem { get }
  
  var reactor: SystemReactor { get set }
  
  var jobs: SystemJobs { get }
  
  var mem: SystemMem { get }
  var cpu: SystemCPU { get }
  var gpu: SystemGPU { get }
  var net: SystemNet { get }
  
  var io: SystemIO { get }
}


protocol SystemJobsCom {}
protocol SystemMemCom {}
protocol SystemCPUCom {}
protocol SystemGPUCom {}
protocol SystemNetCom {}
protocol SystemIOCom {}


//**************************************************************************************
// MARK: - Source

protocol Source:
  AnyObject
{
  associatedtype KeyElement: SourceElement
  associatedtype SourceCore: Core
  
  typealias ElementMetatypeID = Int
  
  var elementTypes: [any SourceElement.Type]
  { get set }
  
  var elements: [ElementMetatypeID: [any SourceElement]]
  { get set }
  
  var keyElements: [KeyElement] 
  { get set }
  
  var count: Int                { get }
  var focused: KeyElement?      { get set }
  var selected: Set<KeyElement> { get set }
  var selectedCount: Int        { get }
  
  var core: SourceCore? { get set }
}


protocol SourceElement:
  Identifiable,
  Equatable,
  Comparable,
  Hashable
{
  static var metatypeID: Int { get }
  
  var id: UUID { get }
}


extension SourceElement
{
  static var metatypeID: Int {
    return ObjectIdentifier(self).hashValue
  }
  
  func hash(
    into hasher: inout Hasher
  ) {
    hasher.combine(id)
  }
}


//**************************************************************************************
// MARK: - Model

protocol Modelable {}
protocol SourceModelController: 
  AnyObject
{}


//**************************************************************************************
// MARK: - View

protocol Viewable {}
protocol AppViewController: 
  AnyObject
{}



//**************************************************************************************
// MARK: - App Interface

struct AppView:
  View
{
  private var core: CoreType
  
  @State
  private var command: String = ""
  @State
  private var response: String?
  
  var body: some View {
#if SWIFTUI_OFF
    
    RootViewController()
      .environment(core.source)
#if os(macOS)
      .frame(minWidth:    640,
             idealWidth:  1200,
             minHeight:   400,
             idealHeight: 900)
#endif
    
    VStack {
      HStack {
        TextField(
          "Enter Image Link",
          text: $command,
          onCommit: {
            validateCommand(command)
          }
        )
        .padding(8)
        .textFieldStyle(.roundedBorder)
        
        Button {
          validateCommand(command)
        } label: {
          Text("Get Image")
        }
      }
      
      if let response = response {
        Text(response)
          .transition(.opacity)
          .animation(
            .easeOut(duration: 0.5),
            value: response
          )
      }
      
      HStack {
        Button {
          core.log.debug("stat")
        } label: {
          Text("Memo Stat")
        }
        .padding()
      }
    }
    .padding()
    
#elseif SWIFTUI_ON
    
    NavigationSplitView {
      SidebarView(selected: $selected)
    } content: {
      ContentView()
        .frame(minWidth:   240,
               idealWidth: 480)
    } detail: {
      DetailView()
        .frame(minWidth:   100,
               idealWidth: 120,
               maxWidth:   240)
    }
    .navigationSplitViewStyle(.balanced)
    .environment(source as? imageMap)
    
#endif
  }
  
  init(
    core: CoreType
  ) {
    self.core   = core
  }
  
  private
  func validateCommand(
    _ command: String
  ) {
    guard let url = URL(string: command), checkURL(url)
    else {
      withAnimation { response = "Invalid URL for Image." }
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        withAnimation { response = nil }
      }
      return
    }
    
    withAnimation { response = "Downloading Image..." }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation { response = nil }
    }
    
    downloadImage(at: url) { success, error in
      if success {
        core.log.debug("success")
      } else {
        core.log.debug("error :: \(String(describing: error))")
      }
    }
  }
  
  private
  func checkURL(
    _ url: URL
  ) -> Bool
  {
    // TODO: Need safer URL validating here...
    let imageTypes = ["png", "jpg", "gif"]
    return imageTypes.contains(url.pathExtension.lowercased())
  }
  
  func downloadImage(
    at url: URL,
    completion: @escaping (Bool, Error?) -> Void
  ) {
    // TODO: Properly setup URLRequest for more complex HTTP Behavior.
    let session = URLSession.shared
    let request = URLRequest(url: url)
    let downloadTask = session.downloadTask(with: request) 
    { location, response, error in
      
      if let location = location, error == nil {
        do {
          try self.saveImage(from: location)
          completion(true, nil)
        } catch {
          completion(false, error)
        }
      } else {
        completion(false, error)
      }
    }
    downloadTask.resume()
  }
  
  private 
  func saveImage(
    from location: URL
  ) throws
  {
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(
      for: .documentDirectory,
      in: .userDomainMask
    ).first else {
      throw NSError(
        domain: Bundle.main.bundleIdentifier!,
        code: 1001,
        userInfo: [NSLocalizedDescriptionKey: "Documents directory not found."]
      )
    }
    
    let destination =
      documentsDirectory.appendingPathComponent(location.lastPathComponent)
          
    if fileManager.fileExists(atPath: destination.path) {
      try fileManager.removeItem(at: destination)
    }

    try fileManager.moveItem(at: location, to: destination)
  }
}
#Preview { AppView(core: CoreType()) }
  
  
#if os(iOS)
typealias ViewControllerRepresentable = UIViewControllerRepresentable
typealias RootViewControllerType = iPhoneAppViewController
#elseif os(macOS)
typealias ViewControllerRepresentable = NSViewControllerRepresentable
typealias RootViewControllerType = MacAppViewController
#endif
  
  
struct RootViewController:
  ViewControllerRepresentable
{
  @Environment(SourceType.self)
  var source: SourceType
  
#if os(iOS)
  
  func makeUIViewController(
    context: Context
  ) -> RootViewControllerType
  {
    let viewController = RootViewControllerType()
    return viewController
  }
  
  func updateUIViewController(
    _ uiViewController: RootViewControllerType,
    context: Context
  ) {}
  
#elseif os(macOS)
  
  func makeNSViewController(
    context: Context
  ) -> RootViewControllerType
  {
    let viewController = RootViewControllerType(source: source)
    return viewController
  }
  
  func updateNSViewController(
    _ nsViewController: RootViewControllerType,
    context: Context
  ) {}
  
#endif
}


//**************************************************************************************
// MARK: - App Interface UIKit

#if os(iOS)

final
class iPhoneAppViewController:
  UISplitViewController,
  AppViewController
{
  
}

#endif


//**************************************************************************************
// MARK: - App Interface AppKit

#if os(macOS)

final
class MacAppViewController:
  NSSplitViewController,
  AppViewController,
  NSToolbarDelegate
{
  var source: SourceType?
  var navViewController: NavViewController
  var navSplitViewItem: NSSplitViewItem
  var mainViewController: MainViewController
  var mainSplitViewItem: NSSplitViewItem
  
  init(
    source: SourceType
  ) {
    self.source = source
    
    self.navViewController = NavViewController()
    self.navViewController.source  = source
    self.navSplitViewItem = NSSplitViewItem(viewController: navViewController)
    
    self.mainViewController = MainViewController()
    self.mainViewController.source  = source
    self.mainSplitViewItem = NSSplitViewItem(viewController: mainViewController)
    
    super.init(nibName: nil,
               bundle: nil)
  }
  
  required
  init?(
    coder: NSCoder
  ) {
    fatalError("init?(coder:) not implemented.")
  }
  
  override
  func viewDidLoad()
  {
    super.viewDidLoad()
    makeViews()
  }
  
  override
  func viewWillAppear() {
    super.viewWillAppear()
  }
  
  private
  func makeViews()
  {
    addSplitViewItem(navSplitViewItem)
    addSplitViewItem(mainSplitViewItem)
    
    let navView = navViewController.view
    let mainView = mainViewController.view
    
    NSLayoutConstraint.activate([
      navView.widthAnchor.constraint(
        lessThanOrEqualToConstant: 480
      ),
      navView.widthAnchor.constraint(
        greaterThanOrEqualToConstant: 240
      ),
      navView.heightAnchor.constraint(
        equalTo: view.heightAnchor
      ),
      navView.centerYAnchor.constraint(
        equalTo: view.centerYAnchor
      ),
      
      mainView.heightAnchor.constraint(
        equalTo: view.heightAnchor
      ),
      mainView.centerYAnchor.constraint(
        equalTo: view.centerYAnchor
      ),
    ])
    
    navView.frame.size.width = 300
    self.view.needsLayout = true
    
  }
}


//**************************************************************************************
// MARK: - App Interface AppKit - Nav

final
class NavViewController:
  NSViewController,
  AppViewController
{
  var source: SourceType?
  
  var tableView: NSTableView!
  
  let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ColumnCell")
  
  override
  func loadView()
  {
    view = NSView(frame: NSRect.zero)
    makeTableView()
  }
  
  override
  func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override
  func viewWillAppear()
  {
    super.viewWillAppear()
    tableView.reloadData()
  }
  
  override
  func viewDidAppear() {
    super.viewDidAppear()
  }
  
  private
  func makeTableView()
  {
    tableView = NSTableView(frame: view.bounds)
    tableView.delegate = self
    tableView.dataSource = self
    let column = NSTableColumn(
      identifier: NSUserInterfaceItemIdentifier(rawValue: "Column")
    )
    column.title = "Images"
    tableView.addTableColumn(column)
    tableView.selectionHighlightStyle = .regular
    
    let scrollView = NSScrollView(frame: view.bounds)
    scrollView.documentView = tableView
    scrollView.hasVerticalScroller = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(
        equalTo: view.topAnchor
      ),
      scrollView.bottomAnchor.constraint(
        equalTo: view.bottomAnchor
      ),
      scrollView.leadingAnchor.constraint(
        equalTo: view.leadingAnchor
      ),
      scrollView.trailingAnchor.constraint(
        equalTo: view.trailingAnchor
      ),
    ])
  }
}


extension NavViewController:
  NSTableViewDataSource
{
  func numberOfRows(
    in tableView: NSTableView
  ) -> Int
  {
    return source?.count ?? 0
  }
}


extension NavViewController:
  NSTableViewDelegate
{
  func tableView(
    _ tableView: NSTableView,
    viewFor tableColumn: NSTableColumn?,
    row: Int
  ) -> NSView?
  {
    let cell = ImageTableCellView()
    makeCell(cell, row: row)
    return cell
  }
  
  func tableView(
    _ tableView: NSTableView,
    heightOfRow row: Int
  ) -> CGFloat
  {
    return 64
  }
  
  func makeCell(
    _ cellView: ImageTableCellView,
    row: Int
  )
  {
    guard let element = source?.keyElements[row]
    else { return }
    
    cellView.textField?.stringValue = element.name
    cellView.imageView?.image       = NSImage(named: element.name)
  }
  
  func tableView(
    _ tableView: NSTableView,
    shouldSelectRow row: Int
  ) -> Bool
  {
    source?.focused = source?.keyElements[row]
    print("change :: \(source?.focused.debugDescription ?? "")")
    return true
  }
  
  func tableView(
    _ tableView: NSTableView,
    rowActionsForRow row: Int,
    edge: NSTableView.RowActionEdge
  ) -> [NSTableViewRowAction]
  {
    if edge == .trailing {
      let deleteAction = NSTableViewRowAction(
        style: .destructive,
        title: "Delete",
        handler: { (action, row) in
          self.source?.keyElements.remove(at: row)
          tableView.removeRows(at: IndexSet(integer: row),
                               withAnimation: .effectFade)
        }
      )
      deleteAction.backgroundColor = NSColor.red
      
      return [deleteAction]
    }
    
    return []
  }
}


//**************************************************************************************
// MARK: - App Interface AppKit - Main

final
class MainViewController:
  NSViewController,
  AppViewController
{
  var source: SourceType?
  
  var imageView: NSImageView!
  var colorView: ColorView!
  
  init()
  {
    super.init(nibName: nil,
               bundle: nil)
  }
  
  required
  init?(
    coder: NSCoder
  ) {
    fatalError("init?(coder:) not implemented.")
  }
  
  override
  func loadView()
  {
    view = NSView(frame: NSRect.zero)
    
    colorView = ColorView()
    colorView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(colorView)
    
    imageView = NSImageView()
    imageView.imageScaling = .scaleNone
    imageView.imageAlignment = .alignTop
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    let clipView = CenteringClipView()
    clipView.documentView = imageView
    clipView.translatesAutoresizingMaskIntoConstraints = false
    
    let scrollView = NSScrollView(frame: view.bounds)
    scrollView.contentView = clipView
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = true
    scrollView.allowsMagnification = true
    scrollView.maxMagnification = 4.0
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      // colorView ----------------------------
      colorView.widthAnchor.constraint(
        equalTo: view.widthAnchor
      ),
      colorView.heightAnchor.constraint(
        equalTo: view.heightAnchor
      ),
      colorView.centerXAnchor.constraint(
        equalTo: view.centerXAnchor
      ),
      colorView.centerYAnchor.constraint(
        equalTo: view.centerYAnchor
      ),
      
      // scrollView ---------------------------
      scrollView.topAnchor.constraint(
        equalTo: view.topAnchor
      ),
      scrollView.bottomAnchor.constraint(
        equalTo: view.bottomAnchor
      ),
      scrollView.leadingAnchor.constraint(
        equalTo: view.leadingAnchor
      ),
      scrollView.trailingAnchor.constraint(
        equalTo: view.trailingAnchor
      ),
      
      // clipView ---------------------------
      clipView.topAnchor.constraint(
        equalTo: view.topAnchor
      ),
      clipView.bottomAnchor.constraint(
        equalTo: view.bottomAnchor
      ),
      clipView.leadingAnchor.constraint(
        equalTo: view.leadingAnchor
      ),
      clipView.trailingAnchor.constraint(
        equalTo: view.trailingAnchor
      ),
    ])
  }
  
  override
  func viewDidLoad()
  {
    super.viewDidLoad()
    
    colorView.backgroundColor = .windowBackgroundColor
    
    drawSource()
  }
  
  override
  func viewWillAppear()
  {}
  
  func drawSource()
  {
    let element: SourceKeyElementType? = withObservationTracking {
      source?.focused
    } onChange: {
      Task { @MainActor in self.drawSource() }
    } as SourceKeyElementType?
    
    guard let element else { return }
    
    Task { @MainActor in
      imageView.image = NSImage(named: element.name)
      imageView.frame = NSRect(
        origin: .zero,
        size: imageView.image?.size ?? .zero
      )
      imageView.needsDisplay = true
      source?.core?.log.debug("\(element.name)")
    }
  }
}


//**************************************************************************************
// MARK: - App Interface AppKit - Views

class ImageTableCellView:
  NSTableCellView
{
  var networkIndicator: NSProgressIndicator!
  
  override
  init(
    frame frameRect: NSRect
  ) {
    super.init(frame: frameRect)
    
    let imageView = NSImageView()
    self.imageView = imageView
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.alphaValue = 1.0
    imageView.tag = 1
    addSubview(imageView)
    
    let textField = NSTextField()
    self.textField = textField
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.cell?.truncatesLastVisibleLine = true
    textField.alignment = .natural
    textField.textColor = NSColor.white
    textField.drawsBackground = false
    textField.isBezeled = false
    textField.isEditable = false
    textField.isBordered = false
    textField.tag = 2
    addSubview(textField)
    
    self.networkIndicator = NSProgressIndicator()
    networkIndicator.translatesAutoresizingMaskIntoConstraints = false
    networkIndicator.minValue = 0
    networkIndicator.maxValue = 100
    networkIndicator.style = .bar
    networkIndicator.isIndeterminate = true
    networkIndicator.isHidden = true
    addSubview(networkIndicator)
    
    
    NSLayoutConstraint.activate([
      // imageView ----------------------------
      imageView.widthAnchor.constraint(
        equalToConstant: 120
      ),
      imageView.heightAnchor.constraint(
        equalTo: self.heightAnchor,
        constant: -18
      ),
      imageView.centerYAnchor.constraint(
        equalTo: self.centerYAnchor
      ),
      
      // textField ----------------------------
      textField.widthAnchor.constraint(
        equalTo: self.widthAnchor,
        constant: (-120 - 20)
      ),
      textField.heightAnchor.constraint(
        equalToConstant: 24
      ),
      textField.centerYAnchor.constraint(
        equalTo: self.centerYAnchor
      ),
      textField.rightAnchor.constraint(
        equalTo: self.rightAnchor,
        constant: -10
      ),
      
      // networkIndicator  --------------------
      networkIndicator.widthAnchor.constraint(
        equalTo: textField.widthAnchor,
        constant: -20
      ),
      networkIndicator.heightAnchor.constraint(
        equalToConstant: 32
      ),
      networkIndicator.centerYAnchor.constraint(
        equalTo: textField.centerYAnchor,
        constant: 22
      ),
      networkIndicator.rightAnchor.constraint(
        equalTo: textField.rightAnchor,
        constant: -10
      ),
    ])
  }
  
  required
  init?(
    coder: NSCoder
  ) {
    fatalError("init?(coder:) not implemented.")
  }
  
  func startNetworkActivity()
  {
    networkIndicator?.isHidden = false
    networkIndicator?.startAnimation(self)
  }
  
  func stopNetworkActivity()
  {
    networkIndicator?.stopAnimation(self)
    networkIndicator?.isHidden = true
  }
}


class CenteringClipView:
  NSClipView
{
  override
  func constrainBoundsRect(
    _ proposedBounds: NSRect
  ) -> NSRect
  {
    var constrainedBounds = super.constrainBoundsRect(proposedBounds)
    
    guard let documentView = documentView else {
      return constrainedBounds
    }
    
    if documentView.frame.width < proposedBounds.width {
      constrainedBounds.origin.x = floor(
        (proposedBounds.width - documentView.frame.width) / -2.0
      )
    }
    
    if documentView.frame.height < proposedBounds.height {
      constrainedBounds.origin.y = floor(
        (proposedBounds.height - documentView.frame.height) / -2.0
      )
    }
    
    return constrainedBounds
  }
}


final
class ColorView:
  NSView
{
  var backgroundColor: NSColor = .clear {
    didSet { self.needsDisplay = true }
  }
  
  override
  func draw(
    _ deltaRect: NSRect
  ) {
    super.draw(deltaRect)
    backgroundColor.setFill()
    deltaRect.fill()
  }
}

#endif


//**************************************************************************************
// MARK: - App Interface SwiftUI

struct SidebarView:
  View
{
  @Environment(ImageSource.self)
  var imageMap: ImageSource
  
  @Binding
  var selected: ImageType.ID?
  
  var body: some View {
    @Bindable
    var imageMap = imageMap
    
    List(imageMap.keyElements,
         selection: $selected)
    { color in
      HStack {
        NavigationLink(value: color) {
          Text(color.name)
        }
      }
    }
    .navigationDestination(for: ImageType.self)
    { color in
      ContentView(color)
    }
    .navigationTitle("Images")
  }
}


struct ContentView:
  View
{
  @Environment(ImageSource.self)
  private var imageMap: ImageSource
  
  var selectedImage: ImageType?
  
  var body: some View {
    @Bindable
    var imageMap = imageMap
    
    Text(selectedImage?.name ?? "Images")
      .navigationTitle(selectedImage?.name ?? "Images")
#if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
#endif
  }
  
  init() {}
  
  init(_ newColor: ImageType)
  {
    selectedImage = newColor
  }
}


struct DetailView:
  View
{
  var body: some View {
    Text("Detail")
  }
}


//**************************************************************************************
// MARK: - Log

struct LogRecord
{
  var type: LogType   = .dev(name: "Log")
  var lines: [String] = []
  var history: Bool   = false
  var logger: Logger  = .init()
  var name: String    { type.name }
  var label: String   { type.name }
}


enum LogType:
  Hashable
{
  case dev(name: String)
  case sys(name: String)
  case app(name: String)
  case com(name: String)
  
  var name: String {
    let bundleID: String = Bundle.main.bundleIdentifier ?? ""
    var label: String    = ""
    
    switch self {
    case .dev(let name):
      label = "Dev.\(name)"
    case .sys(let name):
      label = "Sys.\(name)"
    case .app(let name):
      label = "App.\(name)"
    case .com(let name):
      label = "Com.\(name)"
    }
    
    return "\(bundleID).\(label)"
  }
  
  func hash(
    into hasher: inout Hasher
  ) {
    hasher.combine(name)
  }
}


final
class Log
{
  static let debugLogType: LogType = .dev(name: "Debug")
  static let eventLogType: LogType = .app(name: "Event")
  static let statLogType: LogType  = .sys(name: "Stat")
  
  private var debugLog: LogRecord?
  private var eventLog: LogRecord?
  private var statLog: LogRecord?
  
  private var logs: [LogType: LogRecord]  = [:]
  
  private let queue: DispatchQueue = {
    let bundleID: String = Bundle.main.bundleIdentifier ?? ""
    return .init(label: "\(bundleID).dispatch.Log")
  }()
  
  init()
  {
    addType(Log.debugLogType)
    addType(Log.eventLogType)
    addType(Log.statLogType)
    
    debugLog = logs[Log.debugLogType]
    eventLog = logs[Log.eventLogType]
    statLog = logs[Log.statLogType]
  }
  
  func addType(
    _ type: LogType
  ) {
    queue.sync {
      var log: LogRecord = .init(type: type)
      log.history = false
      log.logger = Logger(subsystem: log.name,
                          category: log.label)
      logs[type] = log
    }
  }
  
  func out(
    _ type: LogType,
    _ message: String
  ) {
    queue.sync {
      guard var log = logs[type] else { return }
      if log.history {
        log.lines.append(message)
        logs[type] = log
      }
      log.logger.log("\(message)")
    }
  }
  
  @discardableResult
  func debug(
    _ message: String
  ) -> String
  {
    let output: String = message
    out(Log.debugLogType,
        output)
    return output
  }
  
  @discardableResult
  func event(
    _ message: String
  ) -> String
  {
    let output: String = message
    out(Log.eventLogType,
        output)
    return output
  }
  
  @discardableResult
  func stat(
    _ message: String
  ) -> String
  {
    let output: String = message
    out(Log.statLogType,
        output)
    return output
  }
}


//**************************************************************************************
// MARK: - Mon

final
class Mon
{
  
}


//**************************************************************************************


