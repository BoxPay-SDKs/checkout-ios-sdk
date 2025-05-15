//
//  BottomSheet.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUICore

struct BottomSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let content: () -> SheetContent

    @State private var showContent = false

    func body(content base: Content) -> some View {
        ZStack {
            base

            if isPresented {
                // Dimmed background (not tappable)
                Color.black.opacity(showContent ? 0.4 : 0.0)
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false) // 👈 disables tap on background

                // Bottom sheet content
                VStack {
                    Spacer()

                    if showContent {
                        self.content()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .transition(.move(edge: .bottom))
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showContent)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showContent = true
                    }
                }
            }
        }
    }
}


extension View {
    func bottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(BottomSheet(isPresented: isPresented, content: content))
    }
}
