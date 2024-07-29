//
//  PropertyWrappers.swift
//  HollowCodable
//
//  Created by Condy on 2024/6/1.
//

import Foundation

// MARK: - Float

/// Use the values in `T` when (en/de)coding this immutable Property with non-conforming numbers, also known as IEEE 754 exceptional values.
public typealias NonConformingFloatCoding<T: NonConformingDecimalValueProvider> = AnyBacked<NonConformingFloatValue<T>>
/// Use the values in `T` when decoding this immutable Property with non-conforming numbers, also known as IEEE 754 exceptional values.
public typealias NonConformingFloatDecoding<T: NonConformingDecimalValueProvider> = AnyBackedDecoding<NonConformingFloatValue<T>>
/// Use the values in `T` when encoding this immutable Property with non-conforming numbers, also known as IEEE 754 exceptional values.
public typealias NonConformingFloatEncoding<T: NonConformingDecimalValueProvider> = AnyBackedEncoding<NonConformingFloatValue<T>>

// MARK: - Double

/// Use the values in `T` when (en/de)coding this immutable Property with non-conforming numbers, also known as IEEE 754 exceptional values.
public typealias NonConformingDoubleCoding<T: NonConformingDecimalValueProvider> = AnyBacked<NonConformingDoubleValue<T>>
/// Use the values in `T` when decoding this immutable Property with non-conforming numbers, also known as IEEE 754 exceptional values.
public typealias NonConformingDoubleDecoding<T: NonConformingDecimalValueProvider> = AnyBackedDecoding<NonConformingDoubleValue<T>>
/// Use the values in `T` when encoding this immutable Property with non-conforming numbers, also known as IEEE 754 exceptional values.
public typealias NonConformingDoubleEncoding<T: NonConformingDecimalValueProvider> = AnyBackedEncoding<NonConformingDoubleValue<T>>

// MARK: - Date

/// If you want to use it like this: `@DateCoding<Hollow.DateFormat.yyyy, Hollow.Timestamp.secondsSince1970>`
public typealias DateCoding<D: DateConverter, E: DateConverter> = AnyBacked<DateValue<D,E>>
public typealias DateDecoding<D: DateConverter> = AnyBackedDecoding<DateValue<D,D>>
public typealias DateEncoding<E: DateConverter> = AnyBackedEncoding<DateValue<E,E>>

public typealias DateFormatterCoding<D: DateConverter, E: DateConverter> = DateCoding<D,E>

/// If you want to use it like this: `@DateFormatCoding<Hollow.DateFormat.yyyy_mm_dd>`
public typealias DateFormatCoding<T: DateConverter>   = AnyBacked<DateValue<T,T>>
public typealias DateFormatDecoding<D: DateConverter> = AnyBackedDecoding<DateValue<D,D>>
public typealias DateFormatEncoding<E: DateConverter> = AnyBackedEncoding<DateValue<E,E>>

/// If you want to use it like this: `@TimestampDateCoding<Hollow.Timestamp.millisecondsSince1970>`
public typealias TimestampDateCoding<D: DateConverter, E: DateConverter> = AnyBacked<DateValue<D,E>>
public typealias TimestampDateDecoding<D: DateConverter> = AnyBackedDecoding<DateValue<D,D>>
public typealias TimestampDateEncoding<E: DateConverter> = AnyBackedEncoding<DateValue<E,E>>

public typealias Since1970DateCoding<T: DateConverter> = TimestampDateCoding<T,T>

public typealias SecondsSince1970DateCoding   = TimestampDateCoding<Hollow.Timestamp.secondsSince1970, Hollow.Timestamp.secondsSince1970>
public typealias SecondsSince1970DateDecoding = TimestampDateDecoding<Hollow.Timestamp.secondsSince1970>
public typealias SecondsSince1970DateEncoding = TimestampDateEncoding<Hollow.Timestamp.secondsSince1970>

public typealias MilliSecondsSince1970DateCoding   = TimestampDateCoding<Hollow.Timestamp.millisecondsSince1970, Hollow.Timestamp.millisecondsSince1970>
public typealias MilliSecondsSince1970DateDecoding = TimestampDateDecoding<Hollow.Timestamp.millisecondsSince1970>
public typealias MilliSecondsSince1970DateEncoding = TimestampDateEncoding<Hollow.Timestamp.millisecondsSince1970>

public typealias ISO8601DateCoding  = DateFormatCoding<Hollow.DateFormat.ISO8601Date>
public typealias ISO8601DateDeoding = DateFormatDecoding<Hollow.DateFormat.ISO8601Date>
public typealias ISO8601DateEnoding = DateFormatEncoding<Hollow.DateFormat.ISO8601Date>

