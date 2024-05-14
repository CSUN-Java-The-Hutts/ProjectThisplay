//
//  Server+Uploader.swift
//  ThisPlay
//
import SwiftUI

class ServerUploader: ObservableObject {
    @Published var blockStatuses: [String] = []
    @Published var currentRetries: Int = 0
    var uploadStatusUpdate: ((String) -> Void)?
    
    var server: Server

    init(server: Server, uploadStatusUpdate: @escaping (String) -> Void) {
        self.server = server
        self.uploadStatusUpdate = uploadStatusUpdate
    }

    func uploadCanvas(b64Buffers: [String]) {
        blockStatuses = Array(repeating: "Pending", count: b64Buffers.count)
        currentRetries = 0 // Reset retries
        sequentialPost(buffers: b64Buffers)
    }

    private func sequentialPost(buffers: [String]) {
        var block = 0
        var sequenceRetries = 0 // max 3
        var blockRetries = 0 // max 2

        func postNext() {
            guard block < buffers.count, sequenceRetries < 3 else {
                if block == buffers.count {
                    updateUploadStatus("SUCCESS.")
                } else {
                    updateUploadStatus("Upload failed.")
                }
                DispatchQueue.main.async {}
                return
            }

            let urlString = "http://\(server.ipAddress)/block\(block)" // Use the current server's IP address
            guard let url = URL(string: urlString) else {
                updateBlockStatus(block, status: "Error: Invalid URL")
                updateUploadStatus("Error: Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = buffers[block].data(using: .utf8)
            
            // Logging
            print("Attempting to POST to URL: \(urlString)")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.updateBlockStatus(block, status: "Error: \(error.localizedDescription)")
                    retryPost()
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.updateBlockStatus(block, status: "Error: Invalid response")
                    retryPost()
                    return
                }

                self.updateBlockStatus(block, status: "\(httpResponse.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")

                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    blockRetries = 0
                    block += 1
                    postNext()
                } else if httpResponse.statusCode == 409 {
                    self.updateUploadStatus("Restarting sequence...")
                    sequenceRetries += 1
                    blockRetries = 0
                    block = 0
                    postNext()
                } else {
                    retryPost()
                }
            }
            task.resume()
        }

        func retryPost() {
            blockRetries += 1
            currentRetries = blockRetries // Update current retries
            if blockRetries > 2 {
                blockRetries = 0
                sequenceRetries += 1
                block = 0
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                postNext()
            }
        }

        postNext()
    }

    private func updateBlockStatus(_ block: Int, status: String) {
        DispatchQueue.main.async {
            if self.blockStatuses.indices.contains(block) {
                self.blockStatuses[block] = status
            }
        }
    }

    private func updateUploadStatus(_ text: String) {
        DispatchQueue.main.async {
            self.uploadStatusUpdate?(text)
        }
    }
}
