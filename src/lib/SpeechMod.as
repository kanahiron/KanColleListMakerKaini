#module SpeechMod

#deffunc local init
    available = 0
    newcom spv, "Sapi.SpVoice"
    if (varuse(spv)==0): return -1
    available = 1
    volume = 100
    speed = 0
    pitch = 0
return 0

#define SetVolume(%1=100) SetVolume_@SpeechMod %1
#deffunc local SetVolume_ int p1 
    if ( (p1<0) or (100<p1) ): return -1
    volume = p1
return 0

#define SetSpeed(%1=0) SetSpeed_@SpeechMod %1
#deffunc local SetSpeed_ int p1 
    if ( (p1<-10) or (10<p1) ): return -1
    speed = p1
return 0

#define SetPitch(%1=0) SetPitch_@SpeechMod %1
#deffunc local SetPitch_ int p1 
    if ( (p1<-10) or (10<p1) ): return -1
    pitch = p1
return 0

#deffunc local Speak str p1, local cmd
    if (available==0): return -1

    sdim cmd
    cmd = strf("<volume level='%d'><rate speed='%d'><pitch middle='%d'>", volume, speed, pitch)
    cmd += p1
    cmd += strf("</volume></rate></pitch>")
    logmes cmd
    spv->"Speak" cmd,1

return 0

#global
init@SpeechMod

//Sample
#if 0 

#include "hsp3utf.as"
#include "WrapCall.as"

    //そのまま喋らす
    Speak@SpeechMod "こんにちは"

    SetVolume@SpeechMod 10
    Speak@SpeechMod "かなり声を抑えました"

    SetVolume@SpeechMod 50
    SetSpeed@SpeechMod 3
    Speak@SpeechMod "早口"

    SetSpeed@SpeechMod
    SetPitch@SpeechMod -6
    Speak@SpeechMod "声を低く"

    SetPitch@SpeechMod 9
    Speak@SpeechMod "声を高く"

#endif