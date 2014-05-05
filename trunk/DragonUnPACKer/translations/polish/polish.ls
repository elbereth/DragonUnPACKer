# Language Source File (for DLNGC v4.0)
# ============================================================================
#  Program: Dragon UnPACKer v5.7.0 Beta
#    J�zyk: Polski (Polish)
#   Wersja: 16
#    Autor: Piotr Halama (Halamix2)
# ============================================================================
#
# This file is the model for translations of Dragon UnPACKer.
#
# Po prostu przet�umacz wszystko mi�dzy {BODY} i {/BODY}
#
# Then compile the file with DLNGC and put the resulting .LNG file into the
# \Data\ sub-directory of Dragon UnPACKer.
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
# wersja 16:
# Dodano OPT853, LOG020, LOG021, LOG022, LOG023
# Usuni�to LOG001, 11TH01, 11TH02, 11TH03, 11TH04, 11TH10, 11TH11, 11TH12, 11TH13, 11TH14
#
# wersja 15:
# Dodano LSTCP5, LSTCP6, OPT040, OPT041 and OPT129
#
# wersja 14:
# Dodano LOG505, LOG506, LOG507, OPT127, OPT128, OPT812, POP2S6 and POP3S4
#
# wersja 13:
# Dodano HR2031, HR4061, HR4062 and HR4063
#
# wersja 12:
# Dodano missing preview keywords
# Usuni�to wpisy Duppi (teraz w osobnym pliku)
#
# wersja 11a:
# Naprawiono brakuj�ce s�owo kluczowe w LOG005
#
# wersja 11:
# Dodano s�owa kluczowe podgl�du
#
# wersja 10:
# Dodano nowe opcje.
#
# wersja 9a:
# Dodano brakuj�ce s�owo kluczowe w OPT203
#
# wersja 9:
# Dodano ci�gi wtyczki UT Package driver.
# Dodano ci�gi Dziennika.
# Dodano ci�gi Duppi.
#
# wersja 8:
# Zmieniono kilka komunikat�w  b��d�w.
# wersja 7:
# Dodano ci�gi nowych Opcji (priorytet sterownik�w itp.).
# Dodano ci�gi Dziennika.
#
# wersja 6a:
# Dodano FontName header option.
#
# wersja 6: (see english-rc3-changes.txt for changes since wersja 5)
# Fixed two missing HyperRipper plugin error strings (ERRH01 and ERRH02)
# Dodano some convert plugin strings.
# Dodano new about box strings.
# Dodano 11th Hour driver plugin strings.
#
# wersja 5: (see english-rc2-changes.txt for changes since wersja 4)
# Dodano Use HyperRipper if all plugins fails option string.
# Fixed some leading ' characters.
#
# wersja 4: (see english-rc1-changes.txt for changes since wersja 3)
# Dodano Error handling string.
# Dodano HyperRipper v5.0a strings.
# Dodano Convert pic/tex plugin palette convertion strings.
#
# wersja 3: (see english-beta3-changes.txt for changes since wersja 2)
#            (no changes between beta3 and beta4)
# Dodano Create List strings.
# Dodano Error handling strings.
# Dodano Duppi v2 strings.
# Dodano 1 option string.
#
# wersja 2: (see english-beta2-changes.txt for changes since wersja 1)
# Dodano 1 Duppi string.
# Dodano all HyperRipper translation labels.
#
# wersja 1:
# First wersja.
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
# Dragon UnPACKer v5.0.0 Beta 1  UP       1
# Dragon UnPACKer v5.0.0 Beta 2  UP       2
# Dragon UnPACKer v5.0.0 Beta 3  UP       3
# Dragon UnPACKer v5.0.0 Beta 4  UP       3
# Dragon UnPACKer v5.0.0 RC1     UP       4
# Dragon UnPACKer v5.0.0 RC2     UP       5
# Dragon UnPACKer v5.0.0 RC3     UP       6
# Dragon UnPACKer v5.1.0         UP       7
# Dragon UnPACKer v5.1.2         UP       8
# Dragon UnPACKer v5.2.0         UP       9
# Dragon UnPACKer v5.2.0a        UP       9
# Dragon UnPACKer v5.2.0b        UP       9
# Dragon UnPACKer v5.3.0         UP       9
# Dragon UnPACKer v5.3.1         UP       9
# Dragon UnPACKer v5.3.2         UP      10
# Dragon UnPACKer v5.3.3 Beta    UP      11
# Dragon UnPACKer v5.4.0         UP      12
# Dragon UnPACKer v5.5.1 Beta    UP      13
# Dragon UnPACKer v5.6.1         UP      14
# Dragon UnPACKer v5.6.2         UP      15
# Dragon UnPACKer v5.7.0 Beta    UP      16
#
ProgramID = UP
ProgramVer = 16
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
OutFile = polish.lng
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
MNU1=&Plik
MNU1S1=&Otw�rz...
MNU1S2=&Zamknij
MNU1S3=&Wyjd�
MNU1S4=&Otw�rz ponownie...
MNU2=&Opcje
MNU2S1=Podstawowe
MNU2S2=Sterowniki
MNU2S3=Wygl�d/Ikony
MNU2S4=Typy Plik�w
MNU2S5=Konwersja
MNU2S6=Wtyczki
MNU2S7=Zaawansowane
MNU2S8=Dziennik
MNU2S9=Podgl�d
MNU3=&?
MNU3S1=o
MNU3S2=Szukaj nowej wersji w internecie...
MNU4=&Edytuj
MNU4S1=&Szukaj
MNU5=&Narz�dzia
MNU5S1=Stw�rz list� pozycji...
LSTCP1=Plik
LSTCP2=Rozmiar (Bajty)
LSTCP3=Offset
LSTCP4=Opis
LSTCP5=Dane X
LSTCP6=Dane Y
STAT10=obiekt(y/�w)
STAT20=bajt(y/�w)

