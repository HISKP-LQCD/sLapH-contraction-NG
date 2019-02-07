(* ::Package:: *)

(* This is the library which contains most of the functionality. The notebooks
are supposed to just to exercise this library. *)


BeginPackage["sLapHProjection`"];


(* Text IO helpers *)


ReadDataframe[path_] := Module[{assocs, bulk, data, header},
	data = Import[path, "CSV"];
	header = data[[1]];
	bulk = Drop[data, 1];
	(* https://mathematica.stackexchange.com/q/88418/1507 *)
	assocs = AssociationThread[header, #] & /@ bulk;
	Dataset[assocs]];


MatrixFromAssocList[assocs_] := Module[{dataset, rows, cols, values, size},
	dataset = Dataset[assocs];
	rows = Normal @ dataset[[All, "row"]];
	cols = Normal @ dataset[[All, "col"]];
	values = Normal @ dataset[[All, "matrix element"]];
	size = Length @ values;
	Partition[ToExpression /@ values, Sqrt[size]]];


MatrixLongToActual[dataset_] := GroupBy[
	dataset,
	Normal @ Values @ Take[#, 6] &,
	MatrixFromAssocList];


ConvertMatrixElement[dataset_] := Module[{normal},
	normal = Normal[dataset];
	normal[[All, "matrix element"]] = ToExpression /@ Normal @ normal[[All, "matrix element"]];
	Dataset[normal]];


ReadIrreps = ConvertMatrixElement @* ReadDataframe;


MatrixElementsToAssociation[dataset_] := GroupBy[
	dataset,
	Normal @ Values @ Take[#, 6] &,
	Association[{#[["row"]], #[["col"]]} -> #[["matrix element"]] & /@ #] &]


IrrepsToAssociations[matrixElementsAssociations_] := Module[{keysIrrep, keysIrrep2, irrep3},
	keysIrrep = Normal @ GroupBy[Keys @ matrixElementsAssociations, #[[1]] &];
	keysIrrep2 = #[[2]] -> # & /@ # & /@ keysIrrep;
	irrep3 = matrixElementsAssociations[Key @ #] & /@ Association @ # & /@ keysIrrep2;
	Map[Normal, irrep3, Infinity]]


DatasetToAssocations := IrrepsToAssociations @* MatrixElementsToAssociation;


ExtractMomentumFromFilename[filename_] := First[ToExpression /@ StringCases[
	filename,
	RegularExpression["\\((-?\\d+),(-?\\d+),(-?\\d+)\\)"] -> {"$1", "$2", "$3"}]]


ReadEulerAngles[filename_] := Module[{oh, values},
	oh = ReadDataframe[filename];
	values = Normal[Values /@ oh];
	#[[1]] -> Pi * {#[[2]], #[[3]], #[[4]]} & /@ values // Association];


(* Momentum transformation *)


MomentumRefScalar[0] = {0,0,0};
MomentumRefScalar[1] = {0,0,1};
MomentumRefScalar[2] = {1,1,0};
MomentumRefScalar[3] = {1,1,1};
MomentumRefScalar[4] = {0,0,2};

MomentumRef[momentumpcm_] := MomentumRefScalar[Total[momentumpcm^2]];


MomentumTransform[momentumd_,  momentumpcm_, eulerG_] :=
	Inverse[MatrixRgtilde[MomentumRef[momentumpcm]]] .
		EulerMatrix[eulerG] .
		MatrixRgtilde[MomentumRef[momentumpcm]];


EulerGTilde[momentumpcm_] := 
	First @ Select[Values @ eulerAngles,
		momentumpcm == EulerMatrix[#] . MomentumRef[momentumpcm] &];

MatrixRGTilde = EulerMatrix @* eulerGTilde;


EndPackage[];
