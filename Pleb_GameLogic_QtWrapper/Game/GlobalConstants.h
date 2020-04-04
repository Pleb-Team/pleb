#ifndef GLOBALCONSTANTS_H
#define GLOBALCONSTANTS_H

//#include <Shlobj.h>
//#include <atlstr.h>
#include <vector>
#include <string>

// Undefine toes not call or include any YaDT stuff
#undef A3D_USE_YADT



/// Debugging
//#define NUMBER_DEBUG_MESSAGES	100


// This binary's version, is also stored in the Config-File and the history-file
//const int c_nArschlochVersion = 3;
const int c_nStringBufferLength = 255;

// Size in Pixels of the welcome dialog
const int c_nGreetingGuiWidth = 400;
const int c_nGreetingGuiHeight = 400;


//--------------------------------------------------------------------------------------------------
/// Zustände !!!
//--------------------------------------------------------------------------------------------------
enum Jojo_Zustand 
{	
	Jojo_Zustand_Nix,							// Spiel zu Ende, Karten in CGame bereits gemischt, kein Player hat karten

	Jojo_SpielZustandKartenGemischt,
	Jojo_SpielZustandKartenVerteilen,
	Jojo_SpielZustandKartenVerteilenFertig,
	Jojo_SpielZustandKartenTauschen,
	Jojo_SpielZustandKartenTauschenFertig,
	Jojo_SpielZustandSpielen,
	Jojo_SpielZustandSpielZuEnde,
	
	// Diese Zustände existieren NUR in CGameControlView
	Jojo_ZustandGui_Greeting,					// Greeting Dialog wird gerade angezeigt
	Jojo_ZustandGui_GreetingFertig,
	Jojo_ZustandGui_Highscore,					// Die Highscore wird gerade angezeigt
	Jojo_ZustandGui_Anwendungsstart,
	Jojo_ZustandGui_SplashScreen,

	Jojo_ZustandMax
};


//--------------------------------------------------------------------------------------
// 3D-Modells
//--------------------------------------------------------------------------------------
#define ABSTAND_KARTEN3D_Z		0.025f
#define STAERKE_KARTEN3D_Z		0.02f


//--------------------------------------------------------------------------------------
// UI control IDs
//--------------------------------------------------------------------------------------
enum Jojo_GuiIDs {
	IDC_TOGGLEFULLSCREEN,
	IDC_TOGGLEREF,
	IDC_CHANGEDEVICE,
	IDC_SCHIEBEN,
	IDC_MOGELN,
	IDC_NEUESSPIEL,
	IDC_ZEIGEGUI,
	IDC_BEENDEN,
	IDC_INFO,
	IDC_SPEED,
	IDC_KIEMPFEHLUNG,
	IDC_txtPlayerTyp,
	IDC_txtPlayerInfo,
	IDC_cmbStrategie,
	IDC_txtStatistik,
	IDC_txtPlayerName,
	Jojo_GuiID_Rekursion,
	Jojo_GuiID_UndoMove,
	Jojo_GuiID_NextMove,
	Jojo_GuiID_GreetingOk
};


const std::string c_sLogfileAlphaBeta = "AlphaBeta.log";
const std::wstring c_sLogfileGameHistory = L"GameHistory.log";
const std::wstring c_sLogfileGeneral = L"Arschloch3D.log";
const std::wstring c_sSettingsFile = L"Einstellungen.ini";



//----------------------------------------------------------------------------------------------------
// Konstanten, die das Spiel und die Karten beschreiben
//----------------------------------------------------------------------------------------------------

#define MAX_REKURSION	20

#define MAX_VALUE		7
#define NUMBER_VALUE	8

#define MAX_COLOR		3
#define NUMBER_COLOR	4

#define MAX_CARD		31
#define NUMBER_CARD		32

#define NUMBER_PLAYER	4
#define MAX_PLAYER		3