ABT001=Program freeware
ABT002=Skontaktuj si� ze mn�:
ABT003=Strona internetowa:
ABT004=Dragon UnPACKer korzysta z:
ABT005=Betatesterzy:
ABT006=Specjalne podzi�kowania dla wszystkich t�umaczy:

INFO99=Informacje
INFO00=Sterownik
INFO01=Nazwa:
INFO02=Autor:
INFO03=Komentarz:
INFO04=Wersja:
INFO05=E-mail:
INFO10=Plik
INFO11=Format:
INFO12=Pozycje:
INFO13=Rozmiar:
INFO14=Czas �adowania:
INFO20=Nazwa wtyczki
INFO21=Wersja
INFO22=Zaawansowane Informacje
INFO23=Wer.Wewn.:

SCHTIT=Szukaj
SCHGRP=Opcje
SCH001=Uwzgl�dniaj wielko�� liter
SCH002=Wszystkie pliki
SCH003=Tylko obecny folder
SCH004=znaleziono obiekt(y/�w)
DIRTIT=Wybierz folder...
POP1S1=Wypakuj plik do...
PSUB01=Bez konwersji
PSUB02=Konwertuj do %d
POP1S2=Wypakuj pliki do...
POP1S3=Otw�rz
POP1S4=Bez konwersji
POP2S1=Wypakuj wszystkie...
POP2S2=Wypakuj pod-foldery...
POP2S3=Informacje
POP2S4=Rozwi� wszystkie
POP2S5=Zwi� wszystkie
POP2S6=Wypakuj pod-foldery do "%d"...
POP3S1=Poka� dziennik
POP3S2=Ukryj dziennik
POP3S3=Wyczy�� dziennik
POP3S4=kopiuj dziennik do schowka
POP4S1=Ukryj podgl�d
POP4S2=Poka� podgl�d
POP5S1=Tryb wy�wietlania
POP5S2=Oryginalny rozmiar z suwakiem (je�li potrzeba)
POP5S3=Skurczone/Rozci�gni�te do rozmiaru panelu
POP5S4=Opcje podgl�du...
OPTTIT=Konfiguracja
OPT000=Opcje zaawansowane
OPT010=Folder tymczasowy
OPT011=U�yj automatycznie wykrytego folderu tymczasowego
OPT012=U�yj wybranego folderu tymczasowego:
OPT013=Wybierz folder tymczasowy...
OPT020=Opcje dla "Otw�rz plik"
OPT021=Zaznacz "Wypakuj plik... Bez konwersji" jako domy�ln� opcj�
OPT030=Rozmiar bufora
OPT031=Wybierz rozmiar bufora dla wypakowywania:
OPT032=Bez bufora / Nie zalecane! (Bardzo wolne)
OPT033=%d bajt(y/�w)
OPT034=%d kilobajt(y/�w)
OPT035=%d Megabajt(y/�w)
OPT036=Domy�lne
OPT040=Integralno�� wej�cia wtyczek sterownik�w
OPT041=Nie ignoruj plik�w z rozmiarem = 0 bajt�w (nie zalecane)
OPT100=Podstawowe opcje
OPT110=J�zyk
OPT111=Szukaj dost�pnych t�umacze�...
OPT120=Opcje
OPT121=Nie wy�wietlaj ekranu powitalnego przy uruchomieniu
OPT122=Zezw�l tylko na jedno jednoczesne uruchomienie programu
OPT123=Automatyczne wykrywanie rozszerzenia plik�w (przy otwieraniu)
OPT124=Pobierz ikony z rejestru Windows (mo�e by� wolniejsze)
OPT125=U�yj HyperRipper je�li �adna wtyczka nie mo�e otworzy� pliku
OPT126=Poka� dziennik uruchomienia
OPT127=Automatycznie rozwi� foldery przy otwieraniu
OPT128=Zachowaj wybrany typ pliku w oknie otwierania
OPT129=Wy�wietlaj dodatkowe pola zaawansowane na li�cie pozycji (nie zalecane)
OPT191=Te wtyczki obs�uguj� konwertowanie format�w plik�w przy wypakowywaniu lub podgl�dzie plik�w.Przyk�ad: Konwertuje tekstury z formatu .ART do .BMP
OPT192=Te wtyczki obs�uguj� otwieranie typ�w plik�w tak aby Dragon UnPACKer m�g� je przeszukiwa�. Je�li plik jest niewspierany to znaczy �e �aden sterownik nie mo�� go za�adowa�. HyperRipper obs�uguje pliki przy u�yciu innych wtyczek (zobacz poni�ej).
OPT193=Te wtyczki obs�uguj� formaty plik�w do skanowania w HyperRipper (np: MPEG Audio, BMP, itp..)
OPT200=Sterowniki
OPT201=O...
OPT202=Ustawienia
OPT203=Wtyczki sterownik�w:
OPT210=Informacje sterownik�w
OPT220=Priorytet :
OPT221=Od�wie� list�
OPT300=Wygl�d/Ikony
OPT310=Informacje o wygl�dzie
OPT320=Motywy wygl�du (pliki):
OPT330=Opcje wygl�du
OPT331=menu i pasek narz�dzi XP-like
OPT400=Typy plik�w
OPT401=Wybierz rozszerzenia kt�re Dragon UnPACKer powinien otworzy� kiedy klikniesz je w Eksploratorze:
OPT402=Obecnie powi�zana ikona:
OPT411=�adne
OPT412=Wszystkie
OPT420=Sprawd� powi�zania przy uruchamianiu
OPT430=U�yj zewn�trznej ikony
OPT431=Wybierz plik ikony dla powi�za� z Dagon UnPACKer 5...
OPT432=Ikony
OPT440=Zmie� tekst powi�zania:
OPT450=Dodaj rozszerzenie pow�oki Windows Explorer "%d"
OPT451=Otw�rz za pomoc� Dragon UnPACKer 5
OPT500=Konwertuj
OPT501=Wtyczki konwertera:
OPT510=Informacje wtyczki
OPT600=Wtyczki
OPT701=Wtyczki HyperRipper:
OPT710=Informacje wtyczki
OPT800=Dziennik uruchomienia
OPT810=Opcje dziennika uruchomienia
OPT811=Poka� dziennik uruchomienia w g��wnym oknie
OPT812=Wyczy�� podczas otwierania nowego pliku
OPT840=Poziom wys�awiania
OPT841=Wybierz ilo�� wy�wietlanych informacji :
OPT850=Niski - ma�o informacji
OPT851=�redni - Du�a dawka informacji
OPT852=Wysoki - Bardzo du�o informacji!
OPT853=Debugowanie
OPT900=Podgl�d
OPT910=Opcje podgl�du
OPT911=W��cz podgl�d
OPT920=Limit rozmiaru podgl�du
OPT921=Nie ograniczaj rozmiaru plik�w do podgl�du
OPT922=Ograniczaj rozmiar plik�w do podgl�du (Zalecane)
OPT923=Limit:
OPT924=Bardzo niski
OPT925=Niski
OPT926=�redni (Zalecane)
OPT927=Wysoki
OPT928=Bardzo wysoki
OPT940=Tryb wy�wietlania podgl�du

