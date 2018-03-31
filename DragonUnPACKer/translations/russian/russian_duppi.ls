# Language Source File (for DLNGC v4.0)
# ============================================================================
#  Program: Duppi v3.3.4 (Dragon UnPACKer)
# Language: Russian
#  Version: 1
#   Author: Alexms69
# ============================================================================
#
# This file is the model for translations of Duppi (Dragon UnPACKer Package
# Installer).
#
# Just translate everything between {BODY} and {/BODY}
#
# Then compile the file with DLNGC and put the resulting .LNG file into the
# \Utils\ sub-directory of Dragon UnPACKer (along with Duppi.exe file).
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
# version 1:
# Initial release
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
# Duppi v3.0.0                   PI       1
# Duppi v3.1.0 - 3.1.3           PI       2
# Duppi v3.2.0 - 3.2.1           PI       3
# Duppi v3.3.0 - 3.3.3           PI       4
# Duppi v3.3.4                   PI       5
#
ProgramID = PI
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
PI0000=Определена версия DUP5:
PI0001=Название
PI0002=Автор
PI0003=Комментарий
PI0004=URL
PI0005=Инфо о пакете
PI0006=Пожалуйста, дождитесь, пока установится пакет...
PI0007=Эта программа установит данный пакет в папку Dragon UnPACKer.
PI0008=Для продолжения установки закройте Dragon UnPACKer 5.
PI0009=Состояние:
PI0010=Ожидание данных от пользователя...
PI0011=Вы действительно хотите выйти?
PI0012=Ошибка.. DUP5 запущен..
PI0013=Ошибка: запущен Dragon UnPACKer 5..%nЗакройте его и попробуйте снова.
PI0014=Критическая ошибка.. Неподдерживаемая версия файла пакета Dragon UnPACKer 5 (.D5P) [версия %v]
PI0015=Критическая ошибка.. Этот файл не является пакетом Dragon UnPACKer 5 (.D5P)
PI0016=Применение: duppi <file.d5p>%n%nВ папку Dragon UnPACKer 5 будет установлен файл пакета file.d5p.
PI0017=Файл не найден!%n%f
PI0018=Чтение пакета...
PI0019=Такой файл уже существует, обновлять его не нужно:%n%n%f%n%nТекущая версия: %1%nВерсия файла в пакете: %2%n%nВсё равно установить?
PI0020=У этого файла неверные контрольные суммы (CRC). Он будет пропущен.%nЕсли вы загружали этот файл, то попробуйте снова.%n%n%f
PI0021=У этого файла неправильный размер. Он будет пропущен.%nЕсли вы загружали этот файл, то попробуйте снова.%n%n%f
PI0022=Успешно установлено файлов: %i...
PI0023=Установка успешно прервана...
PI0024=Установка не удалась (файлов с ошибками: %e)...
PI0025=Установка не удалась... Успешно установлено файлов: %i, обнаружено ошибок: %e...
PI0026=Не найден путь к Dragon UnPACKer 5.%nПожалуйста, хотя бы раз запустите Dragon UnPACKer 5 и попробуйте снова.
PI0027=Пропуск...
PI0028=кБ
PI0029=Чтение...
PI0030=Распаковка...
PI0031=Запись...
PI0032=OK
PI0033=Версия
PI0034=Эта программа устанавливает пакеты для Dragon UnPACKer 5.
PI0035=Что вы хотите сделать?
PI0036=Проверить на наличие новых или обновлённых пакетов и установить их.
PI0037=Примечание: сайт Dragon Software не получает никаких данных о вас или о компьютере.
PI0038=Настройки прокси
PI0039=Установить пакет с жёсткого диска:
PI0040=Выберите пакет для установки...
PI0041=Для установки этого файла пакета Dragon UnPACKer 5 (D5P) вам нужна более новая версия Duppi.%nВаша версия Duppi: %y%nТребуемая версия Duppi: %v%n%nПожалуйста, обновите свою копию Dragon UnPACKer 5!
PI0042=Этот пакет не совместим с вашей версией Dragon UnPACKer.
PI0043=Невозможно зарегистритровать %s.
PI0044=С сервера обновлений получены неверные данные!
PI0045=Неизвестная папка назначения!
PI0046=Обновление Duppi успешно завершено!
PI0047=Доступна новая версия Duppi:%nВаша версия: %a%nДоступна версия: %b%nРазмер обновлений: %s КБ%n%nХотите обновить её сейчас (рекомендуется)?
PI0048=Также показывать нестабильные (alpha/beta/RC)
PI0049=Нет URL для обновления Duppi!
PI0050=Доступна для загрузки новая версия Dragon UnPACKer.%n%nНовая версия: %v%nРазмер обновления: %s КБ%nКомментарий: %c%n%nХотите провести обновление сейчас (рекомендуется)?
PI0051=Нет URL для обновления Dragon UnPACKer!
PI0052=%s Байт
PI0053=%s КиБ
PI0054=Пакет %a...
PI0055=Поиск блоков...
PI0056=Чтение блока "%a"...
PI0057=записей
PI0058=имён
PI0059=содержимого
PI0060=Установка файла %a: %b
PI0061=Регистрация OCX...
PI0062=Пакет успешно установлен.%nПрограмма Duppi перезапустится для применения обновлений.
PI0063=Получение информации о пакете...
PI0064=Пакет %d
PI0065=Найден и будет удалён следующий устаревший файл:%n%n%f%n%n
PI0066=Версия файла: %1%nУстаревшие версии: <= %2%n%n
PI0067=Продолжить и удалить (рекомендуется)?
PI0068=Удалено!
PI0069=Обнаружено несоответствие сборки Dragon UnPACKer, запускаемой последней: (%a) против (%b)  .%nПосле обновления вам нужно хотя бы раз запустить Dragon UnPACKer 5.%n%nВы хотите запустить его сейчас (рекомендуется)?

