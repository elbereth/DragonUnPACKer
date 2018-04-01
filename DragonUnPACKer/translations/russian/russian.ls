# Language Source File (for DLNGC v4.0)
# ============================================================================
#  Program: Dragon UnPACKer v5.7.1 Beta
# Language: Russian
#  Version: 1
#   Author: Alexms69
# ============================================================================
#
# This file is the model for translations of Dragon UnPACKer.
#
# Just translate everything between {BODY} and {/BODY}
#
# Then compile the file with DLNGC and put the resulting .LNG file into the
# \Data\ sub-directory of Dragon UnPACKer.
#
# To select a new Language into Dragon UnPACKer run: DrgUnPACK5.exe /lng
# Or go into the General Options.
#
# DON'T MODIFY ANY KEYWORD - JUST CHANGE THINGS AFTER THE = SYMBOL
#
# If you have made a translation for your language send it to Alex Devilliers
# so it can be distributed along with the main program archive.
#
# You can reach Alex Devilliers by e-mail: translation@dragonunpacker.com
#                                  by ICQ: 1535372 (Elbereth)
#
# ============================================================================
# Informations about this translation
# ============================================================================
#
# version 17:
# Changed HRD000, HRD100, HRD300
# Added CET100, CET200, CET210, CET220, CET230, CET240, CET245, CET250, CET260, CET270,
#  CET300, CET310, CET400, CET410, CET420, CET430, CET440, CET450, CET460, CET500
#
# version 16:
# Added OPT853, LOG020, LOG021, LOG022, LOG023
# Removed LOG001, 11TH01, 11TH02, 11TH03, 11TH04, 11TH10, 11TH11, 11TH12, 11TH13, 11TH14
#
# version 15:
# Added LSTCP5, LSTCP6, OPT040, OPT041 and OPT129
#
# version 14:
# Added LOG505, LOG506, LOG507, OPT127, OPT128, OPT812, POP2S6 and POP3S4
#
# version 13:
# Added HR2031, HR4061, HR4062 and HR4063
#
# version 12:
# Added missing preview keywords
# Removed Duppi entries (now in standalone file)
#
# version 11a:
# Fixed missing LOG005 keyword
#
# version 11:
# Added preview keywords
#
# version 10:
# Added new options.
#
# version 9a:
# Added missing OPT203 keyword
#
# version 9:
# Added UT Package driver plugin strings.
# Added Log feature strings.
# Added Duppi strings.
#
# version 8:
# Changed some error messages.
#
# version 7:
# Added new Options strings (drivers priority, etc..).
# Added Log feature strings.
#
# version 6a:
# Added FontName header option.
#
# version 6: (see english-rc3-changes.txt for changes since version 5)
# Fixed two missing HyperRipper plugin error strings (ERRH01 and ERRH02)
# Added some convert plugin strings.
# Added new about box strings.
# Added 11th Hour driver plugin strings.
#
# version 5: (see english-rc2-changes.txt for changes since version 4)
# Added Use HyperRipper if all plugins fails option string.
# Fixed some leading ' characters.
#
# version 4: (see english-rc1-changes.txt for changes since version 3)
# Added Error handling string.
# Added HyperRipper v5.0a strings.
# Added Convert pic/tex plugin palette convertion strings.
#
# version 3: (see english-beta3-changes.txt for changes since version 2)
#            (no changes between beta3 and beta4)
# Added Create List strings.
# Added Error handling strings.
# Added Duppi v2 strings.
# Added 1 option string.
#
# version 2: (see english-beta2-changes.txt for changes since version 1)
# Added 1 Duppi string.
# Added all HyperRipper translation labels.
#
# version 1:
# First version.
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
Name = Russian
#
# + Author +
# Write here your name or alias (and any comment)
#
# Can be up to 80 characters
#
Author = Alexms69
#
# + Email +
# Write here your email
#
# Can be up to 80 characters
#
Email = hpgamesnet@gmail.com
#
# + URL +
# Write here the Internet URL where your file can be downloaded
#
# Can be up to 80 characters
#
URL = https://hp-games.net
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
# Dragon UnPACKer v5.7.1 Beta    UP      17
#
ProgramID = UP
ProgramVer = 1
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
IconFile = flag_ru.bmp
#
# + OutFile +
# Path & FileName of the compiled file (ex: c:\test.lng)
#
OutFile = russian.lng
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
MNU1=&Файл
MNU1S1=&Открыть...
MNU1S2=&Закрыть
MNU1S3=&Выход
MNU1S4=Открыть заново...
MNU2=&Настройки
MNU2S1=Основные
MNU2S2=Драйверы
MNU2S3=Вид/Значки
MNU2S4=Типы файлов
MNU2S5=Конверторы
MNU2S6=Плагины
MNU2S7=Дополнительно
MNU2S8=Журнал выполнения
MNU2S9=Предпросмотр
MNU3=&?
MNU3S1=О программе
MNU3S2=Проверить на наличие новых версий...
MNU4=&Правка
MNU4S1=&Поиск
MNU5=&Сервис
MNU5S1=Создать список записей...
LSTCP1=Файл
LSTCP2=Размер (в Байтах)
LSTCP3=Смещение
LSTCP4=Описание
LSTCP5=Данные X
LSTCP6=Данные Y
STAT10=объект(ов)
STAT20=Байт

