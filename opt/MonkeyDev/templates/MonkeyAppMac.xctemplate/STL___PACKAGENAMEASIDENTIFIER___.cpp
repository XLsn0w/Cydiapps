//___FILEHEADER___

#include <iostream>
#include "___PACKAGENAMEASIDENTIFIER___.hpp"
#include "___PACKAGENAMEASIDENTIFIER___Priv.hpp"

void ___PACKAGENAMEASIDENTIFIER___::HelloWorld(const char * s)
{
    ___PACKAGENAMEASIDENTIFIER___Priv *theObj = new ___PACKAGENAMEASIDENTIFIER___Priv;
    theObj->HelloWorldPriv(s);
    delete theObj;
};

void ___PACKAGENAMEASIDENTIFIER___Priv::HelloWorldPriv(const char * s) 
{
    std::cout << s << std::endl;
};

