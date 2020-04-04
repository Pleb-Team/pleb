#ifndef GLOBAL_H
#define GLOBAL_H

#include "GlobalConstants.h"


inline std::string WString2String( std::wstring ws )
{
    std::string s(ws.begin(), ws.end());
	return s;
}


inline std::wstring String2WString( std::string s )
{
    std::wstring ws(s.begin(), s.end());
	return ws;
}

//inline std::string CString2StdString( CString cs )
//{
//	//std::wstring ws = (LPCTSTR) cs;
//	//std::string s( ws.begin(), ws.end() );
//	//return s;

//	return WString2String(cs.GetBuffer());
//}



/// Formatiert einen Integer in einen std:.string mit _itoa
inline std::string inttostr(int i)
{
	char Buffer[64];

	// errno_t _itoa_s( int value,  char *buffer,  size_t sizeInCharacters,  int radix 
	_itoa_s(i, Buffer, sizeof(Buffer), 10); 
	std::string s = Buffer;
	return s;
}

/// Konvertiert einen std::string in einen Integer mit atoi
inline int strtoint(std::string s)
{
	return atoi(s.c_str() );
}



#endif
