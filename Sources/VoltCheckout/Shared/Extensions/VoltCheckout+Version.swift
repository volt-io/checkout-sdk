extension VoltCheckout {
    /// A type describing the VoltCheckout SDK version.
    public struct Version: Sendable {
        /// The string value for this version.
        public let value: String

        /// The current VoltCheckout SDK version.
        public static let current = Self(value: "1.0.5")

        /// Private initializer.
        ///
        /// - parameter value: The string value for this version.
        private init(value: String) {
            self.value = value
        }
    }
}
