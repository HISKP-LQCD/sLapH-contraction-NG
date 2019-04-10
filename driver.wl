Get["../qct/qct.m"]
<< sLapHProjection`

totalMomentum = ToExpression @ $ScriptCommandLine[[2]]
irrep = $ScriptCommandLine[[3]]

wc = WickContract[\[Pi]\[Pi]I1Bar[s1, s2, s3, s4, c1, c2, so[1], so[2]] **
  \[Pi]\[Pi]I1[s5, s6, s7, s8, c5, c6, si[1], si[2]]];
qc = QuarkContract[wc];

replaced = ReplacePropagators @ qc;

normalized = NormalizeTraceRecursive @ replaced;

normalized
normalizedFlavor = normalized /. FlavorSwitchRules[];
normalizedFlavorFlow = normalizedFlavor /. FlowReversalRules[];
normalizedFlow = normalized /. FlowReversalRules[];
templates = normalizedFlavorFlow /. DatasetNameRules[]

utm1 = UniqueTotalMomenta /@ Range[0, 1];
utm1Flat = Flatten[utm1, 1]
utm2 = UniqueTotalMomenta /@ Range[0, 4]
utm2Flat = Flatten[utm2, 1]

relMomenta = {#} & /@ utm2Flat;

filename = "gevp-rho-" <> MomentumToString[totalMomentum] <> "-" <> irrep <> ".js";
Print @ filename

timing1 = AbsoluteTiming[some = StructureButSingle[totalMomentum, irrep, relMomenta, 1]][[1]]
Print[timing1]
timing2 = AbsoluteTiming[MomentaAndTemplatesToJSONFile[some, templates, filename]][[1]];
Print[timing2]