OPEN00=Otw�rz plik...
ALLCMP=Kompatybilne pliki
ALLFIL=Wszystkie pliki
XTRCAP=Wypakowywanie w trakcie...
XTRSTA=Wypakowywanie %f...
BUTOK=OK
BUTGO=Id�!
BUTSCH=Szukaj
BUTDIR=Nowy Folder
BUTDET=Wi�cej
BUTDEL=Usu�
BUTADD=Dodaj
BUTCNV=Konwertuj
BUTCAN=Anuluj
BUTINS=Instaluj
BUTCLO=Zamknij
BUTCON=Kontynuuj
BUTNEX=Dalej
BUTPAL=Dodaj Palet�
BUTREF=Od�wie�
BUTREM=Usu�
BUTEDT=Edytuj
HYPAD=Ta wersja potrafi tylko szuka� plik�w d�wi�kowych WAVE.
HYPFIN=Typ %t (Offset %o / %s bajty/�w)
HYPOPN=Wybierz plik do przeskanowania...
CNV000=Konwersja obrazka/tekstury 
CNV001=Paleta
CNV010=Info:%nU�yj okienka konfiguracji aby zarz�dza�%n(dodawa� lub usuwa�) paletami.
CNV100=Dodaj now� palet�
CNV101=�r�d�o:
CNV102=Nazwa:
CNV103=Autor:
CNV104=Format:
CNV110=Raw binarna 768bajtowa paleta
CNV120=Nieznane
CNV900=B��d podczas konwertowania palety:%n%nPlik �r�d�owy: %f%nFormat �r�d�a: %t%n%nB��d: %e%n%nNie mo�na doda� palety.
CNV901=Paleta przekonwertowana pomy�lnie!%nTeraz mo�esz wybra� j� z listy.
CNV990=Nazwa palety ju� istnieje.
CNV991=Format nieznany (spr�buj zmieni� format).
CNV992=Czy na pewno chcesz usun�� palet�?

