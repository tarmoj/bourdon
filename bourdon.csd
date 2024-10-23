<CsoundSynthesizer>
<CsOptions>
-odac 
; -d
; -b 256 -B 1024 ; et äkki see mõjutab Androidi, aga vist mitte....; --env:SSDIR=/home/tarmo/tarmo/programm/qt-projects/bourdon/samples/
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

;;channels
chn_k "type",3
chn_k "sawtooth",3
chn_k "a4",3

chnset 440, "a4"
chnset 2, "type"

giFrequencies[] array 100, cpspch(6.07), cpspch(6.09),
 cpspch(7.00), cpspch(7.02), cpspch(7.04), cpspch(7.05), cpspch(7.06), cpspch(7.07), cpspch(7.09),cpspch(7.11),
 cpspch(8.00), cpspch(8.02), cpspch(8.04), cpspch(8.05), cpspch(8.06), cpspch(8.07), cpspch(8.09), cpspch(8.11)


giPartials1 ftgen 101, 0, 64, -2, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60

giAmps1 ftgen 201, 0, 64, -2, 0.4263,
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
0.0256 ,
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
0.0324,
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
		




instr Bourdon
	iTable =  p4
	kSpeed init 1
	kA4 = chnget:k("a4")
	;printk2 kA4
	kScale = kA4/440

	kType chnget "type"
	; võibolla vaja iType 
	print 
	
	if (kType==1) then
		iamp = 0.3
		kFreq = giFrequencies[iTable]*kScale
		aSaw vco2 iamp, kFreq ;, 10
		aSaw butterlp aSaw, 6000
	  
	  aOut = aSaw

	elseif (kType==2) then ; synthesized sound
		iamp = 0.3
		kFreq = giFrequencies[iTable]*kScale
		
		aWave adsynt iamp, kFreq, -1, giPartials1 , giAmps1 , 64
		aBuzz buzz 0.1*(1+jspline(0.1, 1/4, 1/2)), kFreq, 256, -1
		aOut = aWave+aBuzz
		aOut butterlp aOut, 8000
	
	elseif (kType==0) then
		if ftexists:i(iTable)>0 then
			aSound loscil3 1, 1, iTable, 1 ; kõrguse muutmine Androidi peal ei toimi sel moel...
		else
			aSound = 0
		endif
		
		iSize = 2048
	
		if (kA4==440) then
		
			aOut = aSound
		else 
			f1 pvsanal aSound, iSize, iSize/4, iSize, 1
			f2 pvscale f1, kScale
			aF pvsynth f2
			aOut = aF
		endif	
	endif 
	
	;dispfft aOut, 0.1, 2048
		
	
	
  aEnv linenr 1, 0.1, 0.5, 0.001; midagi on siin valesti...
	kVolume = 0.3 ; chnget   
	aOut *= aEnv * kVolume
	outall aOut 	
endin


; make sure, it can be optional!
schedule "LoadSamples", 0, 0
instr LoadSamples

;if fileexists("G0.wav")== 1 then
	giSound1 ftgen 1, 0, 0, 1, "G0.wav", 0, 0, 1
	giSound2 ftgen 2, 0, 0, 1, "A0.wav", 0, 0, 1
	giSound3 ftgen 3, 0, 0, 1, "c.wav", 0, 0, 1
	giSound4 ftgen 4, 0, 0, 1, "d.wav", 0, 0, 1
	giSound5 ftgen 5, 0, 0, 1, "e.wav", 0, 0, 1
	giSound6 ftgen 6, 0, 0, 1, "e.wav", 0, 0, 1 ; f
	giSound7 ftgen 7, 0, 0, 1, "e.wav", 0, 0, 1 ; fis
	
	giSound8 ftgen 8, 0, 0, 1, "g.wav", 0, 0, 1
	giSound9 ftgen 9, 0, 0, 1, "a.wav", 0, 0, 1
	giSound10 ftgen 10, 0, 0, 1, "h.wav", 0, 0, 1
	
	giSound11 ftgen 11, 0, 0, 1, "c1.wav", 0, 0, 1
	giSound12 ftgen 12, 0, 0, 1, "d1.wav", 0, 0, 1
	giSound13 ftgen 13, 0, 0, 1, "e1.wav", 0, 0, 1
	giSound14 ftgen 14, 0, 0, 1, "e1.wav", 0, 0, 1 ; f
	giSound15 ftgen 15, 0, 0, 1, "e1.wav", 0, 0, 1 ; fis
	
	giSound16 ftgen 16, 0, 0, 1, "g1.wav", 0, 0, 1
	giSound17 ftgen 17, 0, 0, 1, "a1.wav", 0, 0, 1
	giSound18 ftgen 18, 0, 0, 1, "h1.wav", 0, 0, 1
;else
;	prints "File G0.wav not found\n";	
;endif

endin

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>
























