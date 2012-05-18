//----------------------------------------------------------
//
//   SA-MP Multiplayer Modification For GTA:SA
//   Copyright 2004-2010 SA-MP Team
//
//   Author: Kye 10 Jan 2010
//
//----------------------------------------------------------

#pragma once

#define NATIVE_PREFIX "BASS_"

#define DECL_AMX_NATIVE(a) PLUGIN_EXTERN_C cell AMX_NATIVE_CALL n_##a (AMX* amx, cell* params)
#define DECL_AMX_MAP(a) { NATIVE_PREFIX #a, n_##a }

#define SPECTRUM_MODE_NONE				0
#define SPECTRUM_MODE_FULL				1

/*
native BASS_Init();
native BASS_Free();
native BASS_PlayStream(url[]);
native BASS_StopStream(chan);
native BASS_ErrorGetCode();
native BASS_ChannelGetData(chan, buffer[], length);
native BASS_ChannelGetLevel(chan, &left, &right);
*/

DECL_AMX_NATIVE(Init);
DECL_AMX_NATIVE(Free);
DECL_AMX_NATIVE(PlayStream);
DECL_AMX_NATIVE(StopStream);
DECL_AMX_NATIVE(ErrorGetCode);
DECL_AMX_NATIVE(ChannelGetData);
DECL_AMX_NATIVE(ChannelGetLevel);
DECL_AMX_NATIVE(ChannelGetLength);