TLD001=Odczytywanie %f...
TLD002=Pozyskiwanie danych...
TLD003=Parsowanie i wy�wietlanie folderu g��wnego...

HR0000=O...
HR0001=HyperRipper pozwala poszuka� "standardowych" typ�w plik�w%nw innych plikach, kt�re nie s� bezpo�rednio wsperane przez Dragon UnPACKer.
HR0002=UWAGA: Tylka dla zaawansowanych u�ytkownik�w!
HR0003=Za�adowane wtyczki:
HR0004=Wszystkich wspieranych format�w:
HR1000=Szukaj
HR1001=�r�d�o:
HR1002=Utw�rz Plik HyperRipper (HRF):
HR1003=Anuluj / Stop
HR1011=Rozmiar bufora:
HR1012=Rozmiar rollback:
HR1013=Pr�dko�� szukania:
HR1014=Znaleziono:
HR2000=Formaty
HR2011=Format
HR2012=Typ
HR2021=Ustawienia
HR2022=Wszystko / Nic
HR2031=Wy��cz formaty plik�w kt�re mog� wyszuka� fa�szywy alarm
HR3000=Plik HyperRipper
HR3010=Do��cz nast�puj�ce informacje:
HR3011=Tytu�:
HR3012=URL:
HR3020=Wersja HRF
HR3021=Wersja
HR3030=Opcje
HR3031=Ustaw IDentyfikator programu na anonimowy
HR3032=Nie ustawiaj wersji programu
HR3033=Maksymalna d�ugo�� nazwy:
HR3034=%c znaki/�w
HR3035=Kompatybilne z wersjami:
HR3036=%v i nowsze
HR4000=Zaawansowane
HR4010=Pami�� bufora
HR4011=Kilobajty/�w
HR4012=bajty/�w
HR4020=Pami�� rollback
HR4021=Bez Rollback (nie zalecane)
HR4022=Domy�lny Rollback (128 bajt�w)
HR4023=Du�y Rollback (1/4 bufora)
HR4024=Ogromny Rollback (1/2 bufora)
HR4030=Formatowanie wpis�w
HR4031=Stw�rz foldery u�ywaj�c typ�w podanych przez wtyczk�
HR4050=Nazywanie
HR4051=Automatyczne
HR4052=W�asne
HR4053=Przyk�ad
HR4061=Automatyczny start szukania kiedy nieznany typ pliku
HR4062=Automatycznie zamknij HyperRipper kiedy szukanie jest zako�czone i zosta�y znalezione wpisy
HR4063=Ustaw rozmiar bufora
HRLEGF=nazwa pliku
HRLEGN=numer
HRLEGX=rozszerzenie
HRLEGO=offset (Dec)
HRLEGH=offset (Hex)
HRLG01=Nie wybrano format�w...
HRLG02=Nie odnaleziono pliku %f!
HRLG03=Otwieranie %f...
HRLG04=Gotowe!
HRLG05=Lokowanie zasob�w...
HRLG06=Skanowanie pliku na podane formaty...
HRLG07=Nie mo�na odczyta� %b bajt�w z pliku...
HRLG08=Znaleziono %e @ %a (%s bajty/�w)
HRLG09=Przeskanowano %s w %t sekund!
HRLG10=bajt�w
HRLG11=KB
HRLG12=MB
HRLG13=GB
HRLG14=Zapisywanie HRF...
HRLG15=Wy�wietlanie wyniku w Dragon UnPACKer...
HRLG16=B��d podczas skanowania... Anulowanie...
HRLG17=Uwalnianie zasob�w...
HRLG18=B��d!
HRTYP0=Nieznany
HRTYP1=Audio
HRTYP2=Wideo
HRTYP3=Obraz
HRTYPM=Inne
HRTYPE=Typ (%i)
HRD000=Opcje MPEG Audio
HRD100=Formaty MPEG Audio do przeszukania
HRD101=Nieoficjalne
HRD200=Limituj
HRD211=Minimalna liczba klatek:
HRD212=Maksymalna liczba klatek:
HRD213=klatek
HRD221=Minimalny rozmiar:
HRD222=Maksymalny rozmiar:
HRD223=bajt(y/�w)
HRD300=Specjalne
HRD301=Szukaj (i u�ywaj) Xing VBR header
HRD302=Szukaj ID3Tag v1.0/1.1

