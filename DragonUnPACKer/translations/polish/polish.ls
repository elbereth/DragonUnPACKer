# Language Source File (for DLNGC v4.0)
# ============================================================================
#  Program: Dragon UnPACKer v5.7.0 Beta
#    JÍzyk: Polski (Polish)
#   Wersja: 16
#    Autor: Piotr Halama (Halamix2)
# ============================================================================
#
# This file is the model for translations of Dragon UnPACKer.
#
# Po prostu przet≥umacz wszystko miÍdzy {BODY} i {/BODY}
#
# Then compile the file with DLNGC and put the resulting .LNG file into the
# \Data\ sub-directory of Dragon UnPACKer.
#
# To select a new Language into Dragon UnPACKer run: DrgUnPACK5.exe /lng
# Or go into the General Options.
#
# NIE MODYFIKUJ ØADNYCH S£”W KLUICZOWYCH - ZMIE— TYLKO RZECZY PO ZNAKU =
#
# If you have made a translation for your language send it to Alex Devilliers
# so it can be distributed along with the main program archive.
#
# You can reach Alex Devilliers by e-mail: translation@dragonunpacker.com
#                                  by ICQ: 1535372 (Elbereth)
#
# ============================================================================
# Informacje o tym t≥umaczeniu
# ============================================================================
#
# wersja 16:
# Dodano OPT853, LOG020, LOG021, LOG022, LOG023
# UsuniÍto LOG001, 11TH01, 11TH02, 11TH03, 11TH04, 11TH10, 11TH11, 11TH12, 11TH13, 11TH14
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
# UsuniÍto wpisy Duppi (teraz w osobnym pliku)
#
# wersja 11a:
# Naprawiono brakujπce s≥owo kluczowe w LOG005
#
# wersja 11:
# Dodano s≥owa kluczowe podglπdu
#
# wersja 10:
# Dodano nowe opcje.
#
# wersja 9a:
# Dodano brakujπce s≥owo kluczowe w OPT203
#
# wersja 9:
# Dodano ciπgi wtyczki UT Package driver.
# Dodano ciπgi Dziennika.
# Dodano ciπgi Duppi.
#
# wersja 8:
# Zmieniono kilka komunikatÛw  b≥ÍdÛw.
# wersja 7:
# Dodano ciπgi nowych Opcji (priorytet sterownikÛw itp.).
# Dodano ciπgi Dziennika.
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
MNU1S1=&OtwÛrz...
MNU1S2=&Zamknij
MNU1S3=&Wyjdü
MNU1S4=&OtwÛrz ponownie...
MNU2=&Opcje
MNU2S1=Podstawowe
MNU2S2=Sterowniki
MNU2S3=Wyglπd/Ikony
MNU2S4=Typy PlikÛw
MNU2S5=Konwersja
MNU2S6=Wtyczki
MNU2S7=Zaawansowane
MNU2S8=Dziennik
MNU2S9=Podglπd
MNU3=&?
MNU3S1=o
MNU3S2=Szukaj nowej wersji w internecie...
MNU4=&Edytuj
MNU4S1=&Szukaj
MNU5=&NarzÍdzia
MNU5S1=StwÛrz listÍ pozycji...
LSTCP1=Plik
LSTCP2=Rozmiar (Bajty)
LSTCP3=Offset
LSTCP4=Opis
LSTCP5=Dane X
LSTCP6=Dane Y
STAT10=obiekt(y/Ûw)
STAT20=bajt(y/Ûw)

ABT001=Program freeware
ABT002=Skontaktuj siÍ ze mnπ:
ABT003=Strona internetowa:
ABT004=Dragon UnPACKer korzysta z:
ABT005=Betatesterzy:
ABT006=Specjalne podziÍkowania dla wszystkich t≥umaczy:

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
INFO14=Czas ≥adowania:
INFO20=Nazwa wtyczki
INFO21=Wersja
INFO22=Zaawansowane Informacje
INFO23=Wer.Wewn.:

