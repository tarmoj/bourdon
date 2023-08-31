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
chn_k "a4",3

chnset 440, "a4"


giSound1 ftgen 1, 0, 0, 1, "G.wav", 0, 0, 1
giSound2 ftgen 2, 0, 0, 1, "c.wav", 0, 0, 1
giSound3 ftgen 3, 0, 0, 1, "d.wav", 0, 0, 1
giSound4 ftgen 4, 0, 0, 1, "e.wav", 0, 0, 1
giSound5 ftgen 5, 0, 0, 1, "g.wav", 0, 0, 1
giSound6 ftgen 6, 0, 0, 1, "a.wav", 0, 0, 1
giSound7 ftgen 7, 0, 0, 1, "h.wav", 0, 0, 1
giSound8 ftgen 8, 0, 0, 1, "c1.wav", 0, 0, 1
giSound9 ftgen 9, 0, 0, 1, "d1.wav", 0, 0, 1
giSound10 ftgen 10, 0, 0, 1, "e1.wav", 0, 0, 1
giSound11 ftgen 11, 0, 0, 1, "g1.wav", 0, 0, 1
giSound12 ftgen 12, 0, 0, 1, "a1.wav", 0, 0, 1
giSound13 ftgen 13, 0, 0, 1, "h1.wav", 0, 0, 1

instr Bourdon
	iTable =  p4
	kSpeed init 1
	kA4 = chnget:k("a4")
	;printk2 kA4
	kSpeed = kA4/440
	;aSine poscil 0.1, kA4
	aSound loscil3 1, 1, iTable, 1 ; kõrguse muutmine Androidi peal ei toimi sel moel...
	iSize = 2048
	f1 pvsanal aSound, iSize, iSize/4, iSize, 1
	f2 pvscale f1, kSpeed
	aF pvsynth f2
	
	
	aEnv linenr 1, 0.1, 0.5, 0.01
	kVolume = 0.3 ; chnget   
	aOut = aF * aEnv * kVolume
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
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject type="BSBButton" version="2">
  <objectName>button0</objectName>
  <x>39</x>
  <y>153</y>
  <width>100</width>
  <height>30</height>
  <uuid>{3ce2d0f3-36df-488f-b101-4cfefd873757}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Bourdon1</text>
  <image>/</image>
  <eventLine>i1.1 0 -1 1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>148</x>
  <y>153</y>
  <width>100</width>
  <height>30</height>
  <uuid>{ee7a3e41-821e-4a31-9ce5-36f04aba9d63}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Bourdon2</text>
  <image>/</image>
  <eventLine>i 1.2 0 -1 12</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button3</objectName>
  <x>254</x>
  <y>153</y>
  <width>100</width>
  <height>30</height>
  <uuid>{8e415786-a8b0-47d2-87f4-7f2035cfe85a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Bourdon2</text>
  <image>/</image>
  <eventLine>i 1.3 0 -1 3</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>a4</objectName>
  <x>67</x>
  <y>83</y>
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
  <value>445</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
