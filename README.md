# DRFishupKit для Mac OSX и iOS


Framework DRFishupKit был создан для поддержки взаимодействия с сервисом [**Fishup**](http://http://www.fishup.ru) в приложениях для **Mac OSX** и **iOS** (то есть для iPhone и iPad). Framework написан на Objective-C - естественном языке программирования для Mac OSX. 

Все проекты были собраны в Xcode 4.5 (*вероятно можно будет собрать их и в более младшей версии... хотя, не вижу смысла работать в устаревшей IDE*).
     
    Минимальной платформой для приложений Mac является OSX 10.7 (Lion)
    и для мобильных устройств iOS 5. 

Для взаимодействия с Fishup используется **public API** сервиса, наиболее последнее описание которого можно скачать в [разделе для разработчиков](http://www.fishup.ru/developer/api). В качестве сетевой библиотеки используется framework [MKNetworkKit](https://github.com/MugunthKumar/MKNetworkKit), созданный [Mugunth Kumar](http://blog.mugunthkumar.com). 

---
### Как подключить DRFishupKit к своему проекту?

1. Добавьте проект DRFishupKit к вашему проекту;
2. Добовьте `CFNetwork.Framework`, `SystemConfiguration.framework` и `Security.framework` в блок "Linked Frameworks and Libraries" для вашего проекта;
3. Добавьте `DRFishupKit.framework` туда же (если вы правильно добавили проект, то этот выбор появится у вас в блоке "Workspace");
4. Включите `DRFishupKit.h` в ваш PCH файл (или вы можете добавлять импорт этого файла в заголовочный (.H) файл каждого класса, что работает с Fishup.

Собственно, это все.


---
### Как использовать
Подробнее читайте в файле [DRFishupKit.pages](https://github.com/picasso/DRFishupKit/blob/master/DRFishupKit.pages). Я предполагаю, что у всех, кто работает на Mac есть **Pages**. Ну а мне гораздо удобнее работать в нормальном текстовом редакторе, чем использовать специализированную разметку файлов.

---
### TODO

* Исправить загрузку параметров из ApiHelper для методов POST
* Сделать метод для остановки всей очереди загрузки (cancel)
* Написать пример для iOS

Не могу сказать, что я сделаю это в самом ближайшем будущем, но надолго планирую  не откладывать

---
### Known Issues
* При вызове через ApiHelper метода POST словарь не объединяется с передаваемыми параметрами
* Не до конца проверен парсер WDDX при получении ошибок от загрузчика Fishup