SCHTIT=Szukaj
SCHGRP=Opcje
SCH001=UwzglÍdniaj wielkoúÊ liter
SCH002=Wszystkie pliki
SCH003=Tylko obecny folder
SCH004=znaleziono obiekt(y/Ûw)
DIRTIT=Wybierz folder...
POP1S1=Wypakuj plik do...
PSUB01=Bez konwersji
PSUB02=Konwertuj do %d
POP1S2=Wypakuj pliki do...
POP1S3=OtwÛrz
POP1S4=Bez konwersji
POP2S1=Wypakuj wszystkie...
POP2S2=Wypakuj pod-foldery...
POP2S3=Informacje
POP2S4=RozwiÒ wszystkie
POP2S5=ZwiÒ wszystkie
POP2S6=Wypakuj pod-foldery do "%d"...
POP3S1=Pokaø dziennik
POP3S2=Ukryj dziennik
POP3S3=WyczyúÊ dziennik
POP3S4=kopiuj dziennik do schowka
POP4S1=Ukryj podglπd
POP4S2=Pokaø podglπd
POP5S1=Tryb wyúwietlania
POP5S2=Oryginalny rozmiar z suwakiem (jeúli potrzeba)
POP5S3=Skurczone/RozciπgniÍte do rozmiaru panelu
POP5S4=Opcje podglπdu...
OPTTIT=Konfiguracja
OPT000=Opcje zaawansowane
OPT010=Folder tymczasowy
OPT011=Uøyj automatycznie wykrytego folderu tymczasowego
OPT012=Uøyj wybranego folderu tymczasowego:
OPT013=Wybierz folder tymczasowy...
OPT020=Opcje dla "OtwÛrz plik"
OPT021=Zaznacz "Wypakuj plik... Bez konwersji" jako domyúlnπ opcjÍ
OPT030=Rozmiar bufora
OPT031=Wybierz rozmiar bufora dla wypakowywania:
OPT032=Bez bufora / Nie zalecane! (Bardzo wolne)
OPT033=%d bajt(y/Ûw)
OPT034=%d kilobajt(y/Ûw)
OPT035=%d Megabajt(y/Ûw)
OPT036=Domyúlne
OPT040=IntegralnoúÊ wejúcia wtyczek sterownikÛw
OPT041=Nie ignoruj plikÛw z rozmiarem = 0 bajtÛw (nie zalecane)
OPT100=Podstawowe opcje
OPT110=JÍzyk
OPT111=Szukaj dostÍpnych t≥umaczeÒ...
OPT120=Opcje
OPT121=Nie wyúwietlaj ekranu powitalnego przy uruchomieniu
OPT122=ZezwÛl tylko na jedno jednoczesne uruchomienie programu
OPT123=Automatyczne wykrywanie rozszerzenia plikÛw (przy otwieraniu)
OPT124=Pobierz ikony z rejestru Windows (moøe byÊ wolniejsze)
OPT125=Uøyj HyperRipper jeúli øadna wtyczka nie moøe otworzyÊ pliku
OPT126=Pokaø dziennik uruchomienia
OPT127=Automatycznie rozwiÒ foldery przy otwieraniu
OPT128=Zachowaj wybrany typ pliku w oknie otwierania
OPT129=Wyúwietlaj dodatkowe pola zaawansowane na liúcie pozycji (nie zalecane)
OPT191=Te wtyczki obs≥ugujπ konwertowanie formatÛw plikÛw przy wypakowywaniu lub podglπdzie plikÛw.Przyk≥ad: Konwertuje tekstury z formatu .ART do .BMP
OPT192=Te wtyczki obs≥ugujπ otwieranie typÛw plikÛw tak aby Dragon UnPACKer mÛg≥ je przeszukiwaÊ. Jeúli plik jest niewspierany to znaczy øe øaden sterownik nie moøÍ go za≥adowaÊ. HyperRipper obs≥uguje pliki przy uøyciu innych wtyczek (zobacz poniøej).
OPT193=Te wtyczki obs≥ugujπ formaty plikÛw do skanowania w HyperRipper (np: MPEG Audio, BMP, itp..)
OPT200=Sterowniki
OPT201=O...
OPT202=Ustawienia
OPT203=Wtyczki sterownikÛw:
OPT210=Informacje sterownikÛw
OPT220=Priorytet :
OPT221=Odúwieø listÍ
OPT300=Wyglπd/Ikony
OPT310=Informacje o wyglπdzie
OPT320=Motywy wyglπdu (pliki):
OPT330=Opcje wyglπdu
OPT331=menu i pasek narzÍdzi XP-like
OPT400=Typy plikÛw
OPT401=Wybierz rozszerzenia ktÛre Dragon UnPACKer powinien otworzyÊ kiedy klikniesz je w Eksploratorze:
OPT402=Obecnie powiπzana ikona:
OPT411=Øadne
OPT412=Wszystkie
OPT420=Sprawdü powiπzania przy uruchamianiu
OPT430=Uøyj zewnÍtrznej ikony
OPT431=Wybierz plik ikony dla powiπzaÒ z Dagon UnPACKer 5...
OPT432=Ikony
OPT440=ZmieÒ tekst powiπzania:
OPT450=Dodaj rozszerzenie pow≥oki Windows Explorer "%d"
OPT451=OtwÛrz za pomocπ Dragon UnPACKer 5
OPT500=Konwertuj
OPT501=Wtyczki konwertera:
OPT510=Informacje wtyczki
OPT600=Wtyczki
OPT701=Wtyczki HyperRipper:
OPT710=Informacje wtyczki
OPT800=Dziennik uruchomienia
OPT810=Opcje dziennika uruchomienia
OPT811=Pokaø dziennik uruchomienia w g≥Ûwnym oknie
OPT812=WyczyúÊ podczas otwierania nowego pliku
OPT840=Poziom wys≥awiania
OPT841=Wybierz iloúÊ wyúwietlanych informacji :
OPT850=Niski - ma≥o informacji
OPT851=åredni - Duøa dawka informacji
OPT852=Wysoki - Bardzo duøo informacji!
OPT853=Debugowanie
OPT900=Podglπd
OPT910=Opcje podglπdu
OPT911=W≥πcz podglπd
OPT920=Limit rozmiaru podglπdu
OPT921=Nie ograniczaj rozmiaru plikÛw do podglπdu
OPT922=Ograniczaj rozmiar plikÛw do podglπdu (Zalecane)
OPT923=Limit:
OPT924=Bardzo niski
OPT925=Niski
OPT926=åredni (Zalecane)
OPT927=Wysoki
OPT928=Bardzo wysoki
OPT940=Tryb wyúwietlania podglπdu