/// Maximale Anzahl von Karten, die getauscht werden müssen (für GameHistory)
#define NUMBER_KARTENTAUSCHEN	2

#define CARD_7			0
#define CARD_8			1
#define CARD_9			2
#define CARD_10			3
#define CARD_BUBE		4
#define CARD_DAME		5
#define CARD_KOENIG		6
#define CARD_As			7
const std::string c_sTextOnCards[NUMBER_VALUE] = {"7", "8", "9", "10", "B", "D", "K", "As"};

// 2er-potenzen, damit man durch bitweises OR eine Menge von Karten beschreibt
#define COLOR_KARO		1
#define COLOR_HERZ		2
#define COLOR_PIK		4
#define COLOR_KREUZ		8

//----------------------------------------------------------------------------------------------------
// Konstanten für die verschiedenen Game- und Playertypen
//----------------------------------------------------------------------------------------------------

//#define NUMBER_GAME_TYPES 3
//#define GAME_TYPE_NORMAL		0
//#define GAME_TYPE_DEBUG			1
//#define GAME_TYPE_2PLAYER		2
//const CString c_sShortGameDescriptions[NUMBER_GAME_TYPES] = {"Normal", "Debug", "2-Player"};
//inline CString GetShortDescriptionGameType(int Type) {
//	switch (Type) {
//		case GAME_TYPE_NORMAL:	return "Normal"; break;
//		case GAME_TYPE_DEBUG:	return "Debug"; break;
//		case GAME_TYPE_2PLAYER:	return "2-Player"; break;
//		default:				return "Unknown game type"; break;
//	}
//}

const std::wstring c_wsDefaultPlayerName[NUMBER_PLAYER] = {L"", L"Achmed", L"Hillary", L"Barack"};

// Konstanten für die verschiedenen KI's. 
// Must NEVER change since theese values are also written to the logfile
enum Jojo_PlayerAIStrategy
{
	Jojo_PlayerAISimpleAI,
	Jojo_PlayerHuman,
	Jojo_PlayerAISimpleAI2,
	Jojo_PlayerAIAlphaBeta,
	Jojo_PlayerAIDecisionTreeLearning,
	Jojo_PlayerAIStrategyMax
};

inline std::string GetShortDescriptionPlayerType(Jojo_PlayerAIStrategy Type) {
	switch (Type) {
        case Jojo_PlayerAISimpleAI:				return "SimpleAI";
        case Jojo_PlayerHuman:					return "Human";
        case Jojo_PlayerAISimpleAI2:			return "SimpleAI2";
        case Jojo_PlayerAIAlphaBeta:			return "AlphaBeta";
        case Jojo_PlayerAIDecisionTreeLearning: return "DT-Learner";
        default:								return "Unbekannter Playertyp";
	}
}

/// Anzahl Parameter anhand denen eine KI konfiguriert werden kann
#define NUMBER_AI_PARAMS	10
#define NUMBER_AI_INFOTEXT	100

//----------------------------------------------------------------------------------------------------
/// Fehlerkonstanten
//----------------------------------------------------------------------------------------------------

#define JOJO_OK					0
#define JOJO_ERROR				-1
inline std::string GetJojoErrorString(int Error) {
	switch (Error) {
        case JOJO_OK:				return "OK";
        case JOJO_ERROR:			return "Error";
        default:					return "Unbekannter Jojo-Fehlercode";
	}
};

//----------------------------------------------------------------------------------------------------
/// Konstanten fürs Spielergebnis
//----------------------------------------------------------------------------------------------------
#define RESULT_UNDEFINED	-42
#define NUMBER_RESULTS		4
#define RESULT_NEGER		0
#define RESULT_VIZENEGER	1
#define RESULT_VIZEPRAESI	2
#define RESULT_PRAESI		3
const std::string c_sResults[NUMBER_RESULTS] = {"Neger", "Vizeneger", "Vize", "Master"};



#endif // GLOBALCONSTANTS_H