ABT001=Freeware
ABT002=Связаться со мной:
ABT003=Домашняя страница:
ABT004=Dragon UnPACKer создаётся с участием:
ABT005=Команда бета-тестирования:
ABT006=Особая благодарность всем переводчикам:

INFO99=Информация
INFO00=Драйвер
INFO01=Имя:
INFO02=Автор:
INFO03=Коммент.:
INFO04=Версия:
INFO05=E-mail:
INFO10=Файл
INFO11=Формат:
INFO12=Записей:
INFO13=Размер:
INFO14=Время загрузки:
INFO20=Имя плагина
INFO21=Версия
INFO22=Доп. информация
INFO23=Int.Ver.:

SCHTIT=Поиск
SCHGRP=Настройки
SCH001=Учёт регистра
SCH002=Все файлы
SCH003=Только в текущей папке
SCH004=объект(ов) найдено
DIRTIT=Выберите папку...
POP1S1=Извлечь файл в...
PSUB01=Без конвертации
PSUB02=Конвертировать в %d
POP1S2=Извлечь файлы в...
POP1S3=Открыть
POP1S4=Без конвертации
POP2S1=Извлечь все...
POP2S2=Извлечь подпапки...
POP2S3=Информация
POP2S4=Развернуть
POP2S5=Свернуть
POP2S6=Извлечь подпапки в "%d"...
POP3S1=Показать журнал
POP3S2=Скрыть журнал
POP3S3=Очистить журнал
POP3S4=Копировать журнал в буфер обмена
POP4S1=Скрыть предпросмотр
POP4S2=Показать предпросмотр
POP5S1=Режим отображения
POP5S2=Оригинальный размер с полосами прокрутки (если нужны)
POP5S3=Вписывать/растягивать под размер панели
POP5S4=Настройки предпросмотра...
OPTTIT=Конфигурация
OPT000=Доп. настройки
OPT010=Временная папка
OPT011=Автоопределение временной папки
OPT012=Использовать эту временную папку:
OPT013=Выберите папку для временных файлов...
OPT020=Настройки для 'Открыть файл'
OPT021=Сделать 'Извлечь файл... Без конвертации' вариантом по умолчанию
OPT030=Буфер памяти
OPT031=Выберите размер буфера извлечения:
OPT032=Без буфера / Не рекомендуется! (Медленно)
OPT033=%d Байт
OPT034=%d КБ
OPT035=%d МБ
OPT036=По умолчанию
OPT040=Целостность записей плагинов-драйверов
OPT041=Не пропускать файлы нулевого размера (не рекомендуется)
OPT100=Основные настройки
OPT110=Язык
OPT111=Найти доступные переводы...
OPT120=Настройки
OPT121=Не показывать заставку при запуске
OPT122=Только 1 экземпляр программы
OPT123=Умное определение формата файла (при открытии)
OPT124=Получать инфо о значках из реестра (медленнее)
OPT125=Использовать HyperRipper, если ни один плагин не может открыть файл
OPT126=Показывать журнал времени выполнения
OPT127=Автораскрытие папок при открытии
OPT128=Запоминать выбранный тип файла в диалоге 'Открытие файла'
OPT129=Отображать дополнительные поля в списке записей (не рекомендуется)
OPT191=Эти плагины будут преобразовывать формат файлов при извлечении или предварительном просмотре. Пример. Конвертация текстур из формата .ART в формат .BMP.
OPT192=Эти плагины позволяют Dragon UnPACKer'у просматривать файлы. Если файл не поддерживается, это означает, что плагин драйвера не может его загрузить. HyperRipper обрабатывает файлы с помощью другого типа плагинов (см. ниже).
OPT193=Эти плагины применяются при сканирования файлов в HyperRipper (например: MPEG Audio, BMP и т. д.).
OPT200=Драйверы
OPT201=О нём..
OPT202=Установка
OPT203=Драйверы-плагины:
OPT210=Инфо о драйвере
OPT220=Приоритет:
OPT221=Обновить список
OPT300=Вид/Значки
OPT310=Информация об оформлении
OPT320=Темы оформления (файлы):
OPT330=Настройки вида
OPT331=XP-подобные меню и панели инструментов
OPT400=Типы файлов
OPT401=Выберите расширения файлов, которые Dragon UnPACKer будет открывать по двойному щелчку в Проводнике:
OPT402=Ассоциированный значок:
OPT411=Не выбраны
OPT412=Все
OPT420=Проверять ассоциации при запуске
OPT430=Использ. внешний значок
OPT431=Выберите файл значка для его сопоставления с Dragon UnPACKer 5...
OPT432=Значки
OPT440=Изменение текста ассоциации:
OPT450=Добавить расширение Проводника Windows "%d"
OPT451=Открывать с помощью Dragon UnPACKer 5
OPT500=Конвертация
OPT501=Плагины конвертации:
OPT510=Инфо о плагине
OPT600=Плагины
OPT701=Плагины HyperRipper:
OPT710=Инфо о плагине
OPT800=Журнал выполнения
OPT810=Настройки журнала выполнения
OPT811=Показывать журнал выполнения в главном окне
OPT812=Очищать при открытии нового файла
OPT840=Детализация данных
OPT841=Выберите объем информации для отображения:
OPT850=Низкая - минимум информации
OPT851=Средняя - Хороший объем информации
OPT852=Высокая - Много информации!
OPT853=Отладка
OPT900=Предпросмотр
OPT910=Настройки предпросмотра
OPT911=Включить предпросмотр
OPT920=Ограничение размера для предпросмотра
OPT921=Не ограничивать размер Файлов
OPT922=Ограничивать размер просматриваемых файлов (рекомендуется)
OPT923=Предел:
OPT924=Очень маленький
OPT925=Маленький
OPT926=Средний (рекомендуется)
OPT927=Высокий
OPT928=Очень высокий
OPT940=Режим предпросмотра

