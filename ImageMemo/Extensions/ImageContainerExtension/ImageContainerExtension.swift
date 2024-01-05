//
//  ImageContainerExtension.swift
//  ImageContainerExtension
//
//  Created by Ven Jandhyala on 1/3/24.
//


// TODO: Experiment with secure Container for handling untrusted Image Files.


import Foundation
import ExtensionFoundation


struct ImageContainerConfiguration<E: ImageContainer>:
  AppExtensionConfiguration
{
  let appExtension: E
    
  init(
    _ appExtension: E
  ) {
    self.appExtension = appExtension
  }
    
  func accept(
    connection: NSXPCConnection
  ) -> Bool {
    // TODO: Configure the XPC connection and return true
    return false
  }
}


protocol ImageContainer: AppExtension {}


extension ImageContainer
{
  var configuration: ImageContainerConfiguration<some ImageContainer> {
    return ImageContainerConfiguration(self)
  }
}


@main
class ImageContainerExtension: 
  ImageContainer
{
  required
  init() {}
}
