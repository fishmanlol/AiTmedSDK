//
//  Encryption.swift
//  Encryption
//
//  Created by Yi Tong on 10/25/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import Sodium
import Clibsodium

struct Encryption {
    private let sodium = Sodium()
    
    ///Generate asymmetric key pair
    func generateAKey() -> KeyPair? {
        return KeyPair()
    }
    
    ///Generate symmetric key pair
    func generateSKey() -> Key {
        return Key(sodium.secretBox.key())
    }
    
    ///Generate encrypted symmetric key from secrect key and password
    func generateESKey(from sk: Key, using passwd: String) -> Key? {
        guard let hashed = SHA256(passwd.bytes), let esk = sKeyEncrypt(secretKey: Key(hashed), data: sk.toBytes()) else { return nil }
        return Key(esk)
    }
    
    ///Generated secrect key from encrypted symmetric key and password
    func generateSk(from esk: Key, using passwd: String) -> Key? {
        guard let hashed = SHA256(passwd.bytes), let sk = sKeyDecrypt(secretKey: Key(hashed), data: esk.toBytes()) else { return nil }
        
        return Key(sk)
    }
    
    /**
     Generate a pair of BESAK and EESAK
     
     BESAK: begin vertex encrypted sysmmetric access key
     EESAK: end vertex encrypted sysmmetric access key
     
     - Parameter recvPublicKey: public key of recipient
     - Parameter sendSecretKey: secrect key of sender
     
     - returns: (BESAK, EESAK)
    */
    func generateXESAK(sendSecretKey: Key, recvPublicKey: Key) -> (Key?, Key?) {
        let tmpKey = generateSKey().toBytes()
        let halfKey = Array(tmpKey[0...15])
        let sendPublicKey = generatePk(from: sendSecretKey)
        guard let besak = aKeyEncrypt(recvPublicKey: sendPublicKey, sendSecretKey: sendSecretKey, data: halfKey),
                let eesak = aKeyEncrypt(recvPublicKey: recvPublicKey, sendSecretKey: sendSecretKey, data: halfKey) else { return (nil, nil) }
        
        return (Key(besak), Key(eesak))
    }
    
    ///Generate SAK: sysmmetric access key which can decrypt and encrypt documents
    func generateSAK(xesak: Key, sendPublicKey: Key, recvSecretKey: Key) -> Key? {
        guard let halfkey = aKeyDecrypt(sendPublicKey: sendPublicKey, recvSecretKey: recvSecretKey, data: xesak.toBytes()), let hashed = SHA256(halfkey) else { return nil }
        
        return Key(hashed)
    }
    
    ///Generate public key from secrect key
    func generatePk(from secretKey: Key) -> Key {
        let secretKeyBytes = secretKey.toBytes()
        var generatedPublickeyBytes = Bytes(repeating: 0, count: 32)
        let _ = crypto_scalarmult_base(&generatedPublickeyBytes, secretKeyBytes)
        
        return Key(generatedPublickeyBytes)
    }
    
    ///Check if the asymmetric keypair is valid
    func aKeyCheck(publicKey: Key, secretKey: Key) -> Bool {
        let pk = generatePk(from: secretKey)
        return isBytesEqual(pk.toBytes(), publicKey.toBytes())
    }
    
    ///Use recipent public key to encrypt data
    func aKeyEncrypt(recvPublicKey: Key, sendSecretKey: Key, data: Bytes) -> Bytes? {
        guard let before = sodium.box.beforenm(recipientPublicKey: recvPublicKey.toBytes(), senderSecretKey: sendSecretKey.toBytes()) else { return nil }
        return sodium.box.seal(message: data, beforenm: before)
    }
    
    /**
     Use recipent public key to encrypt data in string
     
     - Parameter recvPublicKey: public key of recipient
     - Parameter sendSecretKey: secrect key of sender
     - Parameter data: raw data in utf8 format
     
     - Returns: encrypted data in base64 format
     */
    func aKeyEncrypt(recvPublicKey: Key, sendSecretKey: Key, data: String) -> String? {
        guard let encrypted = aKeyEncrypt(recvPublicKey: recvPublicKey, sendSecretKey: sendSecretKey, data: utf82Bin(data)), let encryptedBase64 = bin2Utf8(encrypted) else { return nil }
        return encryptedBase64
    }
    