public typealias RFC2822DateCoding  = DateFormatCoding<Hollow.DateFormat.RFC2822Date>
public typealias RFC2822DateDeoding = DateFormatDecoding<Hollow.DateFormat.RFC2822Date>
public typealias RFC2822DateEnoding = DateFormatEncoding<Hollow.DateFormat.RFC2822Date>

public typealias RFC3339DateCoding  = DateFormatCoding<Hollow.DateFormat.RFC3339Date>
public typealias RFC3339DateDeoding = DateFormatDecoding<Hollow.DateFormat.RFC3339Date>
public typealias RFC3339DateEnoding = DateFormatEncoding<Hollow.DateFormat.RFC3339Date>

// MARK: - NSDecimalNumber

/// Decoding the `String`、`Double`、`Float`、`CGFloat`、`Int` or `Int64` to a NSDecimalNumber property.
public typealias DecimalNumberCoding   = AnyBacked<DecimalNumberValue>
public typealias DecimalNumberDecoding = AnyBackedDecoding<DecimalNumberValue>
public typealias DecimalNumberEncoding = AnyBackedEncoding<DecimalNumberValue>

// MARK: - Color

/// When coding the color hex value hasn't alpha.
public typealias HexColorCoding   = AnyBacked<HexColor<False>>
public typealias HexColorDecoding = AnyBackedDecoding<HexColor<False>>
public typealias HexColorEncoding = AnyBackedEncoding<HexColor<False>>

public typealias HexColorHasAlphaCoding   = AnyBacked<HexColor<True>>
public typealias HexColorHasAlphaDecoding = AnyBackedDecoding<HexColor<True>>
public typealias HexColorHasAlphaEncoding = AnyBackedEncoding<HexColor<True>>

public typealias RGBColorCoding   = AnyBacked<RGB>
public typealias RGBColorDecoding = AnyBackedDecoding<RGB>
public typealias RGBColorEncoding = AnyBackedEncoding<RGB>

public typealias RGBAColorCoding   = AnyBacked<RGBA>
public typealias RGBAColorDecoding = AnyBackedDecoding<RGBA>
public typealias RGBAColorEncoding = AnyBackedEncoding<RGBA>

// MARK: - Bool

public typealias BoolCoding   = AnyBacked<BooleanValue<False>>
public typealias BoolDecoding = AnyBackedDecoding<BooleanValue<False>>
public typealias BoolEncoding = AnyBackedEncoding<BooleanValue<False>>

public typealias FalseBoolCoding   = DefaultBacked<BooleanValue<False>>
public typealias FalseBoolDecoding = DefaultBackedDecoding<BooleanValue<False>>
public typealias FalseBoolEncoding = DefaultBackedEncoding<BooleanValue<False>>

public typealias TrueBoolCoding   = DefaultBacked<BooleanValue<True>>
public typealias TrueBoolDecoding = DefaultBackedDecoding<BooleanValue<True>>
public typealias TrueBoolEncoding = DefaultBackedEncoding<BooleanValue<True>>

// MARK: - CGRect

public typealias CGRectCoding   = AnyBacked<RectValue>
public typealias CGRectDecoding = AnyBackedDecoding<RectValue>
public typealias CGRectEncoding = AnyBackedEncoding<RectValue>

// MARK: - CGPoint

public typealias PointCoding   = AnyBacked<PointValue>
public typealias PointDecoding = AnyBackedDecoding<PointValue>
public typealias PointEncoding = AnyBackedEncoding<PointValue>

// MARK: - Enum

public typealias EnumCoding<T: RawRepresentable>   = AnyBacked<EnumValue<T>> where T.RawValue: Codable
public typealias EnumDecoding<T: RawRepresentable> = AnyBackedDecoding<EnumValue<T>> where T.RawValue: Codable
public typealias EnumEncoding<T: RawRepresentable> = AnyBackedEncoding<EnumValue<T>> where T.RawValue: Codable

public typealias DefaultEnumCoding<T: CaseDefaultProvider>   = DefaultBacked<EnumValue<T>> where T.RawValue: Codable
public typealias DefaultEnumDecoding<T: CaseDefaultProvider> = DefaultBackedDecoding<EnumValue<T>> where T.RawValue: Codable
public typealias DefaultEnumEncoding<T: CaseDefaultProvider> = DefaultBackedEncoding<EnumValue<T>> where T.RawValue: Codable

// MARK: - Data

public typealias Base64Coding   = AnyBacked<DataValue<Hollow.Base64Data>>
public typealias Base64Decoding = AnyBackedDecoding<DataValue<Hollow.Base64Data>>
public typealias Base64Encoding = AnyBackedEncoding<DataValue<Hollow.Base64Data>>

// MARK: - Dictionary

/// Support any value property wrapper with dictionary, decodes any value json into `[String:Any]`.
public typealias DictionaryCoding   = AnyBacked<AnyDictionary>
public typealias DictionaryDecoding = AnyBackedDecoding<AnyDictionary>
public typealias DictionaryEncoding = AnyBackedEncoding<AnyDictionary>