LST000=Utw�rz list�
LST001=Sortuj
LST100=Szablon
LST101=Wersja:
LST102=Autor:
LST103=Email:
LST104=URL:
LST200=Lista
LST201=Wybrane wpisy
LST202=Wszystkie wpisy
LST203=Wybrany folder
LST204=Do��cz podfoldery
LST300=Sortuj wed�ug
LST301=Nazwy
LST302=Rozmiaru
LST303=Offset
LST304=Odwr��
LST400=Uwaga: Sortowanie spowolni tworzenie listy...
LST500=Zapisz list� do...
LST501=Otrzymywanie elementu Header z szablonu...
LST502=Otrzymywanie elementu Footer z szablonu...
LST503=Otrzymywanie elementu Variable z szablonu...
LST504=Otrzymywanie wpis�w...
LST505=Sortowanie %v wpis�w...
LST506=Przetwarzanie %v wpis�w... %p%
LST507=Zapisywanie pliku listy...
LST508=Otrzymywanie plik�w towarzysz�cych z szablonu...
LST509=Gotowe!

11TH05=Status wtyczki: %s%n(W��czona oznacza, �e mo�esz otwiera� pliki)%n(Wy��czona oznacza, �e musisz zaimportowa� pliki GJD.GJD i DIR.RL)
11TH06=Wy��czona
11TH07=W��czona

