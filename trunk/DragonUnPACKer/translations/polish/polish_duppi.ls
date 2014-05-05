# Language Source File (for DLNGC v4.0)
# ============================================================================
#  Program: Duppi v3.3.4 (Dragon UnPACKer)
#    J�zyk: Polski (Polish)
#   Wersja: 5
#    Autor: Piotr Halama (Halamix2)
# ============================================================================
#
# This file is the model for translations of Duppi (Dragon UnPACKer Package
# Installer).
#
# Po prostu przet�umacz wszystko mi�dzy {BODY} i {/BODY}
#
# Potem skompiluj plik za pomoc� DLNGC i wrzu� wynikowy plik .LNG do
# podfolderu \Utils\ Dragon UnPACKera (razem z plikiem Duppi.exe).
#
# To select a new Language into Dragon UnPACKer run: DrgUnPACK5.exe /lng
# Or go into the General Options.
#
# NIE MODYFIKUJ �ADNYCH S��W KLUICZOWYCH - ZMIE� TYLKO RZECZY PO ZNAKU =
#
# If you have made a translation for your language send it to Alex Devilliers
# so it can be distributed along with the main program archive.
#
# You can reach Alex Devilliers by e-mail: translation@dragonunpacker.com
#                                  by ICQ: 1535372 (Elbereth)
#
# ============================================================================
# Informacje o tym t�umaczeniu
# ============================================================================
#
# wersja 1:
# Pierwsze wydanie
#
{LSF}
{HEADER}
#
# * Header *
#
# + Name +
# Write here the name that will appear in Dragon UnPACKer 4 dialog box for
# your language file (ex: English )
#
# Can be up to 80 characters
#
Name = Polski (Polish)
#
# + Author +
# Write here your name or alias (and any comment)
#
# Can be up to 80 characters
#
Author = Piotr Halama (Halamix2)
#
# + Email +
# Write here your email
#
# Can be up to 80 characters
#
Email = halamix2@o2.pl
#
# + URL +
# Write here the Internet URL where your file can be downloaded
#
# Can be up to 80 characters
#
URL = http://halamix2.cba.pl
#
# + Program Block (ProgramID & ProgramVer)
#
# DON'T CHANGE THIS UNLESS YOU KNOW WHAT YOU ARE DOING
#
#                                ID      Ver
# Duppi v3.0.0                   PI       1
# Duppi v3.1.0 - 3.1.3           PI       2
# Duppi v3.2.0 - 3.2.1           PI       3
# Duppi v3.3.0 - 3.3.3           PI       4
# Duppi v3.3.4                   PI       5
#
ProgramID = PI
ProgramVer = 5
#
# + IconFile +
# Path & FileName of the "icon" displayed with language name (ex: c:\test.bmp)
#
# This file must be a Windows Bitmap file 16x16 (Width=16 Height=16).
# The compiler will not test the file but the program will not display the
# icon if it is not a valid file.
#
# If you don't want to add an icon just comment out the line.
#
IconFile = flag_pl.bmp
#
# + OutFile +
# Path & FileName of the compiled file (ex: c:\test.lng)
#
OutFile = polish_duppi.lng
#
# + FontName +
# Name of the font to use to display this languages strings.
# (For ex Arial, Tahoma, etc..)
#
#FontName=Comic Sans MS
#
# + Compression +
# Compression type to use for data (language strings).
#
# Possible values:   0 = None (Default)
#                   99 = Zlib
#
Compression=99
#
{/HEADER}
#
# * Body *
#
# Each Language Keyword used in the program is followed by the string to
# appear in the program.
#
# Ex: TEST01=This is for testing purposes
#
# Each Language Keyword cannot be longer than 6 characters.
#
# Special words:
#  %n = New line
# Any other %k (where k can be any character but n) is a special keyword that
# will be replaced during Dragon UnPACKer runtime by a value.
#
# DON'T ADD/DELETE KEYWORDS UNLESS YOU KNOW WHAT YOU ARE DOING.
# THE PROGRAM WILL TEST FOR KEYWORDS AND WILL ABORT IF THERE IS AN ERROR.
#
{BODY}
PI0000=Wykryta wersja DUP5:
PI0001=Tytu�
PI0002=Autor
PI0003=Komentarz
PI0004=URL
PI0005=Informacje paczki
PI0006=Prosz� czeka�, trwa instalacja paczki...
PI0007=Ten program zainstaluje nast�puj�c� paczk� do folderu Dragon UnPACKer.
PI0008=Dragon UnPACKer 5 musi zosta� zamkni�ty przed kontynuacj� instalacji.
PI0009=Status:
PI0010=Oczekiwanie na u�ytkownika...
PI0011=Czy na pewno chcesz wyj�� ?
PI0012=B��d.. DUP5 jest uruchomiony..
PI0013=B��d Dragon UnPACKer 5 jest uruchomiony..%nZamknij i spr�buj ponownie.
PI0014=B��d Krytyczny.. Niewspierana wersja pliku paczki Dragon UnPACKer 5 (.D5P) [wersja %v]
PI0015=B��d Krytyczny.. To nie jest plik paczki Dragon UnPACKer 5 (.D5P)
PI0016=U�ycie: duppi <plik.d5p>%n%nTo zainstaluje paczk� plik.d5p do katalogu Dragon UnPACKer 5.
PI0017=Nie znaleziono pliku!%n%f
PI0018=Czytanie paczki...
PI0019=Nast�puj�cy plik ju� istnieje i jest nowszy lub taki sam jak plik kt�ry pr�bujesz zainstalowa�:%n%n%f%n%nObecna wersja: %1%nPlik w paczce: %2%n%nZainstalowa� mimo to?
PI0020=Nast�puj�cy plik ma z�e CRC. Ten plik b�dzie pomini�ty.%nJe�li pobra�e� plik, spr�buj ponownie.%n%n%f
PI0021=Nast�puj�cy plik ma z�y rozmiar. Ten plik b�dzie pomini�ty.%ne�li pobra�e� plik, spr�buj ponownie.%n%n%f
PI0022=Zainstalowano pomy�lnie %i plik(i/�w)...
PI0023=Instalacja przerwana pomy�lnie...
PI0024=Instalacja nieudana (%e plik(i/�w) da�y b��d)...
PI0025=Instalacja nieudana... zainstalowano pomy�lnie %i plik(i/�w)  i %e b��dy/�w...
PI0026=�cie�ka do Dragon UnPACKer 5 nie znaleziona.%nProsz� uruchomi� Dragon UnPACKer 5 przynajmniej raz przed ponown� pr�b�.
PI0027=Pomijanie...
PI0028=Kb
PI0029=Odczytywanie...
PI0030=Dekompresja...
PI0031=Zapisywanie...
PI0032=OK
PI0033=Wersja
PI0034=Ten program pozwala instalowa� paczki dla Dragon UnPACKer 5.
PI0035=Co chcesz zrobi� ?
PI0036=Szukaj w internecie nowych lub zaktualizowanych paczek i zainstaluj je.
PI0037=Info: Absolutnie �adne dane nie s� przesy�ane do strony internetowej oprogramowania Dragon Software.
PI0038=Opcje Proxy
PI0039=Zainstaluj  paczk� z dysku twardego:
PI0040=Wybierz paczk� do zainstalowania...
PI0041=Aby zainstalowa� ten plik Paczki Dragon UnPACKer 5 (D5P)potrzebujesz nowszej wersji Duppi.%nTwoja wersja Duppi: %y%nPotrzebna wersja Duppi: %v%n%nProsz� zaktualizowa� sw�j Dragon UnPACKer 5!
PI0042=Ta paczka nie mo�e by� zainstalowana przez twoj� wersj� Dragon UnPACKer.
PI0043=Nie mo�na zarejestrowa� %s.
PI0044=Z�e dane uzyskane z serwera aktualizacji!
PI0045=Nieznany folder docelowy!
PI0046=Aktualizacja Duppi udana!
PI0047=Nowa wersja Duppi jest dost�pna:%nTwoja wersja: %a%nDost�pna wersja: %b%nRozmiar aktualizacji: %s Kilobajty/�w%n%nCzy chcesz teraz aktualizowa� (Zalecane)?
PI0048=Poka� tak�e niestabilne (alpha/beta/RC)
PI0049=Brak URL dla aktualizacji Duppi!
PI0050=Nowa wersja Dragon UnPACKer jest dost�pna:%nTwoja wersja: %a%nDost�pna wersja: %b%nRozmiar aktualizacji: %s Kilobajty/�w%n%nCzy chcesz teraz aktualizowa� (Zalecane)?
PI0051=Brak URL dla aktualizacji Dragon UnPACKer!
PI0052=%s bajty/�w
PI0053=%s KiB
PI0054=Paczka %a...
PI0055=Szukanie blok�w...
PI0056=Odczytywanie bloku "%a"...
PI0057=wpisy
PI0058=nazwy
PI0059=zawarto��
PI0060=Instalacja pliku %a: %b
PI0061=Rejestracja OCX...
PI0062=Instalacja paczki pomy�lna.%nDuppi zrestartuje si� aby si� zaktualizowa�.
PI0063=Otrzymywanie informacji o paczce...
PI0064=Paczka %d
PI0065=Nast�puj�cy przestarza�y plik zosta� odnaleziony i zostanie usuni�ty:%n%n%f%n%n
PI0066=Wersja pliku: %1%nPrzestarza�e wersje: <= %2%n%n
PI0067=Wykonaj i usu� (zalecane)?
PI0068=Usuni�to!
PI0069=Wykryto niezgodno�� builda Dragon UnPACKer (%a) ostatnio uruchamiany (%b).%nMusisz uruchomi� Dragon UnPACKer 5 przynajmniej raz po aktualizacji.%n%nCzy chcesz uruchomi� go teraz (zalecane)?

