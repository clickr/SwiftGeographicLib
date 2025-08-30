#!/bin/zsh


#    echo $2 -31.93980 115.96650 |
    
res=$(MagneticField -n $1 --input-string "$2 -31.93980 115.96650")

resArr=(${(@s: :)res})

echo $resArr

declination=$resArr[1]
inclination=$resArr[2]
h=$resArr[3]
t=$resArr[7]

echo // $1 >> MagneticModelTests.swift
echo @Test func $1 "() throws {" >> MagneticModelTests.swift
echo "    //    echo $2 -31.93980 115.96650 | MagneticField -n $1" >> MagneticModelTests.swift
echo "    //    $res" >> MagneticModelTests.swift
echo "    let model = MagneticModel.$1" >> MagneticModelTests.swift
echo "    let date = dateFormatter.date(from: \"$2\")!" >> MagneticModelTests.swift
echo "    let result = try model.magneticComponents(date: date, coordinate: ypph)" >> MagneticModelTests.swift
echo "    #expect(result.declination.isApproximatelyEqual(to: $declination, absoluteTolerance: 1e-2))" >> MagneticModelTests.swift
echo "    #expect(result.inclination.isApproximatelyEqual(to: $inclination, absoluteTolerance: 1e-2))" >> MagneticModelTests.swift
echo "    #expect(result.horizontalField.isApproximatelyEqual(to: $h, absoluteTolerance: 1e-1))" >> MagneticModelTests.swift
echo "    #expect(result.totalField.isApproximatelyEqual(to: $t, absoluteTolerance: 1e-1))" >> MagneticModelTests.swift
echo "}" >> MagneticModelTests.swift

echo "Declination =" $declination
echo "Total Field =" $t


