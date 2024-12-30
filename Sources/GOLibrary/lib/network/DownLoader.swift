//
//  DownLoader.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/08.
//

import Foundation

//@MainActor
public class DownLoader:ObservableObject, PageProtocol{
    public enum Event {
       case complete(URL), error(err:Error), start(Double)
    }
    public enum Status{
       case ready, progress, pause, error, complete
    }
    
    let id:String = UUID().uuidString
    @Published public private(set) var event: Event? = nil {didSet{ if event != nil { event = nil} }}
    @Published public private(set) var status: Status = .ready
    @Published public private(set) var progress:Double = 0
    private(set) var session:URLSessionDownloadTask? = nil
    private(set) var progressObserver:NSKeyValueObservation? = nil
    
    private var fileName:String = ""
    private var fileExtension = ""
    private var path = ""
    
    public init(fileName:String = "Temporary file", fileExtension: String = "mp4", path:String? = nil) {
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.path = path ?? NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    }
    
    private(set) var resumeData:Data? = nil
    public func reset(){
        self.removeAllFile()
        self.close()
        self.status = .ready
    }
    
    public func close(){
        self.progressObserver = nil
        self.session?.cancel()
        self.session = nil
        
    }
    @discardableResult
    public func start(path:String, fileName:String? = nil, qos:QualityOfService = .background)->Bool{
        if let name = fileName {
            self.fileName = name
        }
        guard let url = URL(string:path) else {
            DataLog.e(self.fileName + " targetUrl error", tag: self.tag)
            return false
        }
        
        self.close()
        if getFile() != nil {
            DataLog.d(self.fileName + " is exist file", tag: self.tag)
            return false
        }
        let path = self.getFileFullPath()
        var task:URLSessionDownloadTask? = nil
        if let resumeData = self.resumeData {
            DataLog.d(self.fileName + " continue resumeData", tag: self.tag)
            task = URLSession.shared.downloadTask(withResumeData: resumeData){url,res,error in
                self.onDownloadComplete(url: url, res: res, err: error, savedPath: path)
            }
        } else {
            DataLog.d(self.fileName + " create newFile", tag: self.tag)
            task = URLSession.shared.downloadTask(with: url){url,res,error in
                self.onDownloadComplete(url: url, res: res, err: error, savedPath: path)
            }
        }
        
        self.progressObserver = task?.progress.observe(\.fractionCompleted) { progress, _ in
            //DataLog.d(progress.fractionCompleted.description, tag: self.tag)
            DispatchQueue.main.async {
                self.progress = progress.fractionCompleted
            }
        }
        self.session = task
        self.status = .pause
        self.resume()
        return true
    }
    
    @discardableResult
    func resume()->Bool{
        guard let session = self.session else {return false}
        if self.status != .pause {return false}
        session.resume()
        self.status = .progress
        return true
    }
    
    @discardableResult
    func pause()->Bool{
        guard let session = self.session else {return false}
        if self.status != .progress {return false}
        session.suspend()
        self.status = .pause
        return true
    }
    
    func stop(){
        self.session?.cancel{ resumeDataOrNil in
            guard let resumeData = resumeDataOrNil else {return}
            self.resumeData = resumeData
        }
        self.status = .ready
        self.close()
    }
    
    private func onDownloadComplete(url:URL?, res:URLResponse?, err:Error?, savedPath:URL){
        guard let fileURL = url else { return }
        do {
            try FileManager.default.moveItem(at: fileURL, to: savedPath)
            self.onCompleted(savedPath: savedPath)
        } catch {
            self.onError(err: error)
        }
    }
    private func onError(err:Error){
        DataLog.e(err.localizedDescription, tag: self.tag)
        self.removeAllFile()
        self.event = .error(err: err)
        self.status = .error
    
        self.close()
    }
    private func onCompleted(savedPath:URL){
        DataLog.d("completed " + savedPath.absoluteString, tag: self.tag)
        self.event = .complete(savedPath)
        self.status = .complete
        self.close()
    }
    
    
    func removeAllFile(){
        self.resumeData = nil
        removeFile()
        
    }
    func removeFile(){
        let filePath = self.getFileFullPath().path
        if FileManager.default.fileExists(atPath: filePath) {
            do {
               try FileManager.default.removeItem(atPath: filePath )
            }
            catch let error {
                DataLog.e(error.localizedDescription, tag: self.tag)
            }
        }
    }

    func getFile() -> Data?{
        let filePath = self.getFileFullPath().path
        if FileManager.default.fileExists(atPath: filePath ) {
            return FileManager.default.contents(atPath: filePath)
        } else {
            return nil
        }
    }
    func getFileFullPath() -> URL {
        return URL(fileURLWithPath: self.path).appendingPathComponent(fileName).appendingPathExtension(self.fileExtension)
    }
}