OPEN00=Открыть файл...
ALLCMP=Совместимые файлы
ALLFIL=Все файлы
XTRCAP=Выполняется извлечение...
XTRSTA=Извлекается %f...
BUTOK=OK
BUTGO=Go!
BUTSCH=Поиск
BUTDIR=Новая папка
BUTDET=Подробнее
BUTDEL=Удалить
BUTADD=Добавить
BUTCNV=Конвертация
BUTCAN=Отмена
BUTINS=Установить
BUTCLO=Закрыть
BUTCON=Продолжить
BUTNEX=Далее
BUTPAL=Доб. палитру
BUTREF=Обновить
BUTREM=Удалить
BUTEDT=Правка
HYPAD=Эта версия может искать только звуковые файлы WAVE.
HYPFIN=Тип %t (Смещение %o / %s Байт)
HYPOPN=Выберите файл для сканирования...
CNV000=Конвертация картинок/текстур
CNV001=Палитра
CNV010=Примечание:%nДля управления палитрами (добавление или удаление)%n используйте блок конфигурации.
CNV100=Доб. новую палитру
CNV101=Источник:
CNV102=Имя:
CNV103=Автор:
CNV104=Формат:
CNV110=Raw 768байтовая двоичная палитра
CNV120=Неизвестно
CNV900=Ошибка при конвертации палитры:%n%nИсходный файл: %f%nИсходный формат: %t%n%nОшибка: %e%n%nНевозможно добавить палитру.
CNV901=Палитра успешно преобразована!%nВы можете выбрать её из списка.
CNV990=Такое имя палитры уже существует.
CNV991=Неизвестный формат (попробуйте изменить формат).
CNV992=Вы действительно хотите удалить эту палитру?