OPEN00=OtwÛrz plik...
ALLCMP=Kompatybilne pliki
ALLFIL=Wszystkie pliki
XTRCAP=Wypakowywanie w trakcie...
XTRSTA=Wypakowywanie %f...
BUTOK=OK
BUTGO=Idü!
BUTSCH=Szukaj
BUTDIR=Nowy Folder
BUTDET=WiÍcej
BUTDEL=UsuÒ
BUTADD=Dodaj
BUTCNV=Konwertuj
BUTCAN=Anuluj
BUTINS=Instaluj
BUTCLO=Zamknij
BUTCON=Kontynuuj
BUTNEX=Dalej
BUTPAL=Dodaj PaletÍ
BUTREF=Odúwieø
BUTREM=UsuÒ
BUTEDT=Edytuj
HYPAD=Ta wersja potrafi tylko szukaÊ plikÛw düwiÍkowych WAVE.
HYPFIN=Typ %t (Offset %o / %s bajty/Ûw)
HYPOPN=Wybierz plik do przeskanowania...
CNV000=Konwersja obrazka/tekstury 
CNV001=Paleta
CNV010=Info:%nUøyj okienka konfiguracji aby zarzπdzaÊ%n(dodawaÊ lub usuwaÊ) paletami.
CNV100=Dodaj nowπ paletÍ
CNV101=èrÛd≥o:
CNV102=Nazwa:
CNV103=Autor:
CNV104=Format:
CNV110=Raw binarna 768bajtowa paleta
CNV120=Nieznane
CNV900=B≥πd podczas konwertowania palety:%n%nPlik ürÛd≥owy: %f%nFormat ürÛd≥a: %t%n%nB≥πd: %e%n%nNie moøna dodaÊ palety.
CNV901=Paleta przekonwertowana pomyúlnie!%nTeraz moøesz wybraÊ jπ z listy.
CNV990=Nazwa palety juø istnieje.
CNV991=Format nieznany (sprÛbuj zmieniÊ format).
CNV992=Czy na pewno chcesz usunπÊ paletÍ?

