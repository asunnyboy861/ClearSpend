import SwiftUI
import PhotosUI

struct ReceiptScanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isScanning = false
    @State private var errorMessage: String?
    
    private let scanner = ReceiptScannerService()
    private let onScanned: (ScannedReceipt) -> Void
    
    init(onScanned: @escaping (ScannedReceipt) -> Void) {
        self.onScanned = onScanned
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 200)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("Select a receipt photo")
                                    .foregroundColor(.secondary)
                            }
                        }
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                if selectedImage != nil {
                    Button(action: scanReceipt) {
                        if isScanning {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Label("Scan Receipt", systemImage: "doc.text.viewfinder")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isScanning)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Scan Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        errorMessage = nil
                    }
                }
            }
        }
    }
    
    private func scanReceipt() {
        guard let image = selectedImage else { return }
        isScanning = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await scanner.scanReceipt(from: image)
                onScanned(result)
                dismiss()
            } catch {
                errorMessage = "Failed to scan receipt. Try a clearer photo."
            }
            isScanning = false
        }
    }
}