/// Decodes Dictionaries filtering invalid key-value pairs.
public typealias LossyDictionaryCoding<K: Hashable & Codable, V: Codable>   = AnyBacked<LossyDictionaryValue<K, V>>
public typealias LossyDictionaryDecoding<K: Hashable & Codable, V: Codable> = AnyBackedDecoding<LossyDictionaryValue<K,V>>
public typealias LossyDictionaryEncoding<K: Hashable & Codable, V: Codable> = AnyBackedEncoding<LossyDictionaryValue<K,V>>

// MARK: - Array

/// Support any value property wrapper with array, decodes any value json into `[Any]`.
public typealias ArrayCoding   = AnyBacked<AnyArray>
public typealias ArrayDecoding = AnyBackedDecoding<AnyArray>
public typealias ArrayEncoding = AnyBackedEncoding<AnyArray>

/// Support any value dictionary property wrapper with array, decodes any value json into `[[String:Any]]`.
public typealias ArrayDictionaryCoding   = AnyBacked<AnyDictionaryArray>
public typealias ArrayDictionaryDecoding = AnyBackedDecoding<AnyDictionaryArray>
public typealias ArrayDictionaryEncoding = AnyBackedEncoding<AnyDictionaryArray>

/// Decodes Dictionaries filtering invalid value pairs.
public typealias LossyArrayCoding<T: Codable>   = AnyBacked<LossyArrayValue<T>>
public typealias LossyArrayDecoding<T: Codable> = AnyBackedDecoding<LossyArrayValue<T>>
public typealias LossyArrayEncoding<T: Codable> = AnyBackedEncoding<LossyArrayValue<T>>

public typealias LosslessArrayCoding<T: Codable & LosslessStringConvertible>   = AnyBacked<LosslessArrayValue<T>>
public typealias LosslessArrayDecoding<T: Codable & LosslessStringConvertible> = AnyBackedDecoding<LosslessArrayValue<T>>
public typealias LosslessArrayEncoding<T: Codable & LosslessStringConvertible> = AnyBackedEncoding<LosslessArrayValue<T>>

// MARK: - Any

/// Support any value property wrapper with Any, decodes any value json into `Any`.
public typealias AnyValueCoding   = AnyBacked<AnyX>
public typealias AnyValueDecoding = AnyBackedDecoding<AnyX>
public typealias AnyValueEncoding = AnyBackedEncoding<AnyX>

public typealias AnyXCoding   = AnyBacked<AnyX>
public typealias AnyXDecoding = AnyBackedDecoding<AnyX>
public typealias AnyXEncoding = AnyBackedEncoding<AnyX>

// MARK: - String

public typealias StringToCoding<T: Codable & LosslessStringConvertible>   = AnyBacked<LosslessValue<T>>
public typealias StringToDecoding<T: Codable & LosslessStringConvertible> = AnyBackedDecoding<LosslessValue<T>>
public typealias StringToEncoding<T: Codable & LosslessStringConvertible> = AnyBackedEncoding<LosslessValue<T>>

public typealias LosslessStringCoding<T: Codable & LosslessStringConvertible>   = AnyBacked<LosslessValue<T>>
public typealias LosslessStringDecoding<T: Codable & LosslessStringConvertible> = AnyBackedDecoding<LosslessValue<T>>
public typealias LosslessStringEncoding<T: Codable & LosslessStringConvertible> = AnyBackedEncoding<LosslessValue<T>>

/// Automatic change of type, like int <-> string, bool <-> string.
public typealias AutoConvertedCoding<T: Codable & CustomStringConvertible>   = AnyBacked<AutoConvertedValue<T>>
public typealias AutoConvertedDecoding<T: Codable & CustomStringConvertible> = AnyBackedDecoding<AutoConvertedValue<T>>
public typealias AutoConvertedEncoding<T: Codable & CustomStringConvertible> = AnyBackedEncoding<AutoConvertedValue<T>>

public typealias CustomStringCoding<T: Codable & CustomStringConvertible>   = AnyBacked<AutoConvertedValue<T>>
public typealias CustomStringDecoding<T: Codable & CustomStringConvertible> = AnyBackedDecoding<AutoConvertedValue<T>>
public typealias CustomStringEncoding<T: Codable & CustomStringConvertible> = AnyBackedEncoding<AutoConvertedValue<T>>

// MARK: - Lossless

public typealias LosslessCoding<T: Codable & LosslessStringConvertible>   = AnyBacked<LosslessValue<T>>
public typealias LosslessDecoding<T: Codable & LosslessStringConvertible> = AnyBackedDecoding<LosslessValue<T>>
public typealias LosslessEncoding<T: Codable & LosslessStringConvertible> = AnyBackedEncoding<LosslessValue<T>>
