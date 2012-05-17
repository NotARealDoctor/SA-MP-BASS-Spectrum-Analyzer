/*
 *  Version: MPL 1.1
 *
 *  The contents of this file are subject to the Mozilla Public License Version
 *  1.1 (the "License"); you may not use this file except in compliance with
 *  the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 *
 *  Software distributed under the License is distributed on an "AS IS" basis,
 *  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 *  for the specific language governing rights and limitations under the
 *  License.
 *
 *  The Original Code is the SA:MP Spectrum Analyzer FFT Bar Proof of Concept
 *
 *  The Initial Developer of the Original Code is Scott Reed - h02@h02.org
 *  Portions created by the Initial Developer are Copyright (C) 2012
 *  the Initial Developer. All Rights Reserved.
 */

/* IMPORTANT NOTE: Use PlayAudioStreamForPlayer to send audio to clients, this script will only receive the audio stream to the server */

#include <a_samp>
#include <spectrum>

#define BARS 128
new objects[BARS], handle;
new timer;

public OnFilterScriptInit()
{
    //initialize the output device, receive the stream
    if(BASS_Init() && (handle=BASS_PlayStream("http://yp.shoutcast.com/sbin/tunein-station.pls?id=2206678")))
	{
		timer = SetTimer("Update", 25, true); //40hz timer to fetch the fft data

		for(new x;x<sizeof(objects);x++)
		{
		    //create the bar grid at pershing square (lspd)
			objects[x] = CreateObject(18647, 1488.0-(x*0.05), -1660.0, 12.6, 90.0, 0.0, 0.0);
		}
	}
	else printf("Spectrum: Init error %d", BASS_ErrorGetCode());
}

public OnFilterScriptExit()
{
    KillTimer(timer);
	for(new x;x<sizeof(objects);x++) DestroyObject(objects[x]);
	if(!BASS_Free()) printf("Spectrum: Free error %d", BASS_ErrorGetCode()); //frees all resources of the output device
}

forward Update();
public Update()
{
	new Float:fft[BARS];
	if(BASS_ChannelGetData(handle, fft, BASS_DATA_FFT256))
	{
	    for(new x;x<BARS;x++)
	    {
	        MoveObject(objects[x],1488.0-(x*0.05), -1660.0, 12.6+(fft[x]*5), 5.0, 90.0, 0.0, 0.0);
	    }
	}
	else printf("Spectrum: ChannelGetData error %d", BASS_ErrorGetCode());
}
