//
//  CustomWrappers.swift
//  HollowCodable
//
//  Created by Condy on 2024/6/1.
//

import Foundation

// MARK: - Date

public typealias SecondsSince1970DateCoding = Since1970DateCoding<Hollow.Interval.seconds,Hollow.Interval.seconds>
public typealias SecondsSince1970DateDecoding = Since1970DateDecoding<Hollow.Interval.seconds>
public typealias SecondsSince1970DateEncoding = Since1970DateEncoding<Hollow.Interval.seconds>

public typealias MilliSecondsSince1970DateCoding = Since1970DateCoding<Hollow.Interval.milliseconds,Hollow.Interval.milliseconds>
public typealias MilliSecondsSince1970DateDecoding = Since1970DateDecoding<Hollow.Interval.milliseconds>
public typealias MilliSecondsSince1970DateEncoding = Since1970DateEncoding<Hollow.Interval.milliseconds>

/// If you want to use it like this: `@DateFormatCoding<Hollow.DateFormat.yyyy_mm_dd>`
public typealias DateFormatCoding<T: HollowValue> = DateFormatterCoding<T,T>
public typealias DateFormatDecoding<T: HollowValue> = DateFormatterDecoding<T>
public typealias DateFormatEncoding<T: HollowValue> = DateFormatterEncoding<T>


// MARK: - Color

public typealias HexColorHasAlphaCoding = HexColorHasCoding<Hollow.HasBoolean.yes>
public typealias HexColorHasAlphaDecoding = HexColorDecoding
public typealias HexColorHasAlphaEncoding = HexColorHasEncoding<Hollow.HasBoolean.yes>

/// When coding the color hex value hasn't alpha.
public typealias HexColorCoding = HexColorHasCoding<Hollow.HasBoolean.no>
public typealias HexColorEncoding = HexColorHasEncoding<Hollow.HasBoolean.no>
