//
//  SavedAddressCard.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 11/08/25.
//
import SwiftUI

struct SavedAddressCard: View {
    var addressDetails: SavedAddressResponse
    @Binding var selectedAddressRef: SavedAddressResponse?
    var brandColor : String
    var onClickAddress : (_ addressRef : SavedAddressResponse) -> Void
    var onClickOtherOptions :(_ address : SavedAddressResponse) -> Void
    
    private var labelIcon: String {
            switch addressDetails.labelType.lowercased() {
            case "home":
                return "ic_home"
            case "office":
                return "ic_work"
            default:
                return "ic_other" // for 'others'
            }
        }
    
    var body: some View {
        Button(action: {
            onClickAddress(addressDetails)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Title Row
                HStack(spacing: 6) {
                    Image(frameworkAsset: labelIcon, isTemplate: true)
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color(hex: "#2D2B32"))
                    
                    Text(addressDetails.labelName ?? addressDetails.labelType)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#2D2B32"))
                    
                    if selectedAddressRef?.addressRef == addressDetails.addressRef {
                        FilterTag(filterText: "CURRENTLY SELECTED")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onClickOtherOptions(addressDetails)
                    }) {
                        Image(frameworkAsset: "ic_more_options")
                            .frame(width: 20, height: 20)
                    }
                }
                let addressString = [
                    addressDetails.address1,
                    addressDetails.address2?.isEmpty == false ? addressDetails.address2 : nil,
                    addressDetails.city,
                    addressDetails.state,
                    addressDetails.postalCode
                ]
                .compactMap { $0 } // remove nil values
                .joined(separator: ", ")
                
                // Address
                Text(addressString)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color(hex: "#7F7D83"))
                    .multilineTextAlignment(.leading)
                
                // Phone Number (only if present)
                if !addressDetails.phoneNumber.isEmpty {
                    Text(addressDetails.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedAddressRef?.addressRef == addressDetails.addressRef ? Color(hex: brandColor) : Color.clear, lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
}


struct EditOrDeleteBottomSheet : View {
    var address: SavedAddressResponse
    var onEdit : (_ address : SavedAddressResponse) -> Void
    var onSetDefault : (_ address : SavedAddressResponse) -> Void
    var onDelete : (_ address : SavedAddressResponse) -> Void
    
    private var labelIcon: String {
        switch address.labelType.lowercased() {
        case "home":
            return "ic_home"
        case "office":
            return "ic_work"
        default:
            return "ic_other" // for 'others'
        }
    }

    
    var body: some View {
        VStack(spacing: 16) {
            let addressString = [
                address.address1,
                address.address2?.isEmpty == false ? address.address2 : nil,
                address.city,
                address.state,
                address.postalCode
            ]
            .compactMap { $0 } // remove nil values
            .joined(separator: ", ")
                    
                    // Address Header
                    HStack(alignment: .top, spacing: 8) {
                        Image(frameworkAsset: labelIcon, isTemplate: true)
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color(hex: "#2D2B32"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(address.labelName ?? address.labelType)
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(.black)
                            
                            Text(addressString)
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(Color(hex: "#7F7D83"))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
            VStack {
                Button(action: {
                    onEdit(address)
                }) {
                            Text("Edit")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(Color(hex: "#2D2B32"))
                        }
                .padding(.top, 10)
                        
                        Divider()
                    .padding(10)
                        
                        // Set as Default
                Button(action: {
                    onSetDefault(address)
                }) {
                            Text("Set as Default")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(Color(hex: "#2D2B32"))
                        }
                .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .padding(.horizontal,16)
            .cornerRadius(12)
                    
            Button(action: {
                onDelete(address)
            }) {
                        Text("Delete address")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(Color(hex: "#FF4D4F"))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
                .background(Color(hex: "#F8F9FD"))
                .cornerRadius(20)
    }
}
