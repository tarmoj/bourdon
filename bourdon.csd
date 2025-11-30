<CsoundSynthesizer>
<CsOptions>
-odac 
; -d
; -b 256 -B 1024 ; et äkki see mõjutab Androidi, aga vist mitte....;; 
; --env:SSDIR=/home/tarmo/tarmo/programm/bourdon/bourdon-app2/ogg/
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

;;channels
chn_k "tuning",3
chn_k "type",3
chn_k "sawtooth",3
chn_k "a4",3
chn_k "volumeCorrection", 3
; volume0, volume1 etc for volumes of bourdon notes in dB


chnset 440, "a4"
chnset 1, "type"
chnset 0, "volumeCorrection"
chnset 1, "timbre" ; square by defult


; indexes of the notes in giFrequencies[] and giRatiosX[] arrays
#define G #0#
#define d #3#
#define A #1#
#define c #2#
#define e #4#

#define SAW #0#
#define SYNTH #1#
#define CUSTOM #2#

#define IN #0#
#define OUT #1#

gkFade init 1

giFrequencies[] fillarray cpspch(6.07), cpspch(6.09),
 cpspch(7.00), cpspch(7.02), cpspch(7.04), cpspch(7.05), cpspch(7.06), cpspch(7.07), cpspch(7.09),cpspch(7.11),
 cpspch(8.00), cpspch(8.02), cpspch(8.04), cpspch(8.05), cpspch(8.06), cpspch(8.07), cpspch(8.09), cpspch(8.11)


giRatiosG[] fillarray 1, 9/8,    
4/3, 3/2, 5/3, 7/4, 15/8, 2,  9/4, 5/2,
8/3, 3, 10/3, 7/2, 15/4, 4,  9/2, 5

giRatiosD[] fillarray 2/3, 3/4,    
8/9, 1, 9/8, 6/5, 5/4, 4/3, 3/2,  5/3,
16/9, 2, 9/4, 12/5, 5/2, 8/3, 3,  10/3

giRatiosA[] fillarray 9/10, 1,    
6/5, 4/3, 3/2, 8/5, 5/3, 9/5,  2, 9/4,
12/5, 8/3, 3, 16/5, 10/3, 18/5, 4,  9/2

giRatiosC[] fillarray 3/4, 5/6,    
1, 9/8, 5/4, 4/3, 729/512, 3/2,  5/3, 15/8,
2, 9/4, 5/2, 8/3, 729/256, 3, 10/3,  15/4

giRatiosC[] fillarray 3/4, 5/6,    
1, 9/8, 5/4, 4/3, 729/512, 3/2,  5/3, 15/8,
2, 9/4, 5/2, 8/3, 729/256, 3, 10/3,  15/4

giRatiosE[] fillarray 3/5, 2/3, 4/5, 9/10, 1/1, 16/15, 9/8, 6/5, 4/3, 3/2, 8/5, 9/5, 2/1, 32/15, 9/4, 12/5, 8/3, 3/1


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


;test
; scoreline_i "i 1.1 0 -1 1"
; chnset -24, "volume0"



opcode getFrequency,k, i; in args: base note by index in giFrequencies (negative, if equal temperament), note index, A4
	iNoteIndex xin
	kFrequency init 0
	
	print iNoteIndex
	
	kA4 chnget "a4"
	
	kTuning chnget "tuning"
	;printk2 kTuning
	if kTuning==1 then
		kBaseFrequency = giFrequencies[$G]
		kRatio = giRatiosG[iNoteIndex]
	elseif kTuning==2 then
		kBaseFrequency = giFrequencies[$d]
		kRatio = giRatiosD[iNoteIndex]
	elseif kTuning==3 then
		kBaseFrequency = giFrequencies[$A]
		kRatio = giRatiosA[iNoteIndex]
  elseif kTuning==4 then
		kBaseFrequency = giFrequencies[$c]
		kRatio = giRatiosC[iNoteIndex]
	elseif kTuning==5 then
		kBaseFrequency = giFrequencies[$e]
		kRatio = giRatiosE[iNoteIndex]
	elseif kTuning==6 then
		; surprise!!	
	  ; add random deviation below	
	else 
		kTuning = 0 ; reset to equal temperament			
	endif
	
	;printk2 kBaseFrequency
	;printk2 kRatio
		
	if (kTuning==0) then ; equal temperament
		kFrequency = giFrequencies[iNoteIndex]
	elseif kTuning==6 then ; surprize tuning -  out of tune
		kFrequency = giFrequencies[iNoteIndex]* cent(random(-33, 33))
	else   
		kFrequency = kBaseFrequency * kRatio      
	endif
	kScale = kA4/440 
	xout kFrequency*kScale