    ///Use recipient's secrect key and sender's public key to decrypt data which send to this recipient
    func aKeyDecrypt(sendPublicKey: Key, recvSecretKey: Key, data: Bytes) -> Bytes? {
        return sodium.box.open(nonceAndAuthenticatedCipherText: data, senderPublicKey: sendPublicKey.toBytes(), recipientSecretKey: recvSecretKey.toBytes())
    }
    
    /**
     Use recipient's secrect key and sender's public key to decrypt data which send to this recipient in string
     
     - Parameter sendPublicKey: public key of sender
     - Parameter recvSecretKey: secrect key of recipient
     - Parameter data: encrypted data in base64 format
     
     - Returns: decrypted data in utf8 format
     */
    func aKeyDecrypt(sendPublicKey: Key, recvSecretKey: Key, data: String) -> String? {
        guard let dataBytes = base642Bin(data),
            let decrypted = sodium.box.open(nonceAndAuthenticatedCipherText: dataBytes, senderPublicKey: sendPublicKey.toBytes(), recipientSecretKey: recvSecretKey.toBytes()),
            let utf8 = bin2Utf8(decrypted)
            else { return nil }
        return utf8
    }
    
    ///Use the shared secret key to encrypt data
    func sKeyEncrypt(secretKey: Key, data: Bytes) -> Bytes? {
        return sodium.secretBox.seal(message: data, secretKey: secretKey.toBytes())
    }
    
    ///Use the shared secret key to decrypt data
    func sKeyDecrypt(secretKey: Key, data: Bytes) -> Bytes? {
        return sodium.secretBox.open(nonceAndAuthenticatedCipherText: data, secretKey: secretKey.toBytes())
    }
    
    ///Compare two bytes whether equla
    func isBytesEqual(_ bytes1: Bytes, _ bytes2: Bytes) -> Bool {
        return bytes1.elementsEqual(bytes2)
    }
    
    ///Convert binary to base64
    func bin2Base64(_ bin: Bytes) -> String? {
        return Data(bin).base64EncodedString()
    }
    
    ///Convert base64 to binary
    func base642Bin(_ base64: String) -> Bytes? {
        if let data = Data(base64Encoded: base64) {
            return [UInt8](data)
        } else {
            return nil
        }
    }
    
    ///Convert utf8 to binary
    func utf82Bin(_ utf8: String) -> Bytes {
        return utf8.bytes
    }
    
    ///Convert binary to utf8
    func bin2Utf8(_ bin: Bytes) -> String? {
        return String(bytes: bin, encoding: .utf8)
    }
    
    ///Hash password to 32 bytes
    func SHA256(_ passwd: Bytes) -> Bytes? {
        let salt = Bytes(repeating: 0, count: sodium.pwHash.SaltBytes)
        return sodium.pwHash.hash(outputLength: 32, passwd: passwd, salt: salt, opsLimit: sodium.pwHash.OpsLimitModerate, memLimit: sodium.pwHash.MemLimitModerate, alg: .Default)
    }
}

//Mark: - struct Key
struct Key {
    private let raw:Bytes
    private let e = Encryption()
    
    init(_ raw: Bytes) {
        self.raw = raw
    }
    
    init?(_ base64: String) {
        guard let bin = e.base642Bin(base64) else { return nil }
        self.raw = bin
    }
    
    init(_ data: Data) {
        self.raw = Bytes(data)
    }
    
    func toBase64() -> String? {
        return e.bin2Base64(raw)
    }
    
    func toBytes() -> Bytes {
        return raw
    }
    
    func toData() -> Data {
        return Data(raw)
    }
}

//Mark: - struct KeyPair
struct KeyPair {
    var publicKey: Key
    var secretKey: Key
    
    init(publicKey: Bytes, secretKey: Bytes) {
        self.publicKey = Key(publicKey)
        self.secretKey = Key(secretKey)
    }
    
    init(publicKey: Key, secretKey: Key) {
        self.publicKey = publicKey
        self.secretKey = secretKey
    }
    
    init?() {
        guard let pair = Sodium().box.keyPair() else { return nil }
        self.init(publicKey: pair.publicKey, secretKey: pair.secretKey)
    }
    
    init?(seed: Bytes) {
        guard let pair = Sodium().box.keyPair(seed: seed) else { return nil }
        self.init(publicKey: pair.publicKey, secretKey: pair.secretKey)
    }
}

extension Key: CustomStringConvertible {
    var description: String {
        return self.toBase64() ?? ""
    }
}

extension Key: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(raw)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let bytes = try container.decode(Bytes.self)
        self.raw = bytes
    }
}