CET100=Внешние инструменты (плагины-конверторы) v%v - Конфигурация
CET200=Название:
CET210=Автор:
CET220=URL:
CET230=Комментарий:
CET240=Путь:
CET245=Параметры:
CET250=Расширение на выходе:
CET260=Правильный результат тестирования:
CET270=Правильный результат:
CET300=Инструмент
CET310=Расширения
CET400=Новый
CET410=Удалить
CET420=Сохранить
CET430=Сброс
CET440=Добавить
CET450=Удалить
CET460=Готово
CET500=Инструмент для командной строки

TLD001=Чтение %f...
TLD002=Получение данных...
TLD003=Анализ и отображение корневой папки...

HR0000=О...
HR0001=HyperRipper нужен для поиска "стандартных" форматов файлов%nв других файлах, ккоторые Dragon UnPACKer не может открыть напрямую.
HR0002=ВНИМАНИЕ: Только для опытных пользователей!
HR0003=Загружено плагинов:
HR0004=Поддерживаемых форматов:
HR1000=Поиск
HR1001=Источник:
HR1002=Создать файл HyperRipper (HRF):
HR1003=Отмена/Стоп
HR1011=Размер буфера:
HR1012=Размер отката:
HR1013=Скорость поиска:
HR1014=Найдено:
HR2000=Форматы
HR2011=Формат
HR2012=Тип
HR2021=Установка
HR2022=Все/Ничего
HR2031=Исключить форматы файлов, вызывающие ложные срабатывания
HR3000=Файл HyperRipper
HR3010=Включить следующую информацию:
HR3011=Заголовок:
HR3012=URL:
HR3020=Версия HRF
HR3021=Версия
HR3030=Настройки
HR3031=Уст. програм. IDentifier для анонимов
HR3032=Не устанавливать версию программы
HR3033=Максимальная длина имени записи:
HR3034=%c символов
HR3035=Совместимость с версией:
HR3036=%v и ранее
HR4000=Дополнительно
HR4010=Буфер памяти
HR4011=кБ
HR4012=Байт
HR4020=Память для отката
HR4021=Без отката (не рекомендуется)
HR4022=По умолчанию (128 Байт)
HR4023=Большой (1/4 буфера)
HR4024=Огромный (1/2 буфера)
HR4030=Форматирование записей
HR4031=Создание папок с использованием типа, заданного плагином
HR4050=Именование
HR4051=Авто
HR4052=Другое
HR4053=Пример
HR4061=Автопоиск при неизвестном формате исходного файла
HR4062=Автозакрытие HyperRipper'a, если по окончании поиска найдены записи
HR4063=Форсировать размер буфера
HRLEGF=имя файла
HRLEGN=число
HRLEGX=расширение
HRLEGO=смещение (10)
HRLEGH=смещение (16)
HRLG01=Форматы не выбраны...
HRLG02=Файл %f не найден!
HRLG03=Открытие %f...
HRLG04=Готово!
HRLG05=Распределение ресурсов...
HRLG06=Поиск файлов выбранных форматов...
HRLG07=Невозможно прочитать из файла %b Байт...
HRLG08=Найден %e @ %a (%s Байт)
HRLG09=Просканировано %s за %t сек!
HRLG10=Байт
HRLG11=кБ
HRLG12=МБ
HRLG13=ГБ
HRLG14=Сохранение HRF...
HRLG15=Отобразить результаты в Dragon UnPACKer...
HRLG16=Ошибка при сканировании... Прерывание...
HRLG17=Блокировка ресурсов...
HRLG18=Ошибка!
HRTYP0=Неизвестно
HRTYP1=Звук
HRTYP2=Видео
HRTYP3=Картинки
HRTYPM=Другое
HRTYPE=Тип (%i)
HRD000=Настройки MPEG-1/2 Audio и AAC (ADTS)
HRD100=Форматы MPEG-1/2 Audio для поиска в 
HRD101=Неофициально
HRD200=Предел по
HRD211=Минимальное количество кадров:
HRD212=Максимальное количество кадров:
HRD213=кадр(ов)
HRD221=Мин. размер:
HRD222=Макс. размер:
HRD223=Байт
HRD300=Специально для MPEG-1/2 Audio
HRD301=Искать (и использовать) заголовок Xing VBR
HRD302=Искать ID3Tag v1.0/1.1

