# Language Source File (for DLNGC v4.0)
# ============================================================================
#  Program: Duppi v3.3.4 (Dragon UnPACKer)
#    Jêzyk: Polski (Polish)
#   Wersja: 5
#    Autor: Piotr Halama (Halamix2)
# ============================================================================
#
# This file is the model for translations of Duppi (Dragon UnPACKer Package
# Installer).
#
# Po prostu przet³umacz wszystko miêdzy {BODY} i {/BODY}
#
# Potem skompiluj plik za pomoc¹ DLNGC i wrzuæ wynikowy plik .LNG do
# podfolderu \Utils\ Dragon UnPACKera (razem z plikiem Duppi.exe).
#
# To select a new Language into Dragon UnPACKer run: DrgUnPACK5.exe /lng
# Or go into the General Options.
#
# NIE MODYFIKUJ ¯ADNYCH S£ÓW KLUICZOWYCH - ZMIEÑ TYLKO RZECZY PO ZNAKU =
#
# If you have made a translation for your language send it to Alex Devilliers
# so it can be distributed along with the main program archive.
#
# You can reach Alex Devilliers by e-mail: translation@dragonunpacker.com
#                                  by ICQ: 1535372 (Elbereth)
#
# ============================================================================
# Informacje o tym t³umaczeniu
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
PI0001=Tytu³
PI0002=Autor
PI0003=Komentarz
PI0004=URL
PI0005=Informacje paczki
PI0006=Proszê czekaæ, trwa instalacja paczki...
PI0007=Ten program zainstaluje nastêpuj¹c¹ paczkê do folderu Dragon UnPACKer.
PI0008=Dragon UnPACKer 5 musi zostaæ zamkniêty przed kontynuacj¹ instalacji.
PI0009=Status:
PI0010=Oczekiwanie na u¿ytkownika...
PI0011=Czy na pewno chcesz wyjœæ ?
PI0012=B³¹d.. DUP5 jest uruchomiony..
PI0013=B³¹d Dragon UnPACKer 5 jest uruchomiony..%nZamknij i spróbuj ponownie.
PI0014=B³¹d Krytyczny.. Niewspierana wersja pliku paczki Dragon UnPACKer 5 (.D5P) [wersja %v]
PI0015=B³¹d Krytyczny.. To nie jest plik paczki Dragon UnPACKer 5 (.D5P)
PI0016=U¿ycie: duppi <plik.d5p>%n%nTo zainstaluje paczkê plik.d5p do katalogu Dragon UnPACKer 5.
PI0017=Nie znaleziono pliku!%n%f
PI0018=Czytanie paczki...
PI0019=Nastêpuj¹cy plik ju¿ istnieje i jest nowszy lub taki sam jak plik który próbujesz zainstalowaæ:%n%n%f%n%nObecna wersja: %1%nPlik w paczce: %2%n%nZainstalowaæ mimo to?
PI0020=Nastêpuj¹cy plik ma z³e CRC. Ten plik bêdzie pominiêty.%nJeœli pobra³eœ plik, spróbuj ponownie.%n%n%f
PI0021=Nastêpuj¹cy plik ma z³y rozmiar. Ten plik bêdzie pominiêty.%neœli pobra³eœ plik, spróbuj ponownie.%n%n%f
PI0022=Zainstalowano pomyœlnie %i plik(i/ów)...
PI0023=Instalacja przerwana pomyœlnie...
PI0024=Instalacja nieudana (%e plik(i/ów) da³y b³¹d)...
PI0025=Instalacja nieudana... zainstalowano pomyœlnie %i plik(i/ów)  i %e b³êdy/ów...
PI0026=Œcie¿ka do Dragon UnPACKer 5 nie znaleziona.%nProszê uruchomiæ Dragon UnPACKer 5 przynajmniej raz przed ponown¹ prób¹.
PI0027=Pomijanie...
PI0028=Kb
PI0029=Odczytywanie...
PI0030=Dekompresja...
PI0031=Zapisywanie...
PI0032=OK
PI0033=Wersja
PI0034=Ten program pozwala instalowaæ paczki dla Dragon UnPACKer 5.
PI0035=Co chcesz zrobiæ ?
PI0036=Szukaj w internecie nowych lub zaktualizowanych paczek i zainstaluj je.
PI0037=Info: Absolutnie ¿adne dane nie s¹ przesy³ane do strony internetowej oprogramowania Dragon Software.
PI0038=Opcje Proxy
PI0039=Zainstaluj  paczkê z dysku twardego:
PI0040=Wybierz paczkê do zainstalowania...
PI0041=Aby zainstalowaæ ten plik Paczki Dragon UnPACKer 5 (D5P)potrzebujesz nowszej wersji Duppi.%nTwoja wersja Duppi: %y%nPotrzebna wersja Duppi: %v%n%nProszê zaktualizowaæ swój Dragon UnPACKer 5!
PI0042=Ta paczka nie mo¿e byæ zainstalowana przez twoj¹ wersjê Dragon UnPACKer.
PI0043=Nie mo¿na zarejestrowaæ %s.
PI0044=Z³e dane uzyskane z serwera aktualizacji!
PI0045=Nieznany folder docelowy!
PI0046=Aktualizacja Duppi udana!
PI0047=Nowa wersja Duppi jest dostêpna:%nTwoja wersja: %a%nDostêpna wersja: %b%nRozmiar aktualizacji: %s Kilobajty/ów%n%nCzy chcesz teraz aktualizowaæ (Zalecane)?
PI0048=Poka¿ tak¿e niestabilne (alpha/beta/RC)
PI0049=Brak URL dla aktualizacji Duppi!
PI0050=Nowa wersja Dragon UnPACKer jest dostêpna:%nTwoja wersja: %a%nDostêpna wersja: %b%nRozmiar aktualizacji: %s Kilobajty/ów%n%nCzy chcesz teraz aktualizowaæ (Zalecane)?
PI0051=Brak URL dla aktualizacji Dragon UnPACKer!
PI0052=%s bajty/ów
PI0053=%s KiB
PI0054=Paczka %a...
PI0055=Szukanie bloków...
PI0056=Odczytywanie bloku "%a"...
PI0057=wpisy
PI0058=nazwy
PI0059=zawartoœæ
PI0060=Instalacja pliku %a: %b
PI0061=Rejestracja OCX...
PI0062=Instalacja paczki pomyœlna.%nDuppi zrestartuje siê aby siê zaktualizowaæ.
PI0063=Otrzymywanie informacji o paczce...
PI0064=Paczka %d
PI0065=Nastêpuj¹cy przestarza³y plik zosta³ odnaleziony i zostanie usuniêty:%n%n%f%n%n
PI0066=Wersja pliku: %1%nPrzestarza³e wersje: <= %2%n%n
PI0067=Wykonaj i usuñ (zalecane)?
PI0068=Usuniêto!
PI0069=Wykryto niezgodnoœæ builda Dragon UnPACKer (%a) ostatnio uruchamiany (%b).%nMusisz uruchomiæ Dragon UnPACKer 5 przynajmniej raz po aktualizacji.%n%nCzy chcesz uruchomiæ go teraz (zalecane)?