PI3001=Используется сервер %i: %d
PI3002=Неверный размер файла! (%a <> %b)
PI3003=Проверка целостности файла...
PI3004=Файл повреждён! (%a <> %b)
PI3005=Непредвиденное исключение %a: %b

PIE401=Неизвестная хэш-функция: %h
PIE402=Сбой поиска файла (%a <> %b)
PIE403=Ошибка при чтении файла (%a Байт <> %b Байт)
PIE404=Ошибка при распаковке %a (%b Байт <> %c Байт)
PIE405=Неподдерживаемый формат сжатия (%a)
PIE406=Неправильная хэш-сумма блока (%a <> %b)
PIE407=Не удалось найти блок (%a <> %b)
PIE408=Ошибка при чтении блока (%a Байт <> %b Байт)
PIE409=Ошибка при получении информации:
PIE410=Ошибка при получении баннера:
PIE411=Ошибка при получении данных блока "%a":

PII001=Название
PII002=Ваша версия
PII003=Доступна версия
PII004=Описание
PII005=Размер
PII011=Показать обновления:
PII012=Плагины
PII013=Переводы
PII021=Актуальная стабильная версия:
PII022=Актуальная нестабильная версия:
PII030=Перевод
PII031=Редакция
PII032=Автор
PII100=список обновлений
PII101=Загрузка %f...
PII102=Загрузка %f (получено %b Байт)
PII103=Успешно принято %f (%b Байт)
PII104=Ошибка: %c (%d)
PII105=Получен ответ от сервера!
PII106=-Нет описания-
PII107=Доступна для загрузки новая версия Dragon UnPACKer.%n%nНовая версия: %v%nКомментарий: %c%n%nХотите зайти на официальный сайт для её загрузки?
PII108=Доступно %p плагин(ов) и %t перевод(ов)!

PII200=Обновление не может быть загружено.%nСейчас программа завершит работу.

PIEM01=Ошибка соединения с базой данных. Пожалуйста, повторите попытку позже!
PIEM10=Ошибка при получении последней информации о стабильной версии ядра!
PIEM11=Ошибка при получении последней информации о нестабильной версии ядра!
PIEM12=Ошибка при получении информации о стабильном обновлении ядра!
PIEM13=Ошибка при получении информации о нестабильном обновлении ядра!
PIEM20=Ошибка при получении информации о вашей версии!
PIEM30=Ошибка при получении доступных стабильных версий драйверов-конверторов!
PIEM31=Ошибка при получении доступных стабильных плагинов драйверов!
PIEM32=Ошибка при получении доступных стабильных плагинов HyperRipper!
PIEM33=Ошибка при получении доступных переводов!
PIEM40=Ошибка при получении списка серверов!
PIEM41=Ошибка при получении доступных стабильных + нестабильных плагинов драйверов!
PIEM42=Ошибка при получении доступных стабильных + нестабильных плагинов-конвертеров!
PIEM43=Ошибка при получении доступных стабильных + нестабильных плагинов HyperRipper!
PIEM60=Ошибка при получении последней информации о версии Duppi!
PIEP01=Неверный параметр! Если вы ещё не запускали Dragon UnPACKer, то сделайте это и перезапустите Duppi позже.
PIEP02=Сервер не смог определить вашу версию Dragon UnPACKer...
PIEUNK=Неизвестная ошибка сервера: "%e"

PIP000=Конфигурация прокси
PIP001=Прокси:
PIP002=Порт прокси:
PIP003=Если требуется имя/пароль:
PIP004=Имя:
PIP005=Пароль:

BUTADD=Добавить
BUTCAN=Отмена
BUTCLO=Закрыть
BUTCNV=Конвертация
BUTCON=Продолжить
BUTDEL=Удалить
BUTDET=Подробнее
BUTDIR=Новая папка
BUTEDT=Правка
BUTGO=Пуск!
BUTINS=Установка
BUTNEX=Далее
BUTOK=OK
BUTPAL=Доб. палитру
BUTREF=Обновить
BUTREM=Удалить
BUTSCH=Поиск

{/BODY}
#
# End of Language Source File
#
{/LSF}
