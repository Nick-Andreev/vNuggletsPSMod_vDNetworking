## remove this "psuedo" module that gets created at overall Module import time as this is in ScriptToProcess section of manifest; removing module for the ClassDef bits seems to have no ill effect on the class definitions in the PowerShell session
Remove-Module vNugglets.VDNetworking_ClassDefinition