endop 


instr Bourdon
	iTable =  p4
	iNoteIndex = iTable-1
	
	kType chnget "type"
	
	kFreq getFrequency iNoteIndex
	
	if (kType==$SAW) then ; saw wave
   kamp = 0.2
		aSaw vco2 kamp, kFreq ;, 10
		if (kType==1) then ; donät filter for Saw 2
			aSaw butterlp aSaw, 4000	  
		endif
	  aOut = aSaw	
	elseif (kType==$CUSTOM) then	
		kTimbre port chnget:k("timbre"), 0.02, chnget:i("timbre")
		kamp = 0.4
		; Clip . squareness; Skew - symmetry (1=saw)
		; timbre: 0 -  sine, 0.5 -  saw, 1 -  square
		if kTimbre<=0.5 then 
		  
			kClip = 0
			kSkew = kTimbre * 2
		elseif kTimbre>0.5 && kTimbre<=1.0 then
			kClip = (kTimbre-0.5) * 2
			kSkew = 1-kClip
		else 
			kClip = 0
			kSkew = 0
		endif
	  aOut squinewave a(kFreq), a(kClip), a(kSkew) 
	  aOut *= kamp
	  
	  
	else ; default is synthesized sound, type 1
		kamp = 0.2
		
		aWave adsynt kamp, kFreq, -1, giPartials1 , giAmps1 , 64
		aBuzz buzz 0.1*(1+jspline(0.1, 1/4, 1/2)), kFreq, 256, -1
		aOut = aWave+aBuzz
		aOut butterlp aOut, 8000
	endif 
	
	;dispfft aOut, 0.1, 2048
	
	iFade = 0.1
		
	;aEnv linenr 1, iFade, iFade, 0.01
	aEnv madsr iFade, 0, 1, iFade
  kBourdonVolume chnget sprintf("volume%d", iNoteIndex) 
  kPan chnget sprintf("pan%d", iNoteIndex) // comes in in scale -1...1, 0 gives center
  kPan = kPan/2 + 0.5 
	kVolume = 0.2 * ampdbfs(chnget:k("volumeCorrection")) *
		ampdbfs(kBourdonVolume)
	kVolume port kVolume, 0.01  
	aOut *= aEnv * kVolume *gkFade ; 
	aL, aR pan2 aOut, kPan
	out aL, aR	
endin



; schedule "Reset", 0, 0
instr Reset ; set volumeCorrection and individual volumes to 0 (dB)
	chnset 0, "volumeCorrection"
	index = 0
label:
	chnset 0, sprintf("volume%d", index)
	loop_lt index, 1, lenarray(giFrequencies), label 
endin



instr SlowFade
	iInOut = p4	
	print p3, iInOut
	if iInOut==$IN then
		gkFade line 0, p3, 1
	else
		gkFade line 1, p3, 0
  endif  	
endin

instr RestoreFadeLevel
	gkFade init 1
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
 <bsbObject type="BSBButton" version="2">
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
  <eventLine>i1.1 0 -1 1 1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
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
  <bgcolor mode="background">
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
 <bsbObject type="BSBLabel" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBGraph" version="2">
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
  <value>0</value>
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
 <bsbObject type="BSBDropdown" version="2">
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
    <name>---</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>saw</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>synthesized</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> squine</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBButton" version="2">
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
 <bsbObject type="BSBDropdown" version="2">
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
   <bsbDropdownItem>
    <name> Nat. A</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Nat. C</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Nat. E</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Surprize</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>6</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>timbre</objectName>
  <x>204</x>
  <y>26</y>
  <width>59</width>
  <height>80</height>
  <uuid>{35897466-0742-416a-8322-157e87dd9b0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#ff8921</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>185</x>
  <y>107</y>
  <width>112</width>
  <height>23</height>
  <uuid>{98afd6ec-4fcb-4734-9725-4f02aeeb63b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Siinus-Saag-Nelinurk</label>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>button25</objectName>
  <x>305</x>
  <y>267</y>
  <width>100</width>
  <height>30</height>
  <uuid>{7c353fdc-5024-4013-9732-0936e8bd12e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Test IN</text>
  <image>/</image>
  <eventLine>i "SlowFade" 0 2 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button26</objectName>
  <x>413</x>
  <y>268</y>
  <width>100</width>
  <height>30</height>
  <uuid>{e487701d-bae7-4cf0-add4-ac2c31e23366}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Test OUT</text>
  <image>/</image>
  <eventLine>i "SlowFade" 0 2 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
