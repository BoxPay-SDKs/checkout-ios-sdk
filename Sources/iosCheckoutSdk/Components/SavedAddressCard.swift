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
    var onClickOtherOptions :() -> Void
    
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
                        onClickOtherOptions()
                    }) {
                        Image(frameworkAsset: "ic_more_options")
                            .frame(width: 20, height: 20)
                    }
                }
                
                // Address
                Text("\(addressDetails.address1), \(addressDetails.address2), \(addressDetails.city), \(addressDetails.state), \(addressDetails.postalCode), \(addressDetails.countryCode)")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color(hex: "#7F7D83"))
                
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

