//
//  ViewController.swift
//  promotionArea
//
//  Created by Alice Chang on 2022/1/19.
//

import UIKit

class AlbumsViewController: UIViewController, UICollectionViewDelegate {
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    enum Section: String, CaseIterable {
        case featuredAlbums = "Featured Albums"
        case sharedAlbums = "Shared Albums"
        case myAlbums = "My Albums"
    }
    
    var selectSection: [Section] = []
    var dataSource: UICollectionViewDiffableDataSource<Int, AlbumItem>! = nil
    var albumsCollectionView: UICollectionView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Your Albums"
        configureCollectionView()
        configureDataSource()
    }
}

extension AlbumsViewController {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(AlbumItemCell.self, forCellWithReuseIdentifier: AlbumItemCell.reuseIdentifer)
        collectionView.register(FeaturedAlbumItemCell.self, forCellWithReuseIdentifier: FeaturedAlbumItemCell.reuseIdentifer)
        collectionView.register(SharedAlbumItemCell.self, forCellWithReuseIdentifier: SharedAlbumItemCell.reuseIdentifer)
        collectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: AlbumsViewController.sectionHeaderElementKind,
            withReuseIdentifier: HeaderView.reuseIdentifier)
        albumsCollectionView = collectionView
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
        <Int, AlbumItem>(collectionView: albumsCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, albumItem: AlbumItem) -> UICollectionViewCell? in
            
            let sectionType = self.selectSection[indexPath.section]
            switch sectionType {
            case .featuredAlbums:
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: FeaturedAlbumItemCell.reuseIdentifer,
                        for: indexPath) as? FeaturedAlbumItemCell else { fatalError("Could not create new cell") }
                cell.featuredPhotoURL = albumItem.imageItems[0].thumbnailURL
                cell.title = albumItem.albumTitle
                cell.totalNumberOfImages = albumItem.imageItems.count
                return cell
                
            case .sharedAlbums:
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: SharedAlbumItemCell.reuseIdentifer,
                        for: indexPath) as? SharedAlbumItemCell else { fatalError("Could not create new cell") }
                cell.featuredPhotoURL = albumItem.imageItems[0].thumbnailURL
                cell.title = albumItem.albumTitle
                return cell
                
            case .myAlbums:
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: AlbumItemCell.reuseIdentifer,
                        for: indexPath) as? AlbumItemCell else { fatalError("Could not create new cell") }
                cell.featuredPhotoURL = albumItem.imageItems[0].thumbnailURL
                cell.title = albumItem.albumTitle
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (
            collectionView: UICollectionView,
            kind: String,
            indexPath: IndexPath) -> UICollectionReusableView? in
            
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: HeaderView.reuseIdentifier,
                    for: indexPath) as? HeaderView else { fatalError("Cannot create header view") }
            
            supplementaryView.label.text = self.selectSection[indexPath.section].rawValue
            return supplementaryView
        }
        
        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
                                                            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let isWideView = layoutEnvironment.container.effectiveContentSize.width > 500
            
            let sectionLayoutKind = self.selectSection[sectionIndex]
            switch (sectionLayoutKind) {
            case .featuredAlbums: return self.generateFeaturedAlbumsLayout(isWide: isWideView)
            case .sharedAlbums: return self.generateSharedlbumsLayout()
            case .myAlbums: return self.generateMyAlbumsLayout(isWide: isWideView)
            }
        }
        return layout
    }
    
    func generateFeaturedAlbumsLayout(isWide: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(2/3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Show one item plus peek on narrow screens, two items plus peek on wider screens
        let groupFractionalWidth = isWide ? 0.475 : 0.95
        let groupFractionalHeight: Float = isWide ? 1/3 : 2/3
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(CGFloat(groupFractionalWidth)),
            heightDimension: .fractionalWidth(CGFloat(groupFractionalHeight)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: AlbumsViewController.sectionHeaderElementKind, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    func generateSharedlbumsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(140),
            heightDimension: .absolute(186))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: AlbumsViewController.sectionHeaderElementKind,
            alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    func generateMyAlbumsLayout(isWide: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupHeight = NSCollectionLayoutDimension.fractionalWidth(isWide ? 0.25 : 0.5)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: isWide ? 4 : 2)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: AlbumsViewController.sectionHeaderElementKind,
            alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Int, AlbumItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AlbumItem>()
        let allAlbumsInBaseDirectory = albumsInBaseDirectory() + albumsInBaseDirectory() + albumsInBaseDirectory() + albumsInBaseDirectory()
        let promotionAreas = [promotionArea(type: "category", name: "game", index:2),
                              promotionArea(type: "banner", name: "music", index:8),
                              promotionArea(type: "banner", name: "music", index:12),
                              promotionArea(type: "category", name: "music", index:14),]
        var promotionAreasIndex: [Int] = []
        promotionAreas.forEach { promotionAreasIndex.append($0.index)}
        var separateAllAlbums:[[AlbumItem]] = []
        var tempAlbumItems:[AlbumItem] = []
        
        if promotionAreas.count == 0 {
            selectSection.append(Section.myAlbums)
            snapshot.appendSections([0])
            snapshot.appendItems(allAlbumsInBaseDirectory)
        } else {
            setUpSeparateAllAlbums()
            func setUpSeparateAllAlbums() {
                for (index, album) in allAlbumsInBaseDirectory.enumerated() {
                    if let first = promotionAreasIndex.first, index < first {
                        tempAlbumItems.append(album)
                    } else if let first = promotionAreasIndex.first, index == first {
                        if !tempAlbumItems.isEmpty {
                            separateAllAlbums.append(tempAlbumItems)
                        }
                        tempAlbumItems = []
                        promotionAreasIndex.removeFirst()
                        tempAlbumItems.append(album)
                    } else if promotionAreasIndex.count == 0 && allAlbumsInBaseDirectory.count == index + 1 {
                        separateAllAlbums.append(tempAlbumItems)
                    } else if promotionAreasIndex.count == 0 {
                        tempAlbumItems.append(album)
                    }
                }
            }
            
            
            for (index, _) in separateAllAlbums.enumerated() {
                if promotionAreas.first?.index == 0 {
                    addCategoryAndBannerSection(index: index)
                    addMyAlbums(index: index)
                } else {
                    addMyAlbums(index: index)
                    addCategoryAndBannerSection(index: index)
                }
            }
            
            func addCategoryAndBannerSection(index: Int) {
                if index < promotionAreas.count {
                    if promotionAreas[index].type == "category" {
                        selectSection.append(Section.sharedAlbums)
                        snapshot.appendSections([index+100])
                        snapshot.appendItems(albumsInBaseDirectory())
                    } else {
                        selectSection.append(Section.featuredAlbums)
                        snapshot.appendSections([index+200])
                        snapshot.appendItems(albumsInBaseDirectory())
                    }
                }
            }
            
            func addMyAlbums(index: Int) {
                selectSection.append(Section.myAlbums)
                snapshot.appendSections([index+10])
                snapshot.appendItems(separateAllAlbums[index])
            }
        }
        
        return snapshot
    }
    
    func albumsInBaseDirectory() -> [AlbumItem] {
        guard let baseURL = Bundle.main.url(forResource: "PhotoData", withExtension: "bundle") else { return [] }
        
        let fileManager = FileManager.default
        do {
            return try fileManager.albumsAtURL(baseURL)
        } catch {
            print(error)
            return []
        }
    }
}

