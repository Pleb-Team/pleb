//#include <Shlobj.h>

//#include "../VersionInfo/Version.h"

#include "Konfiguration.h"
//#include "Global.h"

// Das globale Konfig-Objekt
CKonfiguration* g_pKonfig = new CKonfiguration();
//std::wstring g_sProgramDir;



////---------------------------------------------------------------------------------------------------------
///// Konstruktor, setzt die Standardwerte und schreibt "Hallo" in die Logdatei.
///// WICHTIG: Hier wird auch schon die Einstellungen.ini gelesen!
////---------------------------------------------------------------------------------------------------------
//CKonfiguration::CKonfiguration()
//{
//	// Erstmal nen Standard für die Geschwindigkeit setzen
//	SetSpeed();

//	//m_nStrategieFuerZugEmpfehlung = Jojo_PlayerAISimpleAI2;
//	//m_nLevelOfDetail = 0; // Alle details

//	SYSTEMTIME SystemTime;
//	GetSystemTime( &SystemTime );

//	// Logdatei neu erstellen
//	WCHAR path[MAX_PATH];
//	HRESULT hr = SHGetFolderPath(NULL, CSIDL_PERSONAL, NULL,
//                             SHGFP_TYPE_CURRENT, path);

	
//	g_sProgramDir = (std::wstring) path + L"\\Arschloch3D\\";
	
//	if (GetFileAttributesW(g_sProgramDir.c_str()) == INVALID_FILE_ATTRIBUTES)
//	{
//		// Param 2: A pointer to a SECURITY_ATTRIBUTES structure. The lpSecurityDescriptor member of the structure specifies a
//		// security descriptor for the new directory. If lpSecurityAttributes is NULL, the directory gets a default security descriptor.
//		// The ACLs in the default security descriptor for a directory are inherited from its parent directory.
//		if (!CreateDirectoryW(g_sProgramDir.c_str(), NULL))
//		{
//			std::wstring s;
//			s = L"Error: Data directory could not be created (" + g_sProgramDir + L"). Try starting Start Arschloch3D as administrator.";
//			MessageBox( 0, s.c_str(), L"Bug", MB_ICONERROR );
//		}
//	}


//	m_sLogFile = g_sProgramDir + c_sLogfileGeneral;
//	std::ofstream Logfile;
//	Logfile.open( m_sLogFile, std::ios_base::out | std::ios_base::trunc  );

//	if (!Logfile.is_open() )
//	{
//		std::wstring s;
//		s = L"Error: Logfile could not be opened in write acess (" + m_sLogFile + L"). Try starting Start Arschloch3D as administrator.";
//		MessageBox( 0, s.c_str(), L"Bug", MB_ICONERROR );
//	}
//	else
//	{
//		Logfile << "Dies ist die globale Logdatei von Arschloch3D" << std::endl;
//		Logfile << "Current date: " << SystemTime.wDay << "." << SystemTime.wMonth;
//		Logfile	<< " " << SystemTime.wHour << ":" << SystemTime.wMinute << " Uhr" << std::endl;
//		Logfile.close();
//	}

//	// Bestehende Einstellungen.ini suchen und einlesen, danach den PFad auf Userdir umstellen
//	m_sInidatei = g_sProgramDir + c_sSettingsFile;

//	if (GetFileAttributesW(m_sInidatei.c_str()) != INVALID_FILE_ATTRIBUTES)
//	{
//		ReadInifile(m_sInidatei);
//	}
//	else
//	{
//		// If settings do not yet exist in users dir, read them from program dir
//		// ./ at the beginning is needed, don't know why...
//		ReadInifile(L"./" + c_sSettingsFile);
//	}
//}



////---------------------------------------------------------------------------------------------------------
///// Liest die Inidatei mit den Einstellungen
////---------------------------------------------------------------------------------------------------------
//void CKonfiguration::ReadInifile(std::wstring sFilename)
//{
//	Log( "CKonfiguration::ReadInifile()" );

//	int i, nAnzahl;
//	CString sKey, sValue;

//	// Kartenhintergrund
//	nAnzahl = 0;
//	for (;;++nAnzahl)
//	{
//		sKey.Format( L"HintergrundKarten%d", nAnzahl);
//		if ( !GetPrivateProfileString( L"Skin", sKey, L"", sValue.GetBufferSetLength(_MAX_PATH), _MAX_PATH, sFilename.c_str() ) )
//			break;
//	}