DUT100=Konfiguracja
DUT101=Biblioteka
DUT110=ID
DUT111=�cie�ka
DUT112=Wskaz�wka gry
DUT113=DA?
DUT114=GID
DUT201=Z kt�rej gry otwierasz paczk� ?
DUT202=Nie pytaj ponownie dla tej �cie�ki
DUT203=- Nieznane / Inne -

EX=Plik %e
EXANIM=Animacja (%e)
EXART=Paczka Art'�w (Tekstury)
EXBIN=Dane (%e)
EXCFG=Konfiguracja (%e)
EXDLL=Dynamic Link Library (DLL)
EXFIRE=Tekstura Ognia (Dynamiczna)
EXIMG=Obraz %e (%d)
EXMAP=Mapa Poziomu (%e)
EXMDL=Model 3D (%e)
EXMPEG=MPEG Audio/Wideo
EXMUS=Muzyka (%d)
EXPAL=Paleta
EXSCRP=Skrypt (%e)
EXSND=D�wi�k (%d)
EXSPR=Sprite
EXTEX=Tekstura (%e)
EXTXT=Dokument tekstowy

LOG002=�adowanie wtyczek Sterownika...
LOG003=�adowanie wtyczek Kowertera...
LOG004=�adowanie wtyczek HyperRipper...
LOG005=U�yte biblioteki:
LOG009=%p plugin(y/�w)
LOG020=�adowanie motywu: %t
LOG021=Otrzymywanie ikon menu i paska narz�dziowego
LOG022=Otrzymywanie ikon typ�w plik�w
LOG023=Znaleziono %i ikon / przypisano %a
LOG101=Otwieranie pliku "%f":
LOG102=Format pliku nierozpoznany!
LOG103=Uruchamianie HyperRipper...
LOG104=Plik nieznaleziony (lub jest zablokowany przez inny program)...
LOG200=Zamykanie obecnego pliku...
LOG300=Wy�wietlanie wpis�w folderu "%d"...
LOG301=%e wpis�w...
LOG400=U�ywanie SmartOpen do wykrycia formatu pliku �r�d�owego.
LOG500=Wtyczka sterownika "%d" my�li �e mo�e otwory� ten plik.
LOG501=Otwieranie pliku u�ywaj�c wtyczki "%d"...
LOG502=Otrzymywanie %x wpis�w...
LOG503=Parsowanie wpis�w dla folder�w...
LOG504=Plik pomy�lnie otwarty u�ywaj�c wtyczki "%p" (wykryty format: "%f")
LOG505=Pomi�te wpisy: %f (%r)...
LOG506=Rozmiar r�wny 0
LOG507=Offset ni�szy ni� 0
LOG510=Gotowe!
LOG511=Sukces!
LOG512=Pora�ka!
LOG513=B��d!
LOGC01=Uwalnianie %p wtyczek...
LOGC02=Szukanie wtyczek...
LOGC10=Konwertowanie z "%a" do "%b"...
LOGC11=Szybki spos�w!
LOGC12=Wolny spos�w (przestarza�e wtyczki)!
LOGC13=Konwertowanie do "%b"...
LOGC14=Konwertowanie wieu wpis�w do "%b"...
LOGC15=Konwertowanie...