LST000=Создать список
LST001=Сортировка
LST100=Шаблон
LST101=Версия:
LST102=Автор:
LST103=Email:
LST104=URL:
LST200=Список
LST201=Выбранные записи
LST202=Все записи
LST203=Текущая папка
LST204=Включая подпапки
LST300=Сортировать по
LST301=имени
LST302=размеру
LST303=смещению
LST304=Инверсия
LST400=ВНИМАНИЕ: Сортировка замедлит составление списка...
LST500=Сохранить список в...
LST501=Получение элемента Header из шаблона...
LST502=Получение элемента Footer из шаблона...
LST503=Получение элемента Variable из шаблона...
LST504=Получение записей...
LST505=Сортировка %v записей...
LST506=Подсчёт %v записей... %p%
LST507=Сохранение списка файлов...
LST508=Извлечение сопутствующих файлов из шаблона...
LST509=Готово!

11TH05=Состояние плагина: %s%n(Вкл. означает, что вы можете открывать файлы .GJD из The 11th Hour)%n(Откл. означает, что вам нужно импортировать GJD.GJD и DIR.RL)
11TH06=Откл.
11TH07=Вкл.

DUT100=Конфигурация
DUT101=Библиотека
DUT110=ID
DUT111=Путь
DUT112=Подсказка для игры
DUT113=DA?
DUT114=GID
DUT201=Пакет из какой игры вы открываете?
DUT202=Больше не спрашивать для этой папки
DUT203=- Неизвестно / другое -

EX=Файл %e
EXANIM=Анимация (%e)
EXART=Art-пакет (текстуры)
EXBIN=Данные (%e)
EXCFG=Конфигурация (%e)
EXDLL=Динамически связываемая библиотека
EXFIRE=Текстура огня (динамич.)
EXIMG=Изображение %e (%d)
EXMAP=Карта уровня (%e)
EXMDL=3D модель (%e)
EXMPEG=Аудио/видео MPEG
EXMUS=Музыка (%d)
EXPAL=Палитра
EXSCRP=Сценарий (%e)
EXSND=Звуки (%d)
EXSPR=Спрайт
EXTEX=Текстура (%e)
EXTXT=Текст. документ