TLD001=Odczytywanie %f...
TLD002=Pozyskiwanie danych...
TLD003=Parsowanie i wyúwietlanie folderu g≥Ûwnego...

HR0000=O...
HR0001=HyperRipper pozwala poszukaÊ "standardowych" typÛw plikÛw%nw innych plikach, ktÛre nie sπ bezpoúrednio wsperane przez Dragon UnPACKer.
HR0002=UWAGA: Tylka dla zaawansowanych uøytkownikÛw!
HR0003=Za≥adowane wtyczki:
HR0004=Wszystkich wspieranych formatÛw:
HR1000=Szukaj
HR1001=èrÛd≥o:
HR1002=UtwÛrz Plik HyperRipper (HRF):
HR1003=Anuluj / Stop
HR1011=Rozmiar bufora:
HR1012=Rozmiar rollback:
HR1013=PrÍdkoúÊ szukania:
HR1014=Znaleziono:
HR2000=Formaty
HR2011=Format
HR2012=Typ
HR2021=Ustawienia
HR2022=Wszystko / Nic
HR2031=Wy≥πcz formaty plikÛw ktÛre mogπ wyszukaÊ fa≥szywy alarm
HR3000=Plik HyperRipper
HR3010=Do≥πcz nastÍpujπce informacje:
HR3011=Tytu≥:
HR3012=URL:
HR3020=Wersja HRF
HR3021=Wersja
HR3030=Opcje
HR3031=Ustaw IDentyfikator programu na anonimowy
HR3032=Nie ustawiaj wersji programu
HR3033=Maksymalna d≥ugoúÊ nazwy:
HR3034=%c znaki/Ûw
HR3035=Kompatybilne z wersjami:
HR3036=%v i nowsze
HR4000=Zaawansowane
HR4010=PamiÍÊ bufora
HR4011=Kilobajty/Ûw
HR4012=bajty/Ûw
HR4020=PamiÍÊ rollback
HR4021=Bez Rollback (nie zalecane)
HR4022=Domyúlny Rollback (128 bajtÛw)
HR4023=Duøy Rollback (1/4 bufora)
HR4024=Ogromny Rollback (1/2 bufora)
HR4030=Formatowanie wpisÛw
HR4031=StwÛrz foldery uøywajπc typÛw podanych przez wtyczkÍ
HR4050=Nazywanie
HR4051=Automatyczne
HR4052=W≥asne
HR4053=Przyk≥ad
HR4061=Automatyczny start szukania kiedy nieznany typ pliku
HR4062=Automatycznie zamknij HyperRipper kiedy szukanie jest zakoÒczone i zosta≥y znalezione wpisy
HR4063=Ustaw rozmiar bufora
HRLEGF=nazwa pliku
HRLEGN=numer
HRLEGX=rozszerzenie
HRLEGO=offset (Dec)
HRLEGH=offset (Hex)
HRLG01=Nie wybrano formatÛw...
HRLG02=Nie odnaleziono pliku %f!
HRLG03=Otwieranie %f...
HRLG04=Gotowe!
HRLG05=Lokowanie zasobÛw...
HRLG06=Skanowanie pliku na podane formaty...
HRLG07=Nie moøna odczytaÊ %b bajtÛw z pliku...
HRLG08=Znaleziono %e @ %a (%s bajty/Ûw)
HRLG09=Przeskanowano %s w %t sekund!
HRLG10=bajtÛw
HRLG11=KB
HRLG12=MB
HRLG13=GB
HRLG14=Zapisywanie HRF...
HRLG15=Wyúwietlanie wyniku w Dragon UnPACKer...
HRLG16=B≥πd podczas skanowania... Anulowanie...
HRLG17=Uwalnianie zasobÛw...
HRLG18=B≥πd!
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
HRD223=bajt(y/Ûw)
HRD300=Specjalne
HRD301=Szukaj (i uøywaj) Xing VBR header
HRD302=Szukaj ID3Tag v1.0/1.1

