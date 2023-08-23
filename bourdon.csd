<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1


giSound1 ftgen 1, 0, 0, 1, "G.wav", 0, 0, 1
giSound2 ftgen 2, 0, 0, 1, "d.wav", 0, 0, 1
giSound3 ftgen 3, 0, 0, 1, "e.wav", 0, 0, 1



instr Bourdon
	iTable =  p4
	aSound loscil3 1, 1, iTable, 1
	aEnv linenr 1, 0.1, 0.5, 0.01
	kVolume = 0.3 ; chnget   
	aOut = aSound * aEnv * kVolume
	outall aOut 	
endin

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject version="2" type="BSBButton">
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
 <bsbObject version="2" type="BSBButton">
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
  <eventLine>i 1.2 0 -1 2</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
