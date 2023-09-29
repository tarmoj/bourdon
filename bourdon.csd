<CsoundSynthesizer>
<CsOptions>
-odac -d
; -b 256 -B 1024 ; et äkki see mõjutab Androidi, aga vist mitte....
; --env:SSDIR=/home/tarmo/tarmo/programm/bourdon/bourdon-app2/samples/
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

;;channels
chn_k "sawtooth",3
chn_k "a4",3

chnset 440, "a4"

giFrequencies[] array 100, cpspch(6.07), cpspch(6.09),
 cpspch(7.00), cpspch(7.02), cpspch(7.04), cpspch(7.07), cpspch(7.09),cpspch(7.11),
 cpspch(8.00), cpspch(8.02), cpspch(8.04), cpspch(8.07), cpspch(8.09), cpspch(8.11)

giSound1 ftgen 1, 0, 0, 1, "G0.wav", 0, 0, 1
giSound2 ftgen 2, 0, 0, 1, "A0.wav", 0, 0, 1
giSound3 ftgen 3, 0, 0, 1, "c.wav", 0, 0, 1
giSound4 ftgen 4, 0, 0, 1, "d.wav", 0, 0, 1
giSound5 ftgen 5, 0, 0, 1, "e.wav", 0, 0, 1
giSound6 ftgen 6, 0, 0, 1, "g.wav", 0, 0, 1
giSound7 ftgen 7, 0, 0, 1, "a.wav", 0, 0, 1
giSound8 ftgen 8, 0, 0, 1, "h.wav", 0, 0, 1
giSound9 ftgen 9, 0, 0, 1, "c1.wav", 0, 0, 1
giSound10 ftgen 10, 0, 0, 1, "d1.wav", 0, 0, 1
giSound11 ftgen 11, 0, 0, 1, "e1.wav", 0, 0, 1
giSound12 ftgen 12, 0, 0, 1, "g1.wav", 0, 0, 1
giSound13 ftgen 13, 0, 0, 1, "a1.wav", 0, 0, 1
giSound14 ftgen 14, 0, 0, 1, "h1.wav", 0, 0, 1

instr Bourdon
	iTable =  p4
	kSpeed init 1
	kA4 = chnget:k("a4")
	;printk2 kA4
	kScale = kA4/440
	
	if (chnget:k("sawtooth")>0) then
		iamp = 0.4
		aSaw vco2 0.4, giFrequencies[iTable]*kScale
		aOut butterlp aSaw, 6000
		;aOut = aSaw
	else
		aSound loscil3 1, 1, iTable, 1 ; kõrguse muutmine Androidi peal ei toimi sel moel...
	
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
	
	;aSine poscil 0.1, kA4
	
	
	aEnv linenr 1, 0.1, 0.5, 0.01
	kVolume = 0.3 ; chnget   
	aOut *= aEnv * kVolume
	outall aOut 	
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
 <width>354</width>
 <height>183</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>221</r>
  <g>237</g>
  <b>240</b>
 </bgcolor>
 <bsbObject version="2" type="BSBButton">
  <objectName>button0</objectName>
  <x>23</x>
  <y>96</y>
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
  <x>88</x>
  <y>96</y>
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
  <x>227</x>
  <y>143</y>
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
  <eventLine>i1.6 0 -1 6</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttona</objectName>
  <x>295</x>
  <y>143</y>
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
  <eventLine>i1.7 0 -1 7</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonh</objectName>
  <x>363</x>
  <y>143</y>
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
  <eventLine>i1.8 0 -1 8</eventLine>
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
  <eventLine>i1.9 0 -1 9</eventLine>
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
  <eventLine>i1.101 0 -1 10</eventLine>
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
  <eventLine>i1.11 0 -1 11</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttong1</objectName>
  <x>228</x>
  <y>189</y>
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
  <eventLine>i1.12 0 -1 12</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttona1</objectName>
  <x>296</x>
  <y>189</y>
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
  <eventLine>i1.13 0 -1 13</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>buttonh1</objectName>
  <x>364</x>
  <y>189</y>
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
  <eventLine>i1.14 0 -1 14</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>sawtooth</objectName>
  <x>118</x>
  <y>271</y>
  <width>20</width>
  <height>20</height>
  <uuid>{a26b7471-4fcd-4732-bb73-b0bcbbd23d49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>270</y>
  <width>86</width>
  <height>28</height>
  <uuid>{07b07c14-1435-45c6-be67-e3815493d5fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Use saw wave:</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