//	if (nAnzahl > 0)
//	{
//		sKey.Format( L"HintergrundKarten%d", rand() % nAnzahl );
//		GetPrivateProfileString( L"Skin", sKey, L"Media/Hintergrund Karten0.jpg", m_sHintergrundKarten.GetBufferSetLength(_MAX_PATH), _MAX_PATH, sFilename.c_str() );
//	}
//	else
//		m_sHintergrundKarten = L"Media/Hintergrund Karten0.jpg";


//	// Bildschirmhintergrund
//	nAnzahl = 0;
//	for (;;++nAnzahl)
//	{
//		sKey.Format( L"HintergrundBildschirm%d", nAnzahl);
//		if ( !GetPrivateProfileString( L"Skin", sKey, L"", sValue.GetBufferSetLength(_MAX_PATH), _MAX_PATH, sFilename.c_str() ) )
//			break;
//	}
//	if (nAnzahl > 0)
//	{
//		sKey.Format( L"HintergrundBildschirm%d", rand() % nAnzahl );
//		GetPrivateProfileString( L"Skin", sKey, L"", m_sHintergrundBildschirm.GetBufferSetLength(_MAX_PATH), _MAX_PATH, sFilename.c_str() );
//	}
//	else
//		m_sHintergrundBildschirm = L"Media/Hintergrund Bildschirm0.jpg";


//	// Karten
//	nAnzahl = 0;
//	for (;;++nAnzahl)
//	{
//		sKey.Format( L"Karten%d", nAnzahl);
//		if ( !GetPrivateProfileString( L"Skin", sKey, L"", sValue.GetBufferSetLength(_MAX_PATH), _MAX_PATH, sFilename.c_str() ) )
//			break;
//	}
//	if (nAnzahl > 0)
//	{
//		sKey.Format( L"Karten%d", rand() % nAnzahl );
//		GetPrivateProfileString( L"Skin", sKey, L"", m_sDickeTexturKarten.GetBufferSetLength(_MAX_PATH), _MAX_PATH, sFilename.c_str() );
//	}
//	else
//		m_sDickeTexturKarten = L"Media/Karten.jpg";


//	// Anderes Zeugs einlesen
//	m_nRevisionFromIni = GetPrivateProfileInt( L"General", L"Revision", 1, sFilename.c_str() );
//	m_fDauerSplashScreen = GetPrivateProfileInt( L"General", L"SplashDauer", 4, sFilename.c_str() );
//	GetPrivateProfileString( L"Skin", L"SplashScreen", L"Media/Splash.jpg", m_sSplashScreen.GetBufferSetLength( _MAX_PATH), _MAX_PATH, sFilename.c_str() );
//	m_nLevelOfDetail = GetPrivateProfileInt( L"General", L"LevelOfDetail",0, sFilename.c_str() );

//	m_bZeigeGUI = ( GetPrivateProfileInt( L"General", L"ZeigeGUI", 0, sFilename.c_str() ) != 0 );
//	m_bRenderNurVorderseiten = GetPrivateProfileInt( L"General", L"RenderNurVorderseiten", 0, sFilename.c_str() ) != 0;
//	m_nAlphaBetaRekursionsTiefe = GetPrivateProfileInt( L"General", L"AlphaBetaRekursionsTiefe", 9, sFilename.c_str() );
//	m_nStrategieFuerZugEmpfehlung = GetPrivateProfileInt( L"General", L"StrategieZugEmpfehlung", Jojo_PlayerAISimpleAI2, sFilename.c_str() );
//	m_nStrategieFuerZugEmpfehlung = max( 0, min( m_nStrategieFuerZugEmpfehlung, Jojo_PlayerAIStrategyMax-1 ) );


//	// Geometrie einlesen
//	LiesVektorAusIni( "CameraPosition", m_vCameraPosition );
//	LiesVektorAusIni( "UntenLinks", m_vUntenLinks );
//	LiesVektorAusIni( "ObenRechts", m_vObenRechts );
//	LiesVektorAusIni( "UntenLinksGUI", m_vUntenLinksGUI );
//	LiesVektorAusIni( "ObenRechtsGUI", m_vObenRechtsGUI );

//	//alt:
//	Log( (std::string) "\tLevelOfDetail: " + inttostr(m_nLevelOfDetail) );
//	Log( "CKonfiguration::ReadInifile() erfolgreich" );
//}


