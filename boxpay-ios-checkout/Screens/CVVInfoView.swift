////
////  CVVInfoView.swift
////  boxpay-ios-checkout
////
////  Created by ankush on 27/01/25.
////
//
//
//import SwiftUI
//
//struct CVVInfoView: View {
//    var onGoBack: () -> Void
//    var body: some View {
//        VStack(spacing: 20) {
//            HStack {
//                Text("Where to find CVV?")
//                    .font(.headline)
//                Spacer()
//            }
//            .padding(.top, 20)
//            .padding(.horizontal)
//            
//            // Generic CVV Info
//            HStack(alignment: .center, spacing: 15) {
//                Image(systemName: "creditcard.fill") // Placeholder for card image
//                    .resizable()
//                    .frame(width: 60, height: 40)
//                    .foregroundColor(.gray)
//                    .overlay(Text("***").font(.title2).foregroundColor(.white))
//                
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Generic position for CVV")
//                        .font(.subheadline)
//                        .bold()
//                    
//                    Text("3-digit numeric code on the back side of card")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                }
//                
//                Spacer()
//            }
//            .padding(.horizontal)
//            
//            Divider()
//            
//            // American Express CVV Info
//            HStack(alignment: .center, spacing: 15) {
//                Image(systemName: "creditcard.fill") // Placeholder for card image
//                    .resizable()
//                    .frame(width: 60, height: 40)
//                    .foregroundColor(.gray)
//                    .overlay(Text("****").font(.title2).foregroundColor(.white))
//                
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("CVV for American Express Card")
//                        .font(.subheadline)
//                        .bold()
//                    
//                    Text("4-digit numeric code on the front side of the card, just above the card number")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                }
//                
//                Spacer()
//            }
//            .padding(.horizontal)
//            
//            
//            Button(action: {
//                // Action for "Got It!"
//                onGoBack()
//            }) {
//                Text("Got It!")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(Color.green)
//                    .cornerRadius(8)
//            }
//            .padding(.horizontal)
//            .padding(.bottom, 20)
//        }
//        .padding()
//    }
//}
//
//struct CVVInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        CVVInfoView(onGoBack: {
//            print("Go back tapped(CVV info)")
//        })
//    }
//}
