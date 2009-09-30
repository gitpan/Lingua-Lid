/*
    Alex Linke, <alinke@lingua-systems.com>

    Copyright (C) 2009 Lingua-Systems Software GmbH
*/


#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <string.h>
#include <lid.h>


/*
Auxiliary macro:  SET_ERRSTR()

This macro evaluates an identification's result data structure (lid_t *) and
sets Lingua::Lid's package variable $errstr to "undef" or --if an error
occurred-- to an appropriate string describing the error.
*/
#define SET_ERRSTR(r)                                                        \
{                                                                            \
    SV * errstr = get_sv("Lingua::Lid::errstr", TRUE);                       \
                                                                             \
    if      (! r || lid_errno != LID_ENOERR)                                 \
    {                                                                        \
        sv_setsv(errstr, newSVpv(lid_strerror(lid_errno), 0));               \
    }                                                                        \
    else if (! r->language || ! r->isocode || ! r->encoding)                 \
    {                                                                        \
        sv_setsv(errstr, newSVpv("internal error (lid_t *)", 0));            \
    }                                                                        \
    else                                                                     \
    {                                                                        \
        sv_setsv(errstr, &PL_sv_undef);                                      \
    }                                                                        \
}


/*
Auxiliary macro:  SET_HVP_RETVAL()

This macro converts an identification's result (lid_t *) into a Perl hash
(HV *) and sets the XS RETVAL variable to the hash.
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
## Frontend:   lid_version()
##
const char *
lid_version()
    CODE:
        RETVAL = LID_VERSION;
    OUTPUT:
        RETVAL


##
## Frontend:   lid_ffile()
##
HV *
lid_ffile(file)
    const char *file
    PREINIT:
	lid_t * r = NULL;
    CODE:
        r = lid_ffile(file);

        SET_ERRSTR(r);

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
## Frontend:   lid_fstr()
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
          Only extract bytes if Perl thinks "str" contains string like data,
          that is, if the SV is marked with the POK flag.

          Otherwise, the default values "(NULL, 0)" are passed to lid_fnstr()
          which does the right thing by throwing the following error:
          LID_EARG denoting "Invalid argument".
        */
        if (SvPOK(str))
        {
            len   = SvCUR(str);
            bytes = SvPV(str, len);
        }

        r = lid_fnstr(bytes, len);

        SET_ERRSTR(r);

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


# vim: sts=4 sw=4 enc=utf-8 ai et ft=xs
