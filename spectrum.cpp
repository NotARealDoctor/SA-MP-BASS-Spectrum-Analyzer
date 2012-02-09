//----------------------------------------------------------
//
//   SA-MP Multiplayer Modification For GTA:SA
//   Copyright 2004-2010 SA-MP Team
//
//   Author: h02 10 Jan 2010
//
//----------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "spectrum.h"
#include "bass.h"
//----------------------------------------------------------

CSpectrum::CSpectrum()
{
	m_iOperatingMode = SPECTRUM_MODE_NONE;
	m_pPointData = NULL;
}

//----------------------------------------------------------

CSpectrum::~CSpectrum()
{
	m_iOperatingMode = SPECTRUM_MODE_NONE;
    if(m_pPointData) free(m_pPointData);
	m_pPointData = NULL;
}

//----------------------------------------------------------

int CSpectrum::Init()
{
	
}

int CSpectrum::Free()
{
	if(BASS_Free())
	{
		m_iOperatingMode = SPECTRUM_MODE_NONE;
		return SPECTRUM_ERROR_SUCCESS;
	}
	return BASS_ErrorGetCode();
}

//----------------------------------------------------------
int CSpectrum::PlayStream(char url)
{
	if(m_iOperatingMode == SPECTRUM_MODE_NONE)
	{
		return -1;
	}
	if (!(chan=BASS_StreamCreateURL("http://yp.shoutcast.com/sbin/tunein-station.pls?id=860870",0,BASS_STREAM_DECODE,NULL,0)))
	{
		//&& !(chan=BASS_MusicLoad(FALSE,"chicken.mp3",0,0,BASS_MUSIC_RAMP|BASS_SAMPLE_LOOP,0))) {
		return BASS_ErrorGetCode();
	}

	BASS_ChannelPlay(chan,FALSE);

	return SPECTRUM_ERROR_SUCCESS;
}

//----------------------------------------------------------