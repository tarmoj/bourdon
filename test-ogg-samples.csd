; test loops of ogg files

<CsoundSynthesizer>
<CsOptions>
-odac
--env:SSDIR=/home/tarmo/tarmo/programm/bourdon/bourdon-app2/ogg/
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

giLoopPoints[][] init 20, 2

; definition of samples

giSound1 ftgen 1, 0, 0, 1, "G0.ogg", 0, 0, 1
giLoopPoints[1][0]=223926 
giLoopPoints[1][1]=596559


giSound2 ftgen 2, 0, 0, 1, "A0.ogg", 0, 0, 1
giLoopPoints[2][0]=438969 
giLoopPoints[2][1]=595254

giSound3 ftgen 3, 0, 0, 1, "c.ogg", 0, 0, 1
giLoopPoints[3][0]= 52279
giLoopPoints[3][1]= 145497


	giSound4 ftgen 4, 0, 0, 1, "d.ogg", 0, 0, 1
giLoopPoints[4][0]= 91488
giLoopPoints[4][1]= 921388


	giSound5 ftgen 5, 0, 0, 1, "e.ogg", 0, 0, 1
giLoopPoints[5][0] = 343606
giLoopPoints[5][1] = 739687
	
	giSound6 ftgen 6, 0, 0, 1, "f.ogg", 0, 0, 1 ; f
giLoopPoints[6][0] = 363949
giLoopPoints[6][1] = 1198777
	
	giSound7 ftgen 7, 0, 0, 1, "fis.ogg", 0, 0, 1 ; fis
giLoopPoints[7][0] = 788621
giLoopPoints[7][1] = 1485189	
	
	
	giSound8 ftgen 8, 0, 0, 1, "g.ogg", 0, 0, 1
giLoopPoints[8][0] = 191368
giLoopPoints[8][1] = 871622
	
	
	giSound9 ftgen 9, 0, 0, 1, "a.ogg", 0, 0, 1
giLoopPoints[9][0] = 352173
giLoopPoints[9][1] = 875722
	
	giSound10 ftgen 10, 0, 0, 1, "h.ogg", 0, 0, 1
giLoopPoints[10][0] = 764175
giLoopPoints[10][1] = 1059722	
	
	giSound11 ftgen 11, 0, 0, 1, "c1.ogg", 0, 0, 1
giLoopPoints[11][0] = 147145
giLoopPoints[11][1] = 285339	
	
	giSound12 ftgen 12, 0, 0, 1, "d1.ogg", 0, 0, 1
giLoopPoints[12][0] = 404900
giLoopPoints[12][1] =	606115
	
	giSound13 ftgen 13, 0, 0, 1, "e1.ogg", 0, 0, 1
giLoopPoints[13][0] = 113771
giLoopPoints[13][1] = 187850
	
	giSound14 ftgen 14, 0, 0, 1, "f1.ogg", 0, 0, 1 ; f
giLoopPoints[14][0] = 104999
giLoopPoints[14][1] = 156894 
	
	
	giSound15 ftgen 15, 0, 0, 1, "fis1.ogg", 0, 0, 1 ; fis
giLoopPoints[15][0] = 112656
giLoopPoints[15][1] = 161512 
	
	giSound16 ftgen 16, 0, 0, 1, "g1.ogg", 0, 0, 1
giLoopPoints[16][0] = 31416
giLoopPoints[16][1] = 95460	
	
	giSound17 ftgen 17, 0, 0, 1, "a1.ogg", 0, 0, 1
giLoopPoints[17][0] = 151807
giLoopPoints[17][1] = 943548

	giSound18 ftgen 18, 0, 0, 1, "h1.ogg", 0, 0, 1
giLoopPoints[18][0] = 198640
giLoopPoints[18][1] =	268507


instr 1
	iTable = p4
	if ftexists:i(iTable)>0 then
			aSound loscil3 0.5, 1, iTable, 1, 1, giLoopPoints[iTable][0], giLoopPoints[iTable][1]  
		else
			aSound = 0
		endif
		
		outall aSound*madsr(0.1, 0, 1, 0.1)

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
 <width>557</width>
 <height>226</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