//  extension AlbumsViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//      guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
//      let albumDetailVC = AlbumDetailViewController(withPhotosFromDirectory: item.albumURL)
//      navigationController?.pushViewController(albumDetailVC, animated: true)
//    }
//  }


extension FileManager {
    func albumsAtURL(_ fileURL: URL) throws -> [AlbumItem] {
        let albumsArray = try self.contentsOfDirectory(
            at: fileURL,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: .skipsHiddenFiles
        ).filter { (url) -> Bool in
            do {
                let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
                return resourceValues.isDirectory! && url.lastPathComponent.first != "_"
            } catch { return false }
        }.sorted(by: { (urlA, urlB) -> Bool in
            do {
                let nameA = try urlA.resourceValues(forKeys:[.nameKey]).name
                let nameB = try urlB.resourceValues(forKeys: [.nameKey]).name
                return nameA! < nameB!
            } catch { return true }
        })
        
        return albumsArray.map { fileURL -> AlbumItem in
            do {
                let detailItems = try self.albumDetailItemsAtURL(fileURL)
                return AlbumItem(albumURL: fileURL, imageItems: detailItems)
            } catch {
                return AlbumItem(albumURL: fileURL)
            }
        }
    }
    
    func albumDetailItemsAtURL(_ fileURL: URL) throws -> [AlbumDetailItem] {
        guard let components = URLComponents(url: fileURL, resolvingAgainstBaseURL: false) else { return [] }
        
        let photosArray = try self.contentsOfDirectory(
            at: fileURL,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: .skipsHiddenFiles
        ).filter { (url) -> Bool in
            do {
                let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
                return !resourceValues.isDirectory!
            } catch { return false }
        }.sorted(by: { (urlA, urlB) -> Bool in
            do {
                let nameA = try urlA.resourceValues(forKeys:[.nameKey]).name
                let nameB = try urlB.resourceValues(forKeys: [.nameKey]).name
                return nameA! < nameB!
            } catch { return true }
        })
        
        return photosArray.map { fileURL in AlbumDetailItem(
            photoURL: fileURL,
            thumbnailURL: URL(fileURLWithPath: "\(components.path)thumbs/\(fileURL.lastPathComponent)")
        )}
    }
}

struct promotionArea {
    let type: String
    let name: String
    let index: Int
}