PI3001=U�ywanie serwera %i: %d
PI3002=Rozmiar pliku nie jest prawid�owy! (%a <> %b)
PI3003=Sprawdzanie integralno�ci pliku...
PI3004=Brak integralno�ci pliku! (%a <> %b)
PI3005=Nieoczekiwany wyj�tek %a: %b

PIE401=Nieznana funkcja haszuj�ca: %h
PIE402=Szukanie pliku zako�czone niepowodzeniem (%a <> %b)
PIE403=B��d podczas odczytu pliku (%a bytes <> %b bytes)
PIE404=B��d podczas dekompresji %a (%b bytes <> %c bytes)
PIE405=Niewspierana kompresja (%a)
PIE406=Warto�� hash nie pasuje do bloku (%a <> %b)
PIE407=Szukanie bloku zako�czone niepowodzeniem (%a <> %b)
PIE408=B��d podczas odczytu bloku (%a bytes <> %b bytes)
PIE409=B��d podczas odbierania informacji:
PIE410=B��d podczas odbierania bannera:
PIE411=B��d podczas odbierania danych z bloku "%a":

PII001=Tytu�
PII002=Twoja Wersja
PII003=Dost�pna Wersja
PII004=Opis
PII005=Rozmiar
PII011=Poka� aktualizacje:
PII012=Wtyczki
PII013=T�umaczenia
PII021=Obecna wersja stabilna :
PII022=Obecna wersja niestabilna :
PII030=T�umaczenie
PII031=Rewizja
PII032=Autor
PII100=lista aktualizacji
PII101=Pobieranie %f...
PII102=Pobieranie %f (%b bajty/�w odebrano)
PII103=Pomy�lnie odebrano %f (%b bajty/�w)
PII104=B��d: %c (%d)
PII105=Pomy�lny kontakt z serwerem!
PII106=-Brak opisu-
PII107=Nowa wersja Dragon UnPACKer jest dost�pna do pobrania.%n%nNowa wersja: %v%nKomentarz: %c%n%nCzy chcesz przej�� na oficjaln� stron� www aby j� pobra�?
PII108=Dost�pne %p Wtyczki(ek) i %t t�umaczenia(e�)!

