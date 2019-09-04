## Script to enable pst files in outlook ##

set-executionPolicy -ExecutionPolicy "Bypass"

set-itemproperty -path HKCU:\Software\Policies\Microsoft\office\16.0\outlook\PST -Name 'PSTDisableGrow' -value '0'

set-itemproperty -path HKCU:\Software\Policies\Microsoft\office\16.0\outlook -Name 'DisabePST' -value '0'