LOG002=Загрузка плагинов-драйверов...
LOG003=Загрузка плагинов-конверторов...
LOG004=Загрузка плагинов HyperRipper...
LOG005=Используются библиотеки:
LOG009=%p плагин(ов)
LOG020=Загрузка темы: %t
LOG021=Получение значков меню и панелей инструментов
LOG022=Получение значков типов файлов
LOG023=Найдено значков: %i / сопоставлено: %a
LOG101=Открываем файл "%f":
LOG102=Формат файла не распознан!
LOG103=Запуск HyperRipper...
LOG104=Файл не найден (или заблокирован другой программой)...
LOG200=Закрытие текущего файла...
LOG300=Отображение записей папки "%d"...
LOG301=%e записей...
LOG400=Использовать SmartOpen для определения исходного файла.
LOG500=Плагин-драйвер "%d" считает, что может открыть этот файл.
LOG501=Открытие файла с использованием плагина "%d"...
LOG502=Получение %x записей...
LOG503=Разбор записей для папок...
LOG504=Файл успешно открыт с помощью плагина "%p" (определён формат: "%f")
LOG505=Пропущена запись: %f (%r)...
LOG506=Размер равен нулю
LOG507=Смещение меньше нуля
LOG510=Готово!
LOG511=Успешно!
LOG512=Провал!
LOG513=Ошибка!
LOGC01=Освобождение %p плагина(ов)...
LOGC02=Поиск плагинов...
LOGC10=Преобразование из "%a" в "%b"...
LOGC11=Быстрый метод!
LOGC12=Медленный метод (устаревшие плагины)!
LOGC13=Преобразование в "%b"...
LOGC14=Преобразование нескольких записей в "%b"...
LOGC15=Преобразование...

PRV000=Предпросмотр:
PRV001=Нечто непонятное! (Предпросмотр невозможен)
PRV002=Предпросмотр невозможен...
PRV003=Отменено: размер превышает предел (%s Байт)
PRV004=Загрузка
PRV005=Отображение
PRV006=OK
PRV007=Плагины-конверторы:
PRV008=Формат: %f
PRV009=Определение
PRV010=Извлечение

ERR000=Ошибка
ERR101=Ошибка при извлечении.
ERR102=Ошибка во время извлечения файла:
ERR200=Произошла следующая необработанная ошибка:
ERR201=От:
ERR202=Исключение:
ERR203=Сообщение:
ERR204=Если вы хотите сделать отчет об ошибке, включите следующую информацию (нажмите кнопку «Подробнее»).
ERR205=Копировать в буфер обмена
ERR206=Отправить отчёт об ошибке:
ERRCAL=Ошибка при вызове:
ERRCMP=Следующий сопутствующий файл не найден:%n%n%f
ERREMP=Файл пуст.
ERREXT=Ошибка при извлечении данных (режим файла) драйвером %f:
ERRSTM=Ошибка при извлечении данных (режим потока) драйвером %f:
ERRFIL=Этот файл не похож на правильный %f файл (%g).
ERROPN=Ошибка при открытии исходного файла:%n%n%f
ERRUNK=Для открытия этого файла нет соответствующего драйвера.
ERRTMP=Невозможно удалить следующий временный файл:%n%n%f
ERRD01=Драйвер не может быть загружен (неверная версия интерфейса или это не плагин-драйвер для DUP5).
ERRD02=Драйвер не может быть загружен (отсутствуют важные функции).
ERRDRV=Ошибка при использовании драйвера "%d":
ERRDR1=For more information about this error please contact the driver's author (%a).
ERRC01=Плагин-конвертор не может быть загружен (неверная версия интерфейса или это не плагин-конвертор для DUP5).
ERRC02=Плагин-конвертор не может быть загружен (отсутствуют важные функции).
ERRC10=Ошибка во время преобразования палитры.%nНевозможно добавить новую палитру.
ERRH01=Плагин HyperRipper не может быть загружен (неверная версия интерфейса или это не плагин HyperRipper для DUP5).
ERRH02=Плагин HyperRipper не может быть загружен (отсутствуют важные функции).
ERRH03=Внимание: Это расширение не может работать с данными после первых 2 ГБ (после этого предела ничего не может быть найдено).
ERRH04=Неизвестный ID плагина #%i для HyperRipper
ERRH05=Плагин "%p" не может искать дальше 2 ГБ.
ERRIO=Невозможно открыть следующий файл:%n%n%f%n%nПроверьте его доступность и не открыт ли он в другой программе.
ERR900=В плагине отсутствует функция %f...

{/BODY}
#
# End of Language Source File
#
{/LSF}
