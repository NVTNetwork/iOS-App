//
//  EthereumTransaction.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import BigInt
import Foundation

public struct EthereumTransaction: CustomStringConvertible {
    public var nonce: BigUInt
    public var gasPrice: BigUInt = 0
    public var gasLimit: BigUInt = 0
    public var to: Address
    public var value: BigUInt
    public var data: Data
    public var v: BigUInt = 1
    public var r: BigUInt = 0
    public var s: BigUInt = 0
    var chainID: NetworkId?

    public var inferedChainID: NetworkId? {
        if r == 0 && s == 0 {
            return NetworkId(v)
        } else if v == 27 || v == 28 {
            return nil
        } else {
            return NetworkId((v - 1) / 2 - 17)
        }
    }

    public var intrinsicChainID: BigUInt? {
        return chainID?.rawValue
    }

    public mutating func UNSAFE_setChainID(_ chainID: NetworkId?) {
        self.chainID = chainID
    }

    public var hash: Data? {
        var encoded: Data
        let inferedChainID = self.inferedChainID
        if inferedChainID != nil {
            guard let enc = self.encode(forSignature: false, chainId: inferedChainID) else { return nil }
            encoded = enc
        } else {
            guard let enc = self.encode(forSignature: false, chainId: self.chainID) else { return nil }
            encoded = enc
        }
        let hash = encoded.sha3(.keccak256)
        return hash
    }

    public init(gasPrice: BigUInt, gasLimit: BigUInt, to: Address, value: BigUInt, data: Data) {
        nonce = BigUInt(0)
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.value = value
        self.data = data
        self.to = to
    }

    public init(to: Address, data: Data, options: Web3Options) {
        let merged = Web3Options.default.merge(with: options)
        nonce = BigUInt(0)
        gasLimit = merged.gasLimit!
        gasPrice = merged.gasPrice!
        value = merged.value!
        self.to = to
        self.data = data
    }

    public init(nonce: BigUInt, gasPrice: BigUInt, gasLimit: BigUInt, to: Address, value: BigUInt, data: Data, v: BigUInt, r: BigUInt, s: BigUInt) {
        self.nonce = nonce
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.to = to
        self.value = value
        self.data = data
        self.v = v
        self.r = r
        self.s = s
    }

    public func mergedWithOptions(_ options: Web3Options) -> EthereumTransaction {
        var tx = self
        if options.gasPrice != nil {
            tx.gasPrice = options.gasPrice!
        }
        if options.gasLimit != nil {
            tx.gasLimit = options.gasLimit!
        }
        if options.value != nil {
            tx.value = options.value!
        }
        if options.to != nil {
            tx.to = options.to!
        }
        return tx
    }

    public var description: String {
        return """
Transaction
Nonce: \(nonce)
Gas price: \(gasPrice)
Gas limit: \(gasLimit)
To: \(to.address)
Value: \(value)
Data: \(data.hex)
v: \(v)
r: \(r)
s: \(s)
Intrinsic chainID: \(String(describing: chainID))
Infered chainID: \(String(describing: inferedChainID))
sender: \(String(describing: sender?.address))
hash: \(String(describing: hash))
"""
    }

    public var sender: Address? {
        guard let publicKey = self.recoverPublicKey() else { return nil }
        return try? Web3Utils.publicToAddress(publicKey)
    }

    public func recoverPublicKey() -> Data? {
        // !(r == 0 && s == 0)
        guard r != 0 || s != 0 else { return nil }
        var normalizedV: BigUInt = 0
        let inferedChainID = self.inferedChainID
        if let chainId = chainID?.rawValue, chainId != 0 {
            normalizedV = v - 35 - chainId - chainId
        } else if let inferedChainID = inferedChainID?.rawValue {
            normalizedV = v - 35 - inferedChainID - inferedChainID
        } else {
            normalizedV = v - 27
        }
        guard let vData = normalizedV.serialize().setLengthLeft(1) else { return nil }
        guard let rData = r.serialize().setLengthLeft(32) else { return nil }
        guard let sData = s.serialize().setLengthLeft(32) else { return nil }
        guard let signatureData = try? SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { return nil }
        var hash: Data
        if let inferedChainID = inferedChainID {
            guard let h = self.hashForSignature(chainID: inferedChainID) else { return nil }
            hash = h
        } else {
            guard let h = self.hashForSignature(chainID: self.chainID) else { return nil }
            hash = h
        }
        guard let publicKey = try? SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else { return nil }
        return publicKey
    }

    public var txhash: String? {
        guard sender != nil else { return nil }
        guard let hash = self.hash else { return nil }
        let txid = hash.toHexString().withHex.lowercased()
        return txid
    }

    public var txid: String? {
        return txhash
    }

    public func encode(forSignature: Bool = false, chainId: NetworkId? = nil) -> Data? {
        if forSignature {
            if let chainId = chainId {
                let fields = [nonce, gasPrice, gasLimit, to.addressData, value, data, chainId.rawValue, BigUInt(0), BigUInt(0)] as [AnyObject]
                return RLP.encode(fields)
            } else if let chainId = self.chainID {
                let fields = [nonce, gasPrice, gasLimit, to.addressData, value, data, chainId.rawValue, BigUInt(0), BigUInt(0)] as [AnyObject]
                return RLP.encode(fields)
            } else {
                let fields = [nonce, gasPrice, gasLimit, to.addressData, value, data] as [AnyObject]
                return RLP.encode(fields)
            }
        } else {
            let fields = [nonce, gasPrice, gasLimit, to.addressData, value, data, v, r, s] as [AnyObject]
            return RLP.encode(fields)
        }
    }

