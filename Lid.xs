/*
    Alex Linke <alinke@lingua-systems.com>

    Copyright (C) 2009-2010 Lingua-Systems Software GmbH
*/


#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <lid.h>


/*
 * ...for compatibility with lid versions < 3
 */
#if ! defined(LID_VERSION_MAJOR) || LID_VERSION_MAJOR < 3
    #define LID_NOERR              LID_ENOERR
    #define LID_VERSION_STRING     LID_VERSION
    #define lid_version_string()   LID_VERSION
#endif


/*
 * Auxiliary macro:  SET_HVP_RETVAL()
 *
 * This macro converts an identification's result (lid_t *) into a Perl hash
 * (HV *) and sets the XS RETVAL variable to the hash.
 */
#define SET_HVP_RETVAL(r)                                                    \
{                                                                            \
    HV * h = (HV *) sv_2mortal((SV *) newHV());                              \
                                                                             \
    hv_store(h, "language", 8, newSVpv(r->language, 0), 0);                  \
    hv_store(h, "isocode",  7, newSVpv(r->isocode,  0), 0);                  \
    hv_store(h, "encoding", 8, newSVpv(r->encoding, 0), 0);                  \
                                                                             \
    RETVAL = h;                                                              \
}


MODULE = Lingua::Lid   PACKAGE = Lingua::Lid


PROTOTYPES: DISABLE


##
## Exportable: lid_version()
##
## NOTE: returns runtime version of lid
##
const char *
lid_version()
    CODE:
        RETVAL = lid_version_string();
    OUTPUT:
        RETVAL


##
## Exportable: lid_version_ct()
##
## NOTE: returns compile time version of lid
##
const char *
lid_version_ct()
    CODE:
        RETVAL = LID_VERSION_STRING;
    OUTPUT:
        RETVAL


##
## Exportable: lid_ffile()
##
HV *
lid_ffile(file)
    const char *file
    PREINIT:
	lid_t * r = NULL;
    CODE:
        r = lid_ffile(file);

        if (r && r->language && r->isocode && r->encoding)
        {
            SET_HVP_RETVAL(r);
            lid_free(r);
        }
        else
        {
            XSRETURN_UNDEF;
        }
    OUTPUT:
        RETVAL


##
## Exportable: lid_fstr()
##
HV *
lid_fstr(str)
    SV * str
    PREINIT:
        lid_t      * r     = NULL;
        STRLEN       len   = 0;
        const char * bytes = NULL;
    CODE:
        /*
         * Only extract bytes if Perl thinks "str" contains string like data,
         * that is, if the SV is marked with the POK flag.
         *
         * Otherwise, the default values "(NULL, 0)" are passed to
         * lid_fnstr() which does the right thing by throwing the following
         * error: LID_EARG denoting "Invalid argument".
         */
        if (SvPOK(str))
        {
            len   = SvCUR(str);
            bytes = SvPV(str, len);
        }

        r = lid_fnstr(bytes, len);

        if (r && r->language && r->isocode && r->encoding)
        {
            SET_HVP_RETVAL(r);
            lid_free(r);
        }
        else
        {
            XSRETURN_UNDEF;
        }
    OUTPUT:
        RETVAL


##
## Package: errstr()
##
const char *
errstr()
    CODE:
        if (lid_errno == LID_NOERR)
        {
            XSRETURN_UNDEF; /* return undef rather than "No error" */
        }
        else
        {
            RETVAL = lid_strerror(lid_errno);
        }
    OUTPUT:
        RETVAL


# vim: sts=4 sw=4 enc=utf-8 ai et ft=xs
