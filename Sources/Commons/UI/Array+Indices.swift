//
//  Array+Indices.swift
//  Pacer
//
//  Created by Erik Terwan on 21/03/2023.
//

extension Array {

	/// Zips the an array into an array containing the indices and corresponding elements. This is useful when
	/// you have an array of structs that you want to safely identify when iterating over.
	///
	/// Example:
	/// ```
	/// ForEach(viewModel.rows.zippedIndices, id: \.index) { index, row in
	/// 	...
	/// }
	/// ```
	public var zippedIndices: Array<(index: Int, element: Element)> {
		zip(self.indices, self).map {
			(index: $0, element: $1)
		}
	}
}
