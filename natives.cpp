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
 *  The Original Code is the BASS Spectrum Analyzer SA:MP plugin.
 *  
 *  The Initial Developer of the Original Code is Scott Reed - h02@h02.org
 *  Portions created by the Initial Developer are Copyright (C) 2012
 *  the Initial Developer. All Rights Reserved.
 *  
 *  Contributor(s):
 *
 *  SA:MP team - plugin framework.
 */

#include <stdio.h>

#include "amx/amx.h"
#include "plugincommon.h"
#include "natives.h"
#include "bass.h"

HSTREAM chan;

//----------------------------------------------------------

typedef void (*logprintf_t)(char* format, ...);
extern logprintf_t logprintf;
int	m_iOperatingMode;

//----------------------------------------------------------

#define CHECK_PARAMS(f, n) { if (params[0] != (n * sizeof(cell))) { logprintf("SCRIPT: Bad parameter count (Count is %d, Should be %d): %s", params[0] / sizeof(cell), (n), (f)); return 0; } }

//----------------------------------------------------------
// native BASS_Init();
PLUGIN_EXTERN_C cell AMX_NATIVE_CALL n_Init(AMX* amx, cell* params)
{
	// check if already inited
	if(m_iOperatingMode != SPECTRUM_MODE_NONE) {
		logprintf("Spectrum: plugin could not init - already initialized");
		return 0;
	}

	// initialize BASS
	if (!BASS_Init(0,44100,0,0,NULL)) {
		return 0;
	}

	// check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
		return 0;
	}

	BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST,1);
	BASS_SetConfig(BASS_CONFIG_NET_PREBUF,0);

	m_iOperatingMode = SPECTRUM_MODE_FULL;
	return 1;
}

//----------------------------------------------------------
// native BASS_Free();
PLUGIN_EXTERN_C cell AMX_NATIVE_CALL n_Free(AMX* amx, cell* params)
{
	if(BASS_Free())
	{
		m_iOperatingMode = SPECTRUM_MODE_NONE;
		return 1;
	}
	return 0;
}

//----------------------------------------------------------
// native BASS_PlayStream();

PLUGIN_EXTERN_C cell AMX_NATIVE_CALL n_PlayStream(AMX* amx, cell* params)
{	
	CHECK_PARAMS("BASS_PlayStream", 1);
	if(m_iOperatingMode == SPECTRUM_MODE_NONE)
	{
		logprintf("Spectrum: unable to play file - bass not initialized");
		return 0;
	}
	
	cell *addr  = NULL;
	int len = NULL;

    amx_GetAddr(amx, params[1], &addr); 
    amx_StrLen(addr, &len);

	if(len)
	{
		len++;
		char* url = new char[ len ];
        amx_GetString(url, addr, 0, len);

		if (!(chan=BASS_StreamCreateURL(url,0,BASS_STREAM_DECODE,NULL,0)))
		{
			delete [] url;
			return 0;
		}

		BASS_ChannelPlay(chan,FALSE);
		delete [] url;
		return 1;
	}
	return 0;
}

//----------------------------------------------------------
// native BASS_StopStream();
PLUGIN_EXTERN_C cell AMX_NATIVE_CALL n_StopStream(AMX* amx, cell* params)
{
	if(BASS_ChannelStop(chan))
	{
		m_iOperatingMode = SPECTRUM_MODE_NONE;
		return 1;
	}
	return 0;
}

//----------------------------------------------------------
// native BASS_ChannelGetLevel(&left, &right)
PLUGIN_EXTERN_C cell AMX_NATIVE_CALL n_ErrorGetCode(AMX* amx, cell* params)
{
	return BASS_ErrorGetCode();
}
//----------------------------------------------------------
// native BASS_ChannelGetLevel(&left, &right)
PLUGIN_EXTERN_C cell AMX_NATIVE_CALL n_ChannelGetLevel(AMX* amx, cell* params)
{
	CHECK_PARAMS("BASS_ChannelGetLevel", 2);
	DWORD level, left, right;
	if(level=BASS_ChannelGetLevel(chan))
	{
		left=MulDiv(100, LOWORD(level), 32768); // set left peak
		right=MulDiv(100, HIWORD(level), 32768); // set right peak

		cell* addr[2] = {NULL, NULL};
    
		amx_GetAddr(amx, params[1], &addr[0]);
		amx_GetAddr(amx, params[2], &addr[1]);

		*addr[0] = left;
		*addr[1] = right;
		return 1;
	}
	return 0;
}

//----------------------------------------------------------
// native BASS_ChannelGetData(buffer[], length)
PLUGIN_EXTERN_C cell AMX_NATIVE_CALL n_ChannelGetData(AMX* amx, cell* params)
{
	CHECK_PARAMS("BASS_ChannelGetData", 2);
	int length = (int)params[2];
	DWORD clength;
	switch(length)
	{
	case 0:
		clength=BASS_DATA_FFT256;
		length=128;
		break;
	case 1:
		clength=BASS_DATA_FFT512;
		length=256;
		break;
	case 2:
		clength=BASS_DATA_FFT1024;
		length=512;
		break;
	case 3:
		clength=BASS_DATA_FFT2048;
		length=1024;
		break;
	case 4:
		clength=BASS_DATA_FFT4096;
		length=2048;
		break;
	default:
		logprintf("Spectrum: error unknown length");
		return 0;
	}
	float* buffer = new float[length];

	if(BASS_ChannelGetData(chan,buffer,clength) == -1)// get the FFT data
	{
		return 0;
	}

	cell* addr = NULL;
	amx_GetAddr(amx, params[1], &addr);
	for(int i = 0, l = length; i < l; i++)
	{
		*(addr + i) = amx_ftoc(buffer[i]);
	}

	delete [] buffer;
	return 1;
}

//----------------------------------------------------------
