//
//  PhotoCollector.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/27.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreTransferable
import Combine

@MainActor
public class PhotoModel: ObservableObject, PageProtocol {

    private var fixedWidth:CGFloat? = nil
    init(fixedWidth:CGFloat? = nil){
        self.fixedWidth = fixedWidth
    }
    
    public enum ImageState {
        case empty
        case loading(Progress)
        case success(Image, png:Data?)
        case failure(Error)
    }
    public enum TransferError: Error {
        case importFailed
    }
    private(set) var asset: PHAsset? = nil
    @Published public private(set) var imageState: ImageState = .empty
    @Published public var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let id = imageSelection.itemIdentifier ?? ""
                let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
                self.asset = assetResults.firstObject
               
                loadTransferable(from: imageSelection){ progress in
                    self.imageState = .loading(progress)
                }
            } else {
                imageState = .empty
            }
        }
    }
    public struct PhotoImage: Transferable {
        let image: Image
        let data: Data?
        public static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
            #if canImport(AppKit)
                guard let nsImage = NSImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(nsImage: nsImage)
                return PhotoImage(image: image)
            #elseif canImport(UIKit)
                guard let uiImage = UIImage(data: data)?.normalized().resizeMaintainAspectRatio(width: 320) else {
                    throw TransferError.importFailed
                }
                
                let image = Image(uiImage: uiImage)
                return PhotoImage(image: image, data: uiImage.pngData())
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem, complete:@escaping (Progress) -> Void) {
        Task {
            let pro = imageSelection.loadTransferable(type: PhotoImage.self) { result in
                switch result {
                case .success(let photo?):
                    let img = photo.image
                    let data = photo.data
                    DispatchQueue.main.async{
                        self.imageState = .success(img, png: data)
                    }
                case .success(nil):
                    DispatchQueue.main.async{
                        self.imageState = .failure(TransferError.importFailed)
                    }
                case .failure(let error):
                    DispatchQueue.main.async{
                        self.imageState = .failure(error)
                    }
                }
            }
            complete(pro)
        }
       
    }
}

@MainActor
open class PhotoCollector : ObservableObject , PageProtocol{
    public enum Event{
        case updateAuthorization(PHAuthorizationStatus)
        case completed([PhotoModel])
    }
    private(set) var total:Int = 0
    @Published public private(set) var progress:Float = 0
    @Published public private(set) var event:Event? = nil
        {didSet{ if event != nil { event = nil} }}
    
    private var anyCancellable = Set<AnyCancellable>()
    @Published public fileprivate(set) var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            if imageSelections.isEmpty {return}
            self.clear()
            let max = imageSelections.count
            self.total = max
            var count = 0
            var collect:[PhotoModel] = []
            func com(_ md:PhotoModel){
                collect.append(md)
                count += 1
                self.progress = Float(count) / Float(max)
                if count == max {
                    self.completed(collect: collect)
                }
            }
            
            imageSelections.forEach{selection in
                let md = PhotoModel()
                md.$imageState.sink( receiveValue: { state in
                    switch state {
                    case .loading, .empty : break
                    default : 
                        DispatchQueue.main.async {
                            com(md)
                        }
                        
                    }
                }).store(in: &anyCancellable)
                DispatchQueue.main.async {
                    md.imageSelection = selection
                }
            }
            imageSelections = []
        }
    }
    private func clear(){
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
    }
    
    private func completed(collect:[PhotoModel]){
        self.clear()
        self.event = .completed(collect)
    }
    
    @discardableResult
    public func photoLibraryAvailabilityCheck() -> PHAuthorizationStatus
    {
        let status = PHPhotoLibrary.authorizationStatus()
        if status != PHAuthorizationStatus.authorized
        {
            PHPhotoLibrary.requestAuthorization( self.requestAuthorizationHandler )
        }
        return status
    }
    private func requestAuthorizationHandler(status: PHAuthorizationStatus)
    {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized
        {
            self.alertToEncouragePhotoLibraryAccess()
        }
        self.event = .updateAuthorization(status)
    }
    open func alertToEncouragePhotoLibraryAccess()
    {
        /* override to do
        let cameraUnavailableAlertController = UIAlertController (
            title: "String.alert.requestAccessPhoto",
            message: "String.alert.requestAccessPhotoText",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: String.app.setting, style: .destructive) { (_) -> Void in
            AppUtil.goAppSettings()
        }
        let cancelAction = UIAlertAction(title: String.app.confirm, style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(settingsAction)
        cameraUnavailableAlertController .addAction(cancelAction)
        let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        DispatchQueue.main.async {
            window?.windows.first?.rootViewController?.present(cameraUnavailableAlertController , animated: true, completion: {
                let status = PHPhotoLibrary.authorizationStatus()
                self.event = .updateAuthorization(status)
            })
        }
        */
    }
}
