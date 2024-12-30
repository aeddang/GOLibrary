//
//  AesUtil.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/21.
//

import Foundation
import CryptoKit
import CommonCrypto


public class AESUtil {
    static nonisolated(unsafe) private var SECRET_KEY = ""
    public static func setup(_ key: String){
        Self.SECRET_KEY = key
    }
    public static func encrypt(string: String) -> Data? {
        return AES(key: SECRET_KEY)?.encrypt(string: string)
    }
    public static func decrypt(encoded: Data) -> String {
        let crypt = AES(key: SECRET_KEY)?.decrypt(data: encoded)
        return  crypt ?? ""
    }
    public static func decrypt(encoded: String) -> String {
        let datas =  Data(hexString: encoded)
        let crypt = AES(key: SECRET_KEY)?.decrypt(data: datas)
        return  crypt ?? ""
    }
        
    public struct AES {
        private let key: Data
        private let iv: Data

        init?(key: String) {
            guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256, let keyData = key.data(using: .utf8) else {
                DataLog.e("Error: Failed to set a key.", tag:"AES")
                return nil
            }
            self.key = keyData
            self.iv  = Data.init(bytes: Array(key.utf8), count: 16)
        }

        func encrypt(string: String) -> Data? {
            return crypt(data: string.data(using: .utf8), option: CCOperation(kCCEncrypt))
        }

        func decrypt(data: Data?) -> String? {
            guard let decryptedData = crypt(data: data, option: CCOperation(kCCDecrypt)) else { return nil }
            return String(bytes: decryptedData, encoding: .utf8)
        }

        func crypt(data: Data?, option: CCOperation) -> Data? {
            guard let data = data else { return nil }
        
            let cryptLength = data.count + key.count
            var cryptData   = Data(count: cryptLength)
        
            var bytesLength = Int(0)
        
            let status = cryptData.withUnsafeMutableBytes { cryptBytes in
                data.withUnsafeBytes { dataBytes in
                    iv.withUnsafeBytes { ivBytes in
                        key.withUnsafeBytes { keyBytes in
                        CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding), keyBytes.baseAddress, key.count, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                        }
                    }
                }
            }
        
            guard Int32(status) == Int32(kCCSuccess) else {
                DataLog.e("Error: Failed to crypt data. Status \(status)", tag:"AES")
                return nil
            }
        
            cryptData.removeSubrange(bytesLength..<cryptData.count)
            return cryptData
        }
    }
}
