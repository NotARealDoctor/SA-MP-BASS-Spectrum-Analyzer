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
 *  The Original Code is the SA:MP Spectrum Analyzer Bar Level Proof of Concept
 *
 *  The Initial Developer of the Original Code is Scott Reed - h02@h02.org
 *  Portions created by the Initial Developer are Copyright (C) 2012
 *  the Initial Developer. All Rights Reserved.
 */

/* IMPORTANT NOTE: Use PlayAudioStreamForPlayer to send audio to clients, this script will only receive the audio stream to the server */

#include <a_samp>
#include <spectrum>

new obj[2];
new timer;

public OnFilterScriptInit()
{
    //initialize the output device, receive the stream
    if(BASS_Init() && BASS_PlayStream("http://yp.shoutcast.com/sbin/tunein-station.pls?id=7225"))
	{
		timer = SetTimer("Update", 25, true); //40hz timer to fetch the fft data

		obj[0] = CreateObject(18647, 1488.0, -1660.0, 12.6, 90.0, 0.0, 0.0);
		obj[1] = CreateObject(18647, 1487.5, -1660.0, 12.6, 90.0, 0.0, 0.0);
	}
	else printf("Spectrum: Init error %d", BASS_ErrorGetCode());
}

public OnFilterScriptExit()
{
    KillTimer(timer);
	DestroyObject(obj[0]);
	DestroyObject(obj[1]);
	//frees all resources of the output device
	if(!BASS_Free()) printf("Spectrum: Free error %d", BASS_ErrorGetCode());
}

forward Update();
public Update()
{
	new left, right;
	if(BASS_ChannelGetLevel(left, right))
	{
	    MoveObject(obj[0], 1488.0, -1660.0, 12.6+(left*0.0001), 5.0, 90.0, 0.0, 0.0);
	    MoveObject(obj[1], 1487.5, -1660.0, 12.6+(right*0.0001), 5.0, 90.0, 0.0, 0.0);
	}
	else printf("Spectrum: ChannelGetLevel error %d", BASS_ErrorGetCode());
}
