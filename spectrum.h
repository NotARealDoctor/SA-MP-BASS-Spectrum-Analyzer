//----------------------------------------------------------
//
//   SA-MP Multiplayer Modification For GTA:SA
//   Copyright 2004-2009 SA-MP Team
//
//----------------------------------------------------------

#define SPECTRUM_MODE_NONE				0
#define SPECTRUM_MODE_FULL				1

#define SPECTRUM_ERROR_SUCCESS		0
#define SPECTRUM_ERROR_FAILURE		1

//----------------------------------------------------------

class CSpectrum
{
private:
	int	m_iOperatingMode;
	unsigned short *m_pPointData;

public:
	CSpectrum();
	~CSpectrum();

	int		Init();
	int		Free();
	int		PlayStream(char url);
};


//----------------------------------------------------------