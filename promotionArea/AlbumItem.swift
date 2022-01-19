//
//  AlbumItem.swift
//  promotionArea
//
//  Created by Alice Chang on 2022/1/19.
//

import Foundation

class AlbumItem: Hashable {
  let albumURL: URL
  let albumTitle: String
  let imageItems: [AlbumDetailItem]

  init(albumURL: URL, imageItems: [AlbumDetailItem] = []) {
    self.albumURL = albumURL
    self.albumTitle = albumURL.lastPathComponent
    self.imageItems = imageItems
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }

  static func == (lhs: AlbumItem, rhs: AlbumItem) -> Bool {
    return lhs.identifier == rhs.identifier
  }

  private let identifier = UUID()
}

class AlbumDetailItem: Hashable {
  let photoURL: URL
  let thumbnailURL: URL
  let subitems: [AlbumDetailItem]

  init(photoURL: URL, thumbnailURL: URL, subitems: [AlbumDetailItem] = []) {
    self.photoURL = photoURL
    self.thumbnailURL = thumbnailURL
    self.subitems = subitems
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }

  static func == (lhs: AlbumDetailItem, rhs: AlbumDetailItem) -> Bool {
    return lhs.identifier == rhs.identifier
  }

  private let identifier = UUID()
}