PI3001=U¿ywanie serwera %i: %d
PI3002=Rozmiar pliku nie jest prawid³owy! (%a <> %b)
PI3003=Sprawdzanie integralnoœci pliku...
PI3004=Brak integralnoœci pliku! (%a <> %b)
PI3005=Nieoczekiwany wyj¹tek %a: %b

PIE401=Nieznana funkcja haszuj¹ca: %h
PIE402=Szukanie pliku zakoñczone niepowodzeniem (%a <> %b)
PIE403=B³¹d podczas odczytu pliku (%a bytes <> %b bytes)
PIE404=B³¹d podczas dekompresji %a (%b bytes <> %c bytes)
PIE405=Niewspierana kompresja (%a)
PIE406=Wartoœæ hash nie pasuje do bloku (%a <> %b)
PIE407=Szukanie bloku zakoñczone niepowodzeniem (%a <> %b)
PIE408=B³¹d podczas odczytu bloku (%a bytes <> %b bytes)
PIE409=B³¹d podczas odbierania informacji:
PIE410=B³¹d podczas odbierania bannera:
PIE411=B³¹d podczas odbierania danych z bloku "%a":

PII001=Tytu³
PII002=Twoja Wersja
PII003=Dostêpna Wersja
PII004=Opis
PII005=Rozmiar
PII011=Poka¿ aktualizacje:
PII012=Wtyczki
PII013=T³umaczenia
PII021=Obecna wersja stabilna :
PII022=Obecna wersja niestabilna :
PII030=T³umaczenie
PII031=Rewizja
PII032=Autor
PII100=lista aktualizacji
PII101=Pobieranie %f...
PII102=Pobieranie %f (%b bajty/ów odebrano)
PII103=Pomyœlnie odebrano %f (%b bajty/ów)
PII104=B³¹d: %c (%d)
PII105=Pomyœlny kontakt z serwerem!
PII106=-Brak opisu-
PII107=Nowa wersja Dragon UnPACKer jest dostêpna do pobrania.%n%nNowa wersja: %v%nKomentarz: %c%n%nCzy chcesz przejœæ na oficjaln¹ stronê www aby j¹ pobraæ?
PII108=Dostêpne %p Wtyczki(ek) i %t t³umaczenia(eñ)!

