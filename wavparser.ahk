

hFile:=fileOpen("sample_sound.wav","r")

ft:=""
wavHeader:=new WAV_HEAD
fmtHeader:=new FMT_HEAD
dataHeader:=new DATA_HEAD

hFile.Pos := 8
wavHeader.ID:=hFile.Read(4)
if(wavHeader.ID!="WAVE"){
	MsgBox, NOT a WAVE FILE!!!
	ExitApp
}

ft.="WAV HEAD:" "`n"
ft.="ID:`t" wavHeader.ID "`n"

hFile.Pos += 4	; skip string 'fmt '
hFile.RawRead(_,4)
fmtHeader.chunksize:=NumGet(_,0,"Int")
hFile.RawRead(fmtHeader_raw,fmtHeader.chunksize)
fmtHeader.audiofmt:=NumGet(fmtHeader_raw, 0,"Short")
fmtHeader.numch:=NumGet(fmtHeader_raw, 2,"Short")
fmtHeader.samprate:=NumGet(fmtHeader_raw, 4,"Int")
fmtHeader.byterate:=NumGet(fmtHeader_raw, 8,"Int")
fmtHeader.blkalign:=NumGet(fmtHeader_raw, 12,"Short")
fmtHeader.bitspersamp:=NumGet(fmtHeader_raw, 14,"Short")

ft.="`nFMT HEAD:" "`n"
ft.="CHUNKSIZE:`t" fmtHeader.chunksize "`n"
ft.="AUDIOFMT:`t" fmtHeader.audiofmt "`n"
ft.="NUMCH:`t" fmtHeader.numch "`n"
ft.="SAMPRATE:`t" fmtHeader.samprate "`n"
ft.="BYTERATE:`t" fmtHeader.byterate "`n"
ft.="BLKALIGN:`t" fmtHeader.blkalign "`n"
ft.="BITSPERSAMP:`t" fmtHeader.bitspersamp "`n"

hFile.Pos+=4	; skip string 'data'
hFile.RawRead(dataHeader_raw,4)
dataHeader.chunksize:=NumGet(dataHeader_raw, 0,"Int")
ft.="`nDATA HEAD:" "`n"
ft.="CHUNKSIZE:`t" dataHeader.chunksize "`n"
MsgBox, % ft

MsgBox, Press OK to create txt log of wav file.
VarSetCapacity(wav_data,dataHeader.chunksize)
hFile.RawRead(wav_data,dataHeader.chunksize)

output:=""
Loop, % dataHeader.chunksize/fmtHeader.blkalign
{
	output.=NumGet(wav_data, (A_Index-1)*fmtHeader.blkalign,"Float") "`n"
	; MsgBox,
}
FileDelete, wavlog.log
FileAppend, % output, wavlog.log
MsgBox, Finished.
ExitApp

class WAV_HEAD
{
	static ID
}

class FMT_HEAD
{
	static chunksize	;16 for PCM
	static audiofmt		;PCM = 1
	static numch		;Mono = 1, Stereo = 2, etc.
	static samprate		;44100, 48000,etc.
	static byterate		;== SampleRate * NumChannels * BitsPerSample/8
	static blkalign		;== NumChannels * BitsPerSample/8
	static bitspersamp	;8 bits = 8, 16 bits = 16, etc.
}

class DATA_HEAD
{
	static chunksize	;== NumSamples * NumChannels * BitsPerSample/8
	static data			;The actual sound data.
}