LST000=UtwÛrz listÍ
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
LST204=Do≥πcz podfoldery
LST300=Sortuj wed≥ug
LST301=Nazwy
LST302=Rozmiaru
LST303=Offset
LST304=OdwrÛÊ
LST400=Uwaga: Sortowanie spowolni tworzenie listy...
LST500=Zapisz listÍ do...
LST501=Otrzymywanie elementu Header z szablonu...
LST502=Otrzymywanie elementu Footer z szablonu...
LST503=Otrzymywanie elementu Variable z szablonu...
LST504=Otrzymywanie wpisÛw...
LST505=Sortowanie %v wpisÛw...
LST506=Przetwarzanie %v wpisÛw... %p%
LST507=Zapisywanie pliku listy...
LST508=Otrzymywanie plikÛw towarzyszπcych z szablonu...
LST509=Gotowe!

11TH05=Status wtyczki: %s%n(W≥πczona oznacza, øe moøesz otwieraÊ pliki)%n(Wy≥πczona oznacza, øe musisz zaimportowaÊ pliki GJD.GJD i DIR.RL)
11TH06=Wy≥πczona
11TH07=W≥πczona

DUT100=Konfiguracja
DUT101=Biblioteka
DUT110=ID
DUT111=åcieøka
DUT112=WskazÛwka gry
DUT113=DA?
DUT114=GID
DUT201=Z ktÛrej gry otwierasz paczkÍ ?
DUT202=Nie pytaj ponownie dla tej úcieøki
DUT203=- Nieznane / Inne -

EX=Plik %e
EXANIM=Animacja (%e)
EXART=Paczka Art'Ûw (Tekstury)
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
EXSND=DüwiÍk (%d)
EXSPR=Sprite
EXTEX=Tekstura (%e)
EXTXT=Dokument tekstowy

LOG002=£adowanie wtyczek Sterownika...
LOG003=£adowanie wtyczek Kowertera...
LOG004=£adowanie wtyczek HyperRipper...
LOG005=Uøyte biblioteki:
LOG009=%p plugin(y/Ûw)
LOG020=£adowanie motywu: %t
LOG021=Otrzymywanie ikon menu i paska narzÍdziowego
LOG022=Otrzymywanie ikon typÛw plikÛw
LOG023=Znaleziono %i ikon / przypisano %a
LOG101=Otwieranie pliku "%f":
LOG102=Format pliku nierozpoznany!
LOG103=Uruchamianie HyperRipper...
LOG104=Plik nieznaleziony (lub jest zablokowany przez inny program)...
LOG200=Zamykanie obecnego pliku...
LOG300=Wyúwietlanie wpisÛw folderu "%d"...
LOG301=%e wpisÛw...
LOG400=Uøywanie SmartOpen do wykrycia formatu pliku ürÛd≥owego.
LOG500=Wtyczka sterownika "%d" myúli øe moøe otworyÊ ten plik.
LOG501=Otwieranie pliku uøywajπc wtyczki "%d"...
LOG502=Otrzymywanie %x wpisÛw...
LOG503=Parsowanie wpisÛw dla folderÛw...
LOG504=Plik pomyúlnie otwarty uøywajπc wtyczki "%p" (wykryty format: "%f")
LOG505=PomiÍte wpisy: %f (%r)...
LOG506=Rozmiar rÛwny 0
LOG507=Offset niøszy niø 0
LOG510=Gotowe!
LOG511=Sukces!
LOG512=Poraøka!
LOG513=B≥πd!
LOGC01=Uwalnianie %p wtyczek...
LOGC02=Szukanie wtyczek...
LOGC10=Konwertowanie z "%a" do "%b"...
LOGC11=Szybki sposÛw!
LOGC12=Wolny sposÛw (przestarza≥e wtyczki)!
LOGC13=Konwertowanie do "%b"...
LOGC14=Konwertowanie wieu wpisÛw do "%b"...
LOGC15=Konwertowanie...