PII200=�adna aktualizacja nie mog�a zosta� pobrana.%nProgram zako�czy swoje dzia�anie.

PIEM01=B��d po��czenia bazy danych. Prosz� spr�bowa� p�niej!
PIEM10=B��d podczas odbierania informacji o najnowszej stabilnej wersji rdzenia!
PIEM11=B��d podczas odbierania informacji o najnowszej niestabilnej wersji rdzenia!
PIEM12=B��d podczas odbierania informacji o stabilnej wersji rdzenia!
PIEM13=B��d podczas odbierania informacji o niestabilnej wersji rdzenia!
PIEM20=B��d podczas odbierania informacji o twojej wersji!
PIEM30=B��d podczas odbierania dost�pnych stabilnych wtyczek konwertera!
PIEM31=B��d podczas odbierania dost�pnych stabilnych wtyczek sterownika!
PIEM32=B��d podczas odbierania dost�pnych stabilnych wtyczek HyperRipper!
PIEM33=B��d podczas odbierania dost�pnych t�umacze�!
PIEM40=B��d podczas odbierania listy serwer�w!
PIEM41=B��d podczas odbierania dost�pnych stabilnych+niestabilnych wtyczek sterownika!
PIEM42=B��d podczas odbierania dost�pnych stabilnych+niestabilnych wtyczek konwertera!
PIEM43=B��d podczas odbierania dost�pnych stabilnych+niestabilnych wtyczek HyperRipper!
PIEM60=B��d podczas odbierania informacji o najnowszej wersji Duppi!
PIEP01=Z�y parametr! Je�li nie uruchamia�e� Dragon UnPACKer zr�b to i uruchom potem ponownie Duppi.
PIEP02=Serwer nie rozpoznaje twojej wersji Dragon UnPACKer...
PIEUNK=Nieznany b��d serwera: "%e"

PIP000=Konfiguracja proxy
PIP001=Proxy:
PIP002=Port proxy:
PIP003=Proxy potrzebuje Nazwy u�ytkownika/Has�a:
PIP004=Nazwa u�ytkownika:
PIP005=Has�o:

BUTADD=Dodaj
BUTCAN=Anuluj
BUTCLO=Zamknij
BUTCNV=Konwertuj
BUTCON=Kontynuuj
BUTDEL=Usu�
BUTDET=Wi�cej
BUTDIR=Nowy folder
BUTEDT=Edytuj
BUTGO=Id�!
BUTINS=Instaluj
BUTNEX=Dalej
BUTOK=OK
BUTPAL=Dodaj Palet�
BUTREF=Od�wie�
BUTREM=Usu�
BUTSCH=Szukaj

{/BODY}
#
# End of Language Source File
#
{/LSF}
