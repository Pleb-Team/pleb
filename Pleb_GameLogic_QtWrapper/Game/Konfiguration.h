#ifndef KONFIGURATION_H
#define KONFIGURATION_H

#include "GlobalConstants.h"
//#include "Common/dxstdafx.h"
//#include <d3dx9math.h>

//#include <fstream>
#include <iostream>

//----------------------------------------------------------------------------------------------------
/// Alle möglichen Einstellungen, für Spiel und GUI
/// Verwaltet ebenfalls eine Log-Date
//----------------------------------------------------------------------------------------------------
class CKonfiguration {
private:

	/// Dateiname der Einstellungen.ini . Ist absichtlich privat
//	std::wstring m_sInidatei;

//	std::wstring m_sLogFile;

//	float m_fSpeed;

	/// Liest / schreibt einen Vektor in die Sektion [Geometrie]
//	void LiesVektorAusIni( CString sKey, D3DXVECTOR3 & v);
//	void SchreibVektorInIni( CString sKey, D3DXVECTOR3 & v);
			
public:

	//----------------------------------------------Konfiguration aus der Inidatei--------------------

	/// Innerhalb dieses Rechtecks werden PlayerViewsund SpielStapel angeordnet
//	D3DXVECTOR3 m_vCameraPosition, m_vUntenLinks, m_vObenRechts, m_vUntenLinksGUI, m_vObenRechtsGUI;

////	float m_fDauerSplashScreen;
////	float m_fZeitBisPlayerSpielt;
////	float m_fZeitKartenFliegen;
////	float m_fZeitBisSpielBeginnt;
////	float m_fZeitKartenVerteilen;

//	/// A version number corresponding to the version ov Arschloch3D.exe which has written
//	/// Einstellungen.ini the last time. This allows for updates to detect their first runs
//	/// and possibly inform the user, ...
//	int m_nRevisionFromIni;

//	/// Gibt an, daß nur die Vorderseiten der Karten gerendert werden sollen. Sonst werden Karten als Quader gerendert
//	bool m_bRenderNurVorderseiten;

//	/// Ist die GUI gerade sichtbar?
//	bool m_bZeigeGUI;

//	/// Globales Flag, ob man alle Karten der Mitspieler sehen kann
//	bool m_bAlleKartenSichtbar;

//	/// Karten rot highlighten, die von der KI zum spielen empfohlen sind
//	bool m_bKIEmpfehlung;

//	/// Strategie, nach der die Empfehlung zum Spielen (rote Karten) berechnet werden
//	int m_nStrategieFuerZugEmpfehlung;

//	/// Gibt an, welche Direct3D-Fähigkeiten aktiviert sind. 0 = alle
//	int m_nLevelOfDetail;

//	/// Maximale Rekursionstiefe des Backtrackings
//	/// Tiefe 1, 5, 9... sind jeweils unmittelbar, nachdem dieser Player gespielt hat
//	int m_nAlphaBetaRekursionsTiefe;

//	CString m_sHintergrundBildschirm,
//			m_sHintergrundKarten,
//			m_sDickeTexturKarten,
//			m_sSplashScreen;
	

//	//----------------------------------------------Funktionen----------------------------------------

	
//	/// Konstruktor, liest Einstellungen.ini
//	CKonfiguration();
//	~CKonfiguration() {	 WriteInifile(); };

//	void ReadInifile(std::wstring sFilename);
//	void WriteInifile();

//	/// Setzt die Geschwindigkeit. 0 = Am langsamsten, 1 = normal, 2 = am schnellsten
//	void SetSpeed( float fFaktor = 1.0f );
//	float GetSpeed() { return m_fSpeed; };

	/// Schreibt eine Zeile SOFORT in die Logdatei auf die Festplatte (absturzsicher)
	void Log( std::string s );

	/// Gibt den Dateinamen der Einstellungen.ini wieder
//	CString GetIniFilename() { return m_sInidatei.c_str(); };
};

//----------------------------------------------------------------------------------------------------
/// Globales Konfiguration-Objekt
//----------------------------------------------------------------------------------------------------
extern CKonfiguration* g_pKonfig;
//extern std::wstring g_sProgramDir;

#endif
