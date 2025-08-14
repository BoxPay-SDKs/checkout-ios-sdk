//
//  SavedAddressCard.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 11/08/25.
//
import SwiftUI

struct SavedAddressCard: View {
    var addressDetails: SavedAddressResponse
    @Binding var selectedAddressRef: String
    var brandColor : String
    var onClickAddress : (_ addressRef : String) -> Void
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
            onClickAddress(addressDetails.addressRef)
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
                    
                    if selectedAddressRef == addressDetails.addressRef {
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
                
                // Address
                Text("\(addressDetails.address1), \(addressDetails.address2), \(addressDetails.city), \(addressDetails.state), \(addressDetails.postalCode), \(addressDetails.countryCode)")
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
                    .stroke(selectedAddressRef == addressDetails.addressRef ? Color(hex: brandColor) : Color.clear, lineWidth: 1)
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
                    
                    // Address Header
                    HStack(alignment: .top, spacing: 8) {
                        Image(frameworkAsset: labelIcon, isTemplate: true)
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color(hex: "#2D2B32"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(address.labelName ?? address.labelType)
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(.black)
                            
                            Text("\(address.address1), \(address.address2), \(address.city), \(address.state), \(address.postalCode)")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(Color(hex: "#7F7D83"))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Edit
            Button(action: {
                onEdit(address)
            }) {
                        Text("Edit")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                    }
                    
                    Divider()
                    
                    // Set as Default
            Button(action: {
                onSetDefault(address)
            }) {
                        Text("Set as Default")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                    }
                    
                    // Delete
            Button(action: {
                onDelete(address)
            }) {
                        Text("Delete address")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                .background(Color(hex: "#F8F9FD"))
                .cornerRadius(20)
    }
}