<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>1034</width>
 <height>649</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>221</r>
  <g>237</g>
  <b>240</b>
 </bgcolor>
 <bsbObject version="2" type="BSBButton">
  <objectName>button0</objectName>
  <x>360</x>
  <y>97</y>
  <width>61</width>
  <height>37</height>
  <uuid>{3ce2d0f3-36df-488f-b101-4cfefd873757}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>G</text>
  <image>/</image>
  <eventLine>i1.1 0 -1 1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>a4</objectName>
  <x>101</x>
  <y>46</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5b59b0f0-48bc-43ee-805e-a4b34dd30657}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>430</minimum>
  <maximum>450</maximum>
  <randomizable group="0">false</randomizable>
  <value>440</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>16</x>
  <y>46</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3aedea64-30e8-4da0-93ce-e12c4f8af6be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Häälestus</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonA</objectName>
  <x>425</x>
  <y>97</y>
  <width>61</width>
  <height>37</height>
  <uuid>{2e247fa7-31f2-412d-98e5-43c03f843435}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>A</text>
  <image>/</image>
  <eventLine>i1.2 0 -1 2</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonc</objectName>
  <x>25</x>
  <y>143</y>
  <width>61</width>
  <height>37</height>
  <uuid>{a4f0d911-f126-4d61-9029-9bfcfdb447f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>c</text>
  <image>/</image>
  <eventLine>i1.3 0 -1 3</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttond</objectName>
  <x>92</x>
  <y>143</y>
  <width>61</width>
  <height>37</height>
  <uuid>{93f9c60e-d503-4651-a8cc-bdbf4ed8d71b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>d</text>
  <image>/</image>
  <eventLine>i1.4 0 -1 4</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttone</objectName>
  <x>159</x>
  <y>143</y>
  <width>61</width>
  <height>37</height>
  <uuid>{f02ea950-dd89-4243-a099-934272e8a4ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>e</text>
  <image>/</image>
  <eventLine>i1.5 0 -1 5</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttong</objectName>
  <x>359</x>
  <y>142</y>
  <width>61</width>
  <height>37</height>
  <uuid>{edc1484a-cf11-456e-8359-7c5ada6037dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>g</text>
  <image>/</image>
  <eventLine>i1.8 0 -1 8</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttona</objectName>
  <x>427</x>
  <y>142</y>
  <width>61</width>
  <height>37</height>
  <uuid>{d0bd6d25-6ac0-4a51-8b15-c8afa5cd5c4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>a</text>
  <image>/</image>
  <eventLine>i1.9 0 -1 9</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonh</objectName>
  <x>495</x>
  <y>142</y>
  <width>61</width>
  <height>37</height>
  <uuid>{c4f06a9f-8511-4d94-aa5d-d991864b2d98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>h</text>
  <image>/</image>
  <eventLine>i1.010 0 -1 10</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonc1</objectName>
  <x>26</x>
  <y>189</y>
  <width>61</width>
  <height>37</height>
  <uuid>{44cb314e-4ca4-4a7c-b349-aff3c35e6338}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>c1</text>
  <image>/</image>
  <eventLine>i1.11 0 -1 11</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttond1</objectName>
  <x>93</x>
  <y>189</y>
  <width>61</width>
  <height>37</height>
  <uuid>{a2867a58-81be-43ed-ae74-c4019a247290}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>d1</text>
  <image>/</image>
  <eventLine>i1.12 0 -1 12</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttone1</objectName>
  <x>160</x>
  <y>189</y>
  <width>61</width>
  <height>37</height>
  <uuid>{3169fcf9-3de6-44af-b2f7-55f88a7a5e3e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>e1</text>
  <image>/</image>
  <eventLine>i1.13 0 -1 13</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttong1</objectName>
  <x>360</x>
  <y>188</y>
  <width>61</width>
  <height>37</height>
  <uuid>{ad96df30-304f-4209-acbe-b2775bc5ea50}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>g1</text>
  <image>/</image>
  <eventLine>i1.16 0 -1 16</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttona1</objectName>
  <x>428</x>
  <y>188</y>
  <width>61</width>
  <height>37</height>
  <uuid>{ee447150-028a-4310-82e7-1024597f9887}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>a1</text>
  <image>/</image>
  <eventLine>i1.17 0 -1 17</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonh1</objectName>
  <x>496</x>
  <y>188</y>
  <width>61</width>
  <height>37</height>
  <uuid>{080f7f24-1545-4acf-9201-4e868f222992}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>h1</text>
  <image>/</image>
  <eventLine>i1.18 0 -1 18</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName/>
  <x>23</x>
  <y>314</y>
  <width>1011</width>
  <height>335</height>
  <uuid>{396deab4-9066-4e20-b52e-abad46a8d7f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>20</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>true</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>true</showScrollbars>
  <enableTables>true</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>type</objectName>
  <x>181</x>
  <y>269</y>
  <width>80</width>
  <height>30</height>
  <uuid>{3ecddafa-45ff-4a50-a912-220ee809b0f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>sample</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>saw</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>additive</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonf</objectName>
  <x>225</x>
  <y>142</y>
  <width>61</width>
  <height>37</height>
  <uuid>{bf0f5929-1af0-412f-b1bc-9b234e3c57f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>f</text>
  <image>/</image>
  <eventLine>i1.6 0 -1 6</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonf1</objectName>
  <x>226</x>
  <y>188</y>
  <width>61</width>
  <height>37</height>
  <uuid>{eaab4256-6b70-4af6-9a44-fc679c924e97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>f1</text>
  <image>/</image>
  <eventLine>i1.14 0 -1 14</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonfis</objectName>
  <x>292</x>
  <y>142</y>
  <width>61</width>
  <height>37</height>
  <uuid>{85c4e24b-d6c6-46c6-84ea-ec64050c4224}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>fis</text>
  <image>/</image>
  <eventLine>i1.7 0 -1 7</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonfis1</objectName>
  <x>293</x>
  <y>188</y>
  <width>61</width>
  <height>37</height>
  <uuid>{15a472ea-9c38-4130-b2cc-950b652c930d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>fis1</text>
  <image>/</image>
  <eventLine>i1.15 0 -1 15</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>tuning</objectName>
  <x>32</x>
  <y>268</y>
  <width>106</width>
  <height>30</height>
  <uuid>{5d74b23c-4048-4ee1-8c17-a4ac453557a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Equal temp</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Nat. G</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Nat. D</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
