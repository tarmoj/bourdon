<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giPartials ftgen 1, 0, 64, -2, 1	,
2	,
3	,
4	,
5	,
6	,
7	,
8	,
9	,
10	,
11	,
12	,
13	,
14	,
15	,
16	,
17	,
19	,
21	,
23	,
25	,
26	,
27	,
28	,
29	,
30	,
31	,
32	,
33	,
34	,
35	,
36	,
37	,
38	,
39	,
42	,
43	,
44	,
45	,
49	,
50	,
51	,
52	,
53	,
54	,
55	,
56	,
57	,
76	,
78	,
79	





giAmps ftgen 2, 0, 64, -2, 0.4263	,
1	,
0.7491	,
0.4129	,
0.1433	,
0.527	,
0.165	,
0.0677	,
0.1643	,
0.1017	,
0.1505	,
0.0399	,
0.0243	,
0.0104	,
0.0243	,
0.0256	,
0.0462	,
0.0081	,
0.009	,
0.0062	,
0.0148	,
0.0147	,
0.0078	,
0.0116	,
0.0191	,
0.0105	,
0.0256	,
0.0283	,
0.0306	,
0.0353	,
0.0324	,
0.0463	,
0.0398	,
0.0177	,
0.0135	,
0.0105	,
0.0175	,
0.0186	,
0.0124	,
0.0116	,
0.0148	,
0.0152	,
0.0108	,
0.0122	,
0.0104	,
0.01	,
0.0111	,
0.0088	,
0.0088	,
0.0113	,
0.0099	



instr Play
	iamp ampmidi 0.3
	ifreq cpsmidi 
	
	

	ares *= iamp
	
	;ares adsynt iamp, ifreq, -1, 1, 2, 16
	
	aBuzz buzz 0.01*(1+jspline(0.2, 1/4, 1/2)), ifreq, 128, -1

	aOut = (ares+aBuzz)*madsr:a(0.2, 0, 1, 0.5)
	outall aOut


endin

; TODO: c, a
; a ei anna millegi pärast tulemust...
instr Analyze
	aDisk soundin "/home/tarmo/tarmo/programm/bourdon/bourdon-app2/samples/a.wav", 1
	out aDisk
	isiz = 2048
  ihsiz = isiz/4
	ffr,fphs  pvsifd   aDisk, isiz, ihsiz, 1
  ftrk      partials ffr, fphs, 0.01, 1, 1, 500
  part2txt "/home/tarmo/tarmo/programm/bourdon/bourdon-app2/samples/a.txt",ftrk
	
endin




 

</CsInstruments>
<CsScore>
;i "Analyze" 0 1 ; analyze and save to file






</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