    public func encodeAsDictionary(from: Address? = nil) -> TransactionParameters? {
        var toString: String?
        switch to.type {
        case .normal:
            toString = to.address.lowercased()
        case .contractDeployment:
            break
        }
        var params = TransactionParameters(from: from?.address.lowercased(),
                                           to: toString)
        let gasEncoding = gasLimit.abiEncode(bits: 256)
        params.gas = gasEncoding?.toHexString().withHex.stripLeadingZeroes()
        let gasPriceEncoding = gasPrice.abiEncode(bits: 256)
        params.gasPrice = gasPriceEncoding?.toHexString().withHex.stripLeadingZeroes()
        let valueEncoding = value.abiEncode(bits: 256)
        params.value = valueEncoding?.toHexString().withHex.stripLeadingZeroes()
        if data != Data() {
            params.data = data.toHexString().withHex
        } else {
            params.data = "0x"
        }
        return params
    }

    public func hashForSignature(chainID: NetworkId? = nil) -> Data? {
        guard let encoded = self.encode(forSignature: true, chainId: chainID) else { return nil }
        let hash = encoded.sha3(.keccak256)
        return hash
    }

    init(_ json: [String: Any]) throws {
        let options = try Web3Options(json)
        let to = try json.at("to").address()
        let data: Data
        if let value = try? json.at("data") {
            data = try value.data()
        } else if let value = try? json.at("input") {
            data = try value.data()
        } else {
            throw json.notFoundError
        }
        self.init(to: to, data: data, options: options)
        nonce = try json.at("nonce").uint256()
        v = try json.at("v").uint256()
        r = try json.at("r").uint256()
        s = try json.at("s").uint256()
        value = try json.at("value").uint256()
        if let inferedChainID = inferedChainID, v >= 37 {
            chainID = inferedChainID
        }
    }
    
    /**
     Initializes EthereumTransaction from RLP encoded data
     - parameter raw: RLP encoded data
     - returns: EthereumTransaction if data wasn't not corrupted
     */
    public static func fromRaw(_ raw: Data) -> EthereumTransaction? {
        guard let totalItem = RLP.decode(raw) else { return nil }
        guard let rlpItem = totalItem[0] else { return nil }
        switch rlpItem.count {
        case 9?:
            guard let nonceData = rlpItem[0]!.data else { return nil }
            let nonce = BigUInt(nonceData)
            guard let gasPriceData = rlpItem[1]!.data else { return nil }
            let gasPrice = BigUInt(gasPriceData)
            guard let gasLimitData = rlpItem[2]!.data else { return nil }
            let gasLimit = BigUInt(gasLimitData)
            var to: Address
            switch rlpItem[3]!.content {
            case .noItem:
                to = .contractDeployment
            case let .data(addressData):
                if addressData.count == 0 {
                    to = .contractDeployment
                } else if addressData.count == 20 {
                    to = Address(addressData)
                } else {
                    return nil
                }
            case .list:
                return nil
            }
            guard let valueData = rlpItem[4]!.data else { return nil }
            let value = BigUInt(valueData)
            guard let transactionData = rlpItem[5]!.data else { return nil }
            guard let vData = rlpItem[6]!.data else { return nil }
            let v = BigUInt(vData)
            guard let rData = rlpItem[7]!.data else { return nil }
            let r = BigUInt(rData)
            guard let sData = rlpItem[8]!.data else { return nil }
            let s = BigUInt(sData)
            return EthereumTransaction(nonce: nonce, gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: transactionData, v: v, r: r, s: s)
        case 6?:
            return nil
        default:
            return nil
        }
    }

    static func createRequest(method: JsonRpcMethod, transaction: EthereumTransaction, onBlock: String? = nil, options: Web3Options?) -> JsonRpcRequest? {
        var request = JsonRpcRequest(method: method)
//        guard let from = options?.from else { return nil }
        guard var txParams = transaction.encodeAsDictionary(from: options?.from) else { return nil }
        if method == .estimateGas || options?.gasLimit == nil {
            txParams.gas = nil
        }
        var params = [txParams] as Array<Encodable>
        if method.parameters == 2 && onBlock != nil {
            params.append(onBlock as Encodable)
        }
        let pars = JsonRpcParams(params: params)
        request.params = pars
        if !request.isValid { return nil }
        return request
    }

    static func createRawTransaction(transaction: EthereumTransaction) -> JsonRpcRequest? {
        guard transaction.sender != nil else { return nil }
        guard let encodedData = transaction.encode() else { return nil }
        let hex = encodedData.toHexString().withHex.lowercased()
        var request = JsonRpcRequest(method: .sendRawTransaction)
        let params = [hex] as Array<Encodable>
        let pars = JsonRpcParams(params: params)
        request.params = pars
        if !request.isValid { return nil }
        return request
    }
}
