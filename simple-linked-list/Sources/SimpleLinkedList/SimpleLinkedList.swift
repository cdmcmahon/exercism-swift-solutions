//Solution goes in Sources
class Element<T> {
    let value: T?
    var next: Element?
    
    init() {
        self.value = nil
        self.next = nil
    }
    init(_ value: T?, _ next: Element?) {
        self.value = value
        self.next = next
    }
    
    func reverseElements() -> Element<T> {
        return _reverseElements(nil)
    }
    
    private func _reverseElements(_ prev: Element?) -> Element {
        let newElement = Element(self.value, prev)
        guard self.next != nil else {
            return newElement
        }
        return self.next!._reverseElements(newElement)
    }
    
    static func fromArray(_ arr: [T]) -> Element {
        guard !arr.isEmpty else { return Element() }
        let rest = Array(arr.dropFirst())
        return Element(arr[0], fromArray(rest))
    }
    
    func toArray() -> [T] {
        let selfArray = self.value != nil ? [self.value!] : []
        guard self.next != nil else {
            return selfArray
        }
        return selfArray + self.next!.toArray()
    }
    
    func toArrayBad() -> [T] {
        var arr: [T] = []
        var pointer: Element? = self
        while pointer != nil {
            if (pointer?.value != nil) {
                arr.append(pointer!.value!)
            }
            pointer = pointer?.next
        }
        return arr
    }
}
