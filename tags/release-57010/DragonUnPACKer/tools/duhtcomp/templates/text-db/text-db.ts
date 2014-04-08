# HTML Template Source File (for DUHTComp v2.0 / DUHT v2 rev 11/03/2003)
# ============================================================================
#     Desc: Text Database
#  Program: Dragon UnPACKer v5.0.0 RC3
#  Version: 1.0a
#   Author: Alex Devilliers
# ============================================================================
#
# This file is the model for templates of Dragon UnPACKer.
#
# Then compile the file with DUHTComp and put the resulting .UHT file into the
# \Data\ sub-directory of Dragon UnPACKer.
#
# DON'T MODIFY ANY KEYWORD - JUST CHANGE THINGS AFTER THE = SYMBOL
#
# If you have made a template send it to Alex Devilliers so it can be
# distributed along with the main program archive.
#
# You can reach Alex Devilliers by e-mail: duht (at) elberethzone (dot) net
#                                  by ICQ: 1535372 (Elbereth)
#
# ============================================================================
# Informations about this template
# ============================================================================
#
# Version number is x.x.
#    x is the current version
#
# v1.0a: Changed URLs & Emails to elberethzone.net domain
# v1.0: First version of the template (DUHT v2)
#
{TSF}
#
# + Name +
# Write here the name that will appear in Dragon UnPACKer 4 dialog box for
# your template file (ex: StarDust Template )
#
# Can be up to 255 characters
#
Name = Text Database
#
# + Version +
# Write here the version of the template (ex: 1.0-1.65 )
#
# Can be up to 255 characters
#
Version = 1.0a
#
# + Author +
# Write here your name or alias
#
# Can be up to 255 characters
#
Author = Alexandre "Elbereth" Devilliers
#
# + Email +
# Write here your email (comment out if you don't want your email to appear)
#
# Can be up to 255 characters
#
Email = text-db.dup5template@elberethzone.net
#
# + URL +
# Write here the Internet URL where your file can be downloaded
#
# Can be up to 255 characters
#
URL = http://www.elberethzone.net
#
# + Compression +
# Enable/Disable Automatic Compression in DUHT file.
# If 1 then compression is Enabled (Zlib). (Recommended)
# If 0 then it is Disabled.
#
Compression = 1
#
# + OutFile +
# Path & FileName of the compiled file (ex: c:\test.uht)
#
OutFile = text-db.uht
#
# + DefaultExt +
# Default extension of the file created using this templace (ex: HTML
#                                                             or XML)
#
DefaultExt = TXT
#
# + ExtInfo +
# Description of the file format (ex: HyperText Markup Language
#                                  or eXtended Markup Language)
#
ExtInfo = Dragon UnPACKer Text Database (*.TXT)
#
# + Files +
# All the files used for the Template
#
HeaderFile = header.txt
FooterFile = footer.txt
VariableFile = variable.txt
#
# + Preview +
#
# This is a preview picture of the template.
# Must be 200x100 JPEG file.
#
Preview = preview.jpg
#
# + Include +
# Add all files you want to be included in your template (like Cascaded Style
# Sheets, Pictures, etc..).
#
# One file per IncludeFile keyword (100 IncludeFile max).
#
# Ex: IncludeFile = default.css
#     IncludeFile = title.gif
#     IncludeFile = drgsoft_logo.gif
#
# End of Text Database Template Source File
#
{/TSF}
