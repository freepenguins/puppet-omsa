(* Omsa module for Augeas
 Author: freepenguins

 /opt/dell/srvadmin/etc is a standard INI File aside from comments
*)


module Omsa =
  autoload xfm

(************************************************************************
 * INI File settings
 *
 * srvadmin only supports ";" as commentary and "=" as separator
 *************************************************************************)
let comment    = IniFile.comment ";" ";"
let sep        = IniFile.sep "=" "="
let entry_re   = ( /[A-Za-z0-9][A-Za-z0-9._-]*/ )

(************************************************************************
 *                        ENTRY
 * srvadmin uses standard INI File entries, including ones starting with a number
 *************************************************************************)
let entry   = IniFile.indented_entry entry_re sep comment


(************************************************************************
 *                        RECORD
 * srvadmin uses standard INI File records
 *************************************************************************)
let title   = IniFile.indented_title IniFile.record_re
let record  = IniFile.record title entry


(************************************************************************
 *                        LENS & FILTER
 * srvadmin uses standard INI File records
 *************************************************************************)
let lns     = IniFile.lns record comment

let filter = (incl "/opt/dell/srvadmin/etc/srvadmin-storage/stsvc.ini"
             )

let xfm = transform lns filter
