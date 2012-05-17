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
 *  The Original Code is the SA:MP FFT Particle Visualizer
 *
 *  The Initial Developer of the Original Code is Scott Reed - h02@h02.org
 *  Portions created by the Initial Developer are Copyright (C) 2012
 *  the Initial Developer. All Rights Reserved.
 */

/* IMPORTANT NOTE: Use PlayAudioStreamForPlayer to send audio to clients, this script will only receive the audio stream to the server */

#include <a_samp>
#include <spectrum>

#define FTYPE_WHITE  	0
#define FTYPE_RED    	1
#define FTYPE_GREEN  	2
#define FTYPE_BLUE   	3

#define FWHITE    		19281
#define FRED    		19282
#define FGREEN    		19283
#define FBLUE   		19284

#define FWHITE_HUGE    	19295
#define FRED_HUGE   	19296
#define FGREEN_HUGE    	19297
#define FBLUE_HUGE   	19298

#define BARS 128

new objects[BARS], Float:fftvalue[BARS], handle, timer;

public OnFilterScriptInit()
{
    //initialize the output device, receive the stream
    if(BASS_Init() && (handle=BASS_PlayStream("http://yp.shoutcast.com/sbin/tunein-station.pls?id=502985")))
 	{
		timer = SetTimer("Update", 25, true); //40hz timer to fetch the fft data
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
	        if((fft[x]-fftvalue[x] > 0.1))
			{
			    if(!objects[x])
			    {
				    new left, right;
				    if(BASS_ChannelGetLevel(handle, left, right))
				    {
					    printf("Beat detected at %d - %f, %d %d", x, fft[x]-fftvalue[x], left, right);
					    
					    new object;
						if(x < 5) object = FTYPE_WHITE;
						else if(x >= 5 && x < 15) object = FTYPE_RED;
						else if(x >= 15 && x < 25) object = FTYPE_GREEN;
						else if(x >= 25) object = FTYPE_BLUE;

						if(left > 80 || right > 80)
						{
						    switch(object)
						    {
						        case FTYPE_WHITE: object = FRED_HUGE;
						        case FTYPE_RED: object = FGREEN_HUGE;
						        case FTYPE_GREEN: object = FBLUE_HUGE;
						        case FTYPE_BLUE: object = FWHITE_HUGE;
							}
						}
						else
						{
						    switch(object)
						    {
						        case FTYPE_WHITE: object = FRED;
						        case FTYPE_RED: object = FGREEN;
						        case FTYPE_GREEN: object = FBLUE;
						        case FTYPE_BLUE: object = FWHITE;
							}
						}

						objects[x] = CreateObject(object, 1479.0, -1641.0, 14.0, 0.0, 0.0, 0.0);
      					switch(random(2))
						{
							case 0: MoveObject(objects[x], 1479.0+((random(1))+fft[x]*20), -1641.0+((random(1))+fft[x]*30), 14.0+(left*0.15), 20.0);
						 	default: MoveObject(objects[x], 1479.0-((random(1))+fft[x]*20), -1641.0-((random(1))+fft[x]*30), 14.0+(left*0.15), 20.0);
						}
					}
					else printf("Spectrum: ChannelGetLevel error %d", BASS_ErrorGetCode());
				}
			}
	        fftvalue[x] = fft[x];
	    }
	}
	else printf("Spectrum: ChannelGetData error %d", BASS_ErrorGetCode());
}

public OnObjectMoved(objectid)
{
	for(new x;x<sizeof(objects);x++)
	{
	    if(objects[x] == objectid)
	    {
	        DestroyObject(objectid);
	        objects[x] = 0;
	        break;
	    }
	}
	return 1;
}