PRV000=Podgl�d:
PRV001=Nieznany! (nie mo�na podejrze�)
PRV002=Nie mo�na podejrze�...
PRV003=Anulowano: Rozmiar jest wi�kszy ni� limit (%s bajty/�w)
PRV004=�adowanie
PRV005=Wy�wietlanie
PRV006=OK
PRV007=Wtyczki kowertera:
PRV008=Format: %f
PRV009=Wykrywanie
PRV010=Wypakowywanie

ERR000=B��d
ERR101=B��d podczas wypakowywania.
ERR102=B��d podczas wypakowywania pliku:
ERR200=Zdarzy� si� nast�puj�cy nieobs�ugiwany b��d:
ERR201=Z:
ERR202=Wyj�tek:
ERR203=Wiadomo��:
ERR204=Je�li chcesz zg�osi� b��d prosz� do��czy� nast�puj�ce dane ( naci�nij przycisk "Wi�cej").
ERR205=Kopiuj do schowka
ERR206=Wy�lij raport b��du do:
ERRCAL=B��d podczas wzywania:
ERRCMP=Nast�puj�ce potrzebne pliki dodatkowe nie znalezione:%n%n%f
ERREMP=Plik jest pusty.
ERREXT=B��d podczas wypakowywania danych (Tryb pliku) ze %f sterownika:
ERRSTM=B��d podczas wypakowywania danych (Tryb strumienia) ze %f sterownika:
ERRFIL=To nie jest poprawny plik %f (%g).
ERROPN=B��d podczas otwierania pliku �r�d�owego:%n%n%f
ERRUNK=�aden sterownik nie mo�e otworzy� tego pliku.
ERRTMP=Nie mo�na usun�� nast�puj�cego pliku tymczasowego:%n%n%f
ERRD01=Sterownik nie mo�e zosta� za�adowany (z�a wersja interfejsu lub nie jest sterownikiem DUP5).
ERRD02=Sterownik nie mo�e zosta� za�adowany (brakuj�ce wa�ne funkcje).
ERRDRV=B��d podczas u�ywania steownika "%d":
ERRDR1=Aby uzyska� wi�cej informacji o tym b��dzie prosz� skontaktowa� si� z tw�rc� sterownika (%a).
ERRC01=Wtyczka konwertera nie mo�e zosta� za�adowana (z�a wersja interfejsu lub nie jest sterownikiem DUP5).
ERRC02=Wtyczka konwertera nie mo�e zosta� za�adowana (brakuj�ce wa�ne funkcje).
ERRC10=B��d podczas konwertowania palety.%nNie mo�na doda� nowej palety.
ERRH01=Wtyczka HyperRipper nie mo�e zosta� za�adowana (z�a wersja interfejsu lub nie jest sterownikiem HyperRipper DUP5).
ERRH02=Wtyczka HyperRipper nie mo�e zosta� za�adowana (brakuj�ce wa�ne funkcje).
ERRH03=Uwaga: To rozszerzenie nie mo�e pracowa� powy�ej 2GB danych ( po przekroczeniu limitu nic nie b�dzie znajdowane).
ERRH04=Nieznane ID #%i wtyczki HyperRipper 
ERRH05=Wtyczka "%p" nie mo�e przeszukiwa� powy�ej 2GB.
ERRIO=Nie mo�na otworzy� nast�puj�cego pliku:%n%n%f%n%nSprawd� czy jest dost�pny lub czy nie jest otwarty w innym programie.
ERR900=Brakuj�ca funkcja %f we wtyczce...
{/BODY}
#
# End of Language Source File
#
{/LSF}