////---------------------------------------------------------------------------------------------------------
///// Schreibt die Einstellungen in die Inidatei
////---------------------------------------------------------------------------------------------------------
//void CKonfiguration::WriteInifile()
//{
//	CString s;
//	bool bSucess = true;

//	if ( m_bZeigeGUI ) s = "1"; else s = "0";
//	bSucess &= (0 != WritePrivateProfileString( L"General", L"ZeigeGUI", s, m_sInidatei.c_str() ));

//	if ( m_bRenderNurVorderseiten ) s = "1"; else s = "0";
//	bSucess &= (0 != WritePrivateProfileString( L"General", L"RenderNurVorderseiten", s, m_sInidatei.c_str() ));

//	s.Format( L"%d", m_nStrategieFuerZugEmpfehlung );
//	bSucess &= (0 != WritePrivateProfileString( L"General", L"StrategieZugEmpfehlung", s, m_sInidatei.c_str() ));

//	s.Format( L"%d", m_nAlphaBetaRekursionsTiefe );
//	bSucess &= (0 != WritePrivateProfileString( L"General", L"AlphaBetaRekursionsTiefe", s, m_sInidatei.c_str() ));

//	bSucess &= (0 != WritePrivateProfileString( L"General", L"Revision", c_sSvnRevision.c_str(), m_sInidatei.c_str() ));

//	if (!bSucess )
//	{
//		std::wstring s;
//		s = L"Error: Settings could not be saved in inifile (" + m_sInidatei + L"), probably no write access. Try starting Start Arschloch3D as administrator.";
//		MessageBox( 0, s.c_str(), L"Bug", MB_ICONERROR );
//	}

//}


//---------------------------------------------------------------------------------------------------------
/// Schreibt eine Zeile SOFORT in die Logdatei auf die Festplatte (absturzsicher)
//---------------------------------------------------------------------------------------------------------
void CKonfiguration::Log( std::string s ) 
{ 
	// Meldung auch in die Konsole schreiben
	std::cout << s << std::endl;

//	// Logdatei öffnen für append
//	std::ofstream Logfile;
//	Logfile.open( m_sLogFile, std::ios_base::out |  std::ios_base::app  );
//	if (Logfile.is_open() )
//	{
//		Logfile << s << std::endl;
//		Logfile.close();
//	}
}


////---------------------------------------------------------------------------------------------------------
///// Setzt die Geschwindigkeit. 0 = Am langsamsten, 1 = normal, 2 = am schnellsten
////---------------------------------------------------------------------------------------------------------
//void CKonfiguration::SetSpeed( float fFaktor /*  = 1.0f */ )
//{
//	m_fSpeed = max(0, fFaktor);

//	const float fMultiplikator = 5;
//	float fBremse = fMultiplikator * (1 - fFaktor/2);

//	m_fZeitBisPlayerSpielt = fBremse;

//	// So lange ist eine Karte unterwegs, z.B. vom spieler zum Stapel
//	m_fZeitKartenFliegen = fBremse;
//	m_fZeitBisSpielBeginnt = 0.5f * fBremse;

//	// So lange dauert es insgesamt, bis alle Karten verteilt sind
//	// (+ m_fZeitKartenFliegen für die Animation der Karte)
//	m_fZeitKartenVerteilen = 3.0f * fBremse;
//}


////---------------------------------------------------------------------------------------------------------
///// Liest / schreibt einen Vektor in die Sektion [Geometrie]
////---------------------------------------------------------------------------------------------------------
//void CKonfiguration::LiesVektorAusIni( CString sKey, D3DXVECTOR3 & v)
//{
//	CString s;
//	GetPrivateProfileString( L"Geometrie", sKey, L"0, 0, 0", s.GetBufferSetLength(100), 100, GetIniFilename() );
	
//	int nResult = swscanf_s(s.GetBuffer(), L"%f, %f, %f", &v.x, &v.y, &v.z);

//	// Standard zuweisen
//	if (nResult != 3)
//		v = D3DXVECTOR3(0,0,0);
//}


////---------------------------------------------------------------------------------------------------------
///// Liest / schreibt einen Vektor in die Sektion [Geometrie]
////---------------------------------------------------------------------------------------------------------
//void CKonfiguration::SchreibVektorInIni( CString sKey, D3DXVECTOR3 & v)
//{
//	CString s;

//	s.Format( L"%.2d, %.2d, %.2d", v.x, v.y, v.z);
//	WritePrivateProfileString( L"Geometrie", sKey, s.GetBuffer(), GetIniFilename() );
//}