PII200=¯adna aktualizacja nie mog³a zostaæ pobrana.%nProgram zakoñczy swoje dzia³anie.

PIEM01=B³¹d po³¹czenia bazy danych. Proszê spróbowaæ póŸniej!
PIEM10=B³¹d podczas odbierania informacji o najnowszej stabilnej wersji rdzenia!
PIEM11=B³¹d podczas odbierania informacji o najnowszej niestabilnej wersji rdzenia!
PIEM12=B³¹d podczas odbierania informacji o stabilnej wersji rdzenia!
PIEM13=B³¹d podczas odbierania informacji o niestabilnej wersji rdzenia!
PIEM20=B³¹d podczas odbierania informacji o twojej wersji!
PIEM30=B³¹d podczas odbierania dostêpnych stabilnych wtyczek konwertera!
PIEM31=B³¹d podczas odbierania dostêpnych stabilnych wtyczek sterownika!
PIEM32=B³¹d podczas odbierania dostêpnych stabilnych wtyczek HyperRipper!
PIEM33=B³¹d podczas odbierania dostêpnych t³umaczeñ!
PIEM40=B³¹d podczas odbierania listy serwerów!
PIEM41=B³¹d podczas odbierania dostêpnych stabilnych+niestabilnych wtyczek sterownika!
PIEM42=B³¹d podczas odbierania dostêpnych stabilnych+niestabilnych wtyczek konwertera!
PIEM43=B³¹d podczas odbierania dostêpnych stabilnych+niestabilnych wtyczek HyperRipper!
PIEM60=B³¹d podczas odbierania informacji o najnowszej wersji Duppi!
PIEP01=Z³y parametr! Jeœli nie uruchamia³eœ Dragon UnPACKer zrób to i uruchom potem ponownie Duppi.
PIEP02=Serwer nie rozpoznaje twojej wersji Dragon UnPACKer...
PIEUNK=Nieznany b³¹d serwera: "%e"

PIP000=Konfiguracja proxy
PIP001=Proxy:
PIP002=Port proxy:
PIP003=Proxy potrzebuje Nazwy u¿ytkownika/Has³a:
PIP004=Nazwa u¿ytkownika:
PIP005=Has³o:

BUTADD=Dodaj
BUTCAN=Anuluj
BUTCLO=Zamknij
BUTCNV=Konwertuj
BUTCON=Kontynuuj
BUTDEL=Usuñ
BUTDET=Wiêcej
BUTDIR=Nowy folder
BUTEDT=Edytuj
BUTGO=IdŸ!
BUTINS=Instaluj
BUTNEX=Dalej
BUTOK=OK
BUTPAL=Dodaj Paletê
BUTREF=Odœwie¿
BUTREM=Usuñ
BUTSCH=Szukaj

{/BODY}
#
# End of Language Source File
#
{/LSF}
