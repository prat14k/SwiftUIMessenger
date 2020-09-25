//
//  ChatViewModel.swift
//  SwiftUICombineDemo
//
//  Created by Prateek on 24/09/20.
//

import Foundation
import MultipeerConnectivity
import Combine

final class ChatViewModel: NSObject, ObservableObject {
    enum AppState: String {
        case inactive = "InActive"
        case searching = "Searching for Chat"
        case connectedToHost = "Connected To Host"
        case hostingAwaitingPeers = "Waiting for Peers"
        case hostingWithPeers = "Hosting Chat"

        var isConnected: Bool {
            [.connectedToHost, .hostingWithPeers].contains(self)
        }
    }

    static let serviceType = "local-chat-bar"
    static var bottomSafeArea: CGFloat {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0
    }

    @Published private(set) var appState = AppState.inactive
    @Published var newMessageText = ""
    @Published private(set) var messages = [Message(userName: User.current.name, text: "Hello world", timeStamp: "")]
//    @Published private(set) var keyboardOffset: CGFloat = 0
//    @Published private(set) var keyboardAnimationDuration: TimeInterval = 0

    private lazy var mcSession: MCSession = {
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    private let peerID = MCPeerID(displayName: User.current.name)
    private var hostID: MCPeerID?
    private lazy var advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil,
                                                            serviceType: Self.serviceType)
    private lazy var browser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
    private var subscriptions = Set<AnyCancellable>()
    
//    override init() {
//        super.init()
//        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
//            .handleEvents(receiveOutput: { [weak self] (_) in
//                self?.keyboardOffset = 0
//            })
//            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification))
//            .map(\.userInfo)
//            .compactMap({ ($0?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue })
//            .assign(to: \.keyboardAnimationDuration, on: self)
//            .store(in: &subscriptions)
//
//        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
//            .map(\.userInfo)
//            .compactMap({ ($0?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size.height })
//            .map({ $0 * -1 + Self.bottomSafeArea })
//            .assign(to: \.keyboardOffset, on: self)
//            .store(in: &subscriptions)
//    }

    var timeStamp: String { DateFormatter.formatter.string(from: Date()) }

    var isNewMessageEmpty: Bool { newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func isPreviousMessageSenderSame(ofMessage message: Message) -> Bool {
        guard let index = messages.firstIndex(where: { $0.id == message.id }),
                index > 0
        else { return false }
        return messages[index - 1].userName == message.userName
    }

    func isNextMessageSenderSame(ofMessage message: Message) -> Bool {
        guard let index = messages.firstIndex(where: { $0.id == message.id }),
                index < messages.count - 1
        else { return false }
        return messages[index + 1].userName == message.userName
    }

    var actionSheetTitle: String {
        switch appState {
        case .inactive: return "Wanna join or host chat?"
        case .searching, .connectedToHost: return "Want to disconnect?"
        case .hostingAwaitingPeers, .hostingWithPeers: return "Wanna stop hosting?"
        }
    }

    private func insert(message: Message) {
        DispatchQueue.main.async { [weak self] in
            self?.messages.append(message)
        }
    }

    func clear() {
        newMessageText = ""
    }

    func send() {
        guard !isNewMessageEmpty  else { return }
        let message = Message(userName: User.current.name,
                              text: newMessageText.trimmingCharacters(in: .whitespacesAndNewlines),
                              timeStamp: timeStamp)
        insert(message: message)
        newMessageText = ""
        do {
            let data = try JSONEncoder().encode(message)
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            print(error)
        }
    }

    func startAdvertising() {
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        appState = .hostingAwaitingPeers
        hostID = peerID
    }

    func startBrowsing() {
        browser.delegate = self
        browser.startBrowsingForPeers()
        appState = .searching
    }

    func disconnect() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        mcSession.disconnect()
        hostID = nil
        DispatchQueue.main.async { [weak self] in
            self?.appState = .inactive
        }
    }
}

extension ChatViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard state != .connecting,
              hostID == self.peerID, // I am the host
              peerID != self.peerID // Event not for me
        else { return }
        DispatchQueue.main.async { [weak self] in
            self?.appState = session.connectedPeers.isEmpty ? .hostingAwaitingPeers : .hostingWithPeers
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            insert(message: try JSONDecoder().decode(Message.self, from: data))
        } catch {
            print("Error: \(error)")
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension ChatViewModel: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mcSession)
        appState = .hostingWithPeers
    }
}

extension ChatViewModel: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 30)
        appState = .connectedToHost
        hostID = peerID
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard hostID == peerID  else { return }
        disconnect()
    }
}
