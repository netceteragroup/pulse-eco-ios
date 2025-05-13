extension Array where Element: Hashable {
    /// Get's the most frequent element on the array. First it converts the array to a set, then we map it to a dictionary
    /// where the key is the value of the array and the value is the number of times the element is in the array,
    /// Then we need to find the max value from the dictionary and from there return the key which is the original value in the array.
    var mostFrequentValue: Element? {
        let set = Set(self)
        let uniqueKeysWithValues = set.map { ($0, self.filter { $0 == $0 }.count) }
        let dictionary = Dictionary(uniqueKeysWithValues: uniqueKeysWithValues)
        let maxEntry = dictionary.max { $0.value < $1.value }
        return maxEntry?.key
    }
}
