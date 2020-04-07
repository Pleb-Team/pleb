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


/// Konvertiert einen std::string in einen Integer mit atoi
//inline int strtoint(std::string s)
//{
//	return atoi(s.c_str() );
//}



#endif