PRV000=Podglπd:
PRV001=Nieznany! (nie moøna podejrzeÊ)
PRV002=Nie moøna podejrzeÊ...
PRV003=Anulowano: Rozmiar jest wiÍkszy niø limit (%s bajty/Ûw)
PRV004=£adowanie
PRV005=Wyúwietlanie
PRV006=OK
PRV007=Wtyczki kowertera:
PRV008=Format: %f
PRV009=Wykrywanie
PRV010=Wypakowywanie

ERR000=B≥πd
ERR101=B≥πd podczas wypakowywania.
ERR102=B≥πd podczas wypakowywania pliku:
ERR200=Zdarzy≥ siÍ nastÍpujπcy nieobs≥ugiwany b≥πd:
ERR201=Z:
ERR202=Wyjπtek:
ERR203=WiadomoúÊ:
ERR204=Jeúli chcesz zg≥osiÊ b≥πd proszÍ do≥πczyÊ nastÍpujπce dane ( naciúnij przycisk "WiÍcej").
ERR205=Kopiuj do schowka
ERR206=Wyúlij raport b≥Ídu do:
ERRCAL=B≥πd podczas wzywania:
ERRCMP=NastÍpujπce potrzebne pliki dodatkowe nie znalezione:%n%n%f
ERREMP=Plik jest pusty.
ERREXT=B≥πd podczas wypakowywania danych (Tryb pliku) ze %f sterownika:
ERRSTM=B≥πd podczas wypakowywania danych (Tryb strumienia) ze %f sterownika:
ERRFIL=To nie jest poprawny plik %f (%g).
ERROPN=B≥πd podczas otwierania pliku ürÛd≥owego:%n%n%f
ERRUNK=Øaden sterownik nie moøe otworzyÊ tego pliku.
ERRTMP=Nie moøna usunπÊ nastÍpujπcego pliku tymczasowego:%n%n%f
ERRD01=Sterownik nie moøe zostaÊ za≥adowany (z≥a wersja interfejsu lub nie jest sterownikiem DUP5).
ERRD02=Sterownik nie moøe zostaÊ za≥adowany (brakujπce waøne funkcje).
ERRDRV=B≥πd podczas uøywania steownika "%d":
ERRDR1=Aby uzyskaÊ wiÍcej informacji o tym b≥Ídzie proszÍ skontaktowaÊ siÍ z twÛrcπ sterownika (%a).
ERRC01=Wtyczka konwertera nie moøe zostaÊ za≥adowana (z≥a wersja interfejsu lub nie jest sterownikiem DUP5).
ERRC02=Wtyczka konwertera nie moøe zostaÊ za≥adowana (brakujπce waøne funkcje).
ERRC10=B≥πd podczas konwertowania palety.%nNie moøna dodaÊ nowej palety.
ERRH01=Wtyczka HyperRipper nie moøe zostaÊ za≥adowana (z≥a wersja interfejsu lub nie jest sterownikiem HyperRipper DUP5).
ERRH02=Wtyczka HyperRipper nie moøe zostaÊ za≥adowana (brakujπce waøne funkcje).
ERRH03=Uwaga: To rozszerzenie nie moøe pracowaÊ powyøej 2GB danych ( po przekroczeniu limitu nic nie bÍdzie znajdowane).
ERRH04=Nieznane ID #%i wtyczki HyperRipper 
ERRH05=Wtyczka "%p" nie moøe przeszukiwaÊ powyøej 2GB.
ERRIO=Nie moøna otworzyÊ nastÍpujπcego pliku:%n%n%f%n%nSprawdü czy jest dostÍpny lub czy nie jest otwarty w innym programie.
ERR900=Brakujπca funkcja %f we wtyczce...
{/BODY}
#
# End of Language Source File
#
{/LSF}
