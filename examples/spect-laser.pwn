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
 *  The Original Code is the SA:MP Spectrum Analyzer FFT Laser Proof of Concept.
 *
 *  The Initial Developer of the Original Code is Scott Reed - h02@h02.org
 *  Portions created by the Initial Developer are Copyright (C) 2012
 *  the Initial Developer. All Rights Reserved.
 *
 *  Contributor(s):
 *
 *  Un4seen Developments Ltd., Copyright (c) 1999-2011
 */

/* IMPORTANT NOTE: Use PlayAudioStreamForPlayer to send audio to clients, this script will only receive the audio stream to the server */

#include <a_samp>
#include <spectrum>

new objects[28];
new timer;

public OnFilterScriptInit()
{
	//initialize the output device, receive the stream
	if(BASS_Init() && BASS_PlayStream("http://yp.shoutcast.com/sbin/tunein-station.pls?id=860870"))
	{
		timer = SetTimer("Update", 25, true); //40hz timer to fetch the fft data
        //create the laser array at pershing square (lspd)
		for(new x;x<sizeof(objects);x++) objects[x] = CreateObject(18643, 1529.0,-1635.0+(x*0.1),13.0,0.0,0.0,0.0);
	}
	else printf("Spectrum: Init error %d", BASS_ErrorGetCode());
}

public OnFilterScriptExit()
{
	KillTimer(timer);
	for(new x;x<sizeof(objects);x++) DestroyObject(objects[x]);
	//frees all resources of the output device
	if(!BASS_Free()) printf("Spectrum: Free error %d", BASS_ErrorGetCode());
}

forward Update();
public Update()
{
	new Float:fft[128];
	if(BASS_ChannelGetData(fft, BASS_DATA_FFT256))
	{
		new b0;
		for(new x;x<sizeof(objects);x++)
		{
			new Float:peak, Float:y;
			new b1 = 2^(x*10/(sizeof(objects)-1));
			if (b1>1023) b1=1023;
			if (b1<=0) b1=b0+1; // make sure it uses at least 1 FFT bin
			for (;b0<b1;b0++)
			{
				if (peak<fft[1+b0]) peak=fft[1+b0];
			}
			y=floatsqroot(peak)*3*127; // scale it (sqrt to make low values more visible)
			if (y>90) y=90; // cap it
			SetObjectRot(objects[x], 0.0, y-180, 0.0);
		}
	}
	else printf("Spectrum: ChannelGetData error %d", BASS_ErrorGetCode());
}
