/*
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
David Roman - https://github.com/davdroman
https://github.com/davdroman/swift-builders.git
*/

#if canImport(Foundation)
import Foundation
#endif

public typealias ArrayBuilder<Element> = Array<Element>.Builder

public typealias ArraySliceBuilder<Element> = ArraySlice<Element>.Builder

public typealias ContiguousArrayBuilder<Element> = ContiguousArray<Element>.Builder

#if canImport(Foundation)
public typealias DataBuilder = Data.Builder
#endif

public typealias DictionaryBuilder<Key: Hashable, Value> = Dictionary<Key, Value>.Builder

public typealias SetBuilder<Element: Hashable> = Set<Element>.Builder

public typealias SliceBuilder<Base: RangeReplaceableCollection> = Slice<Base>.Builder

public typealias StringBuilder = String.Builder

public typealias StringUTF8ViewBuilder = String.UTF8View.Builder

public typealias StringUnicodeScalarViewBuilder = String.UnicodeScalarView.Builder

public typealias SubstringBuilder = Substring.Builder

public typealias SubstringUTF8ViewBuilder = Substring.UTF8View.Builder

public typealias SubstringUnicodeScalarViewBuilder = Substring.UnicodeScalarView.Builder
