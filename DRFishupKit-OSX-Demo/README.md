#Сложный пример DRFishupKit для Mac OSX

Данный пример демонстрирует методы работы с Fishup API и представляет из себя небольшое, но реально функционирующее приложение. Для первого знакомства с API я бы рекомендовал изучить [простой пример](https://github.com/picasso/DRFishupKit/tree/master/DRFishupKit-OSX-SimpleDemo), поскольку там нет почти ничего, кроме вызовов API - нажимаешь на кнопку и получаешь структуру данных.   

В этом примере данные от Fishup преобразуются и отображаются в виде коллекции картинок. Также в приложении присутствуют эффекты и анимация. Все это значительно усложняет код и, соответственно, его понимание. Но зато это дает реальный пример использования API. 
Подробнее о DRFishupKit читайте в файле [DRFishupKit.pages](https://github.com/picasso/DRFishupKit/blob/master/DRFishupKit.pages).---###Общая информация Для навигации в приложении используется `NSOutline`, а для отображения коллекции картинок `IKImageBrowserView`. Оба класса требуют для своей работы поддержки протоколов `dataSource` и `delegate`. Я не буду пояснять как все это работает - об этом много написано в документации Apple.
Я специально не оптимизировал код чтобы облегчить его понимание. Поэтому там много повторов. Но мне кажется, что с этим будет гораздо проще разобраться. По этой же причине я не разделял функциональность на классы и не делил nib файлы на несколько более мелких.
###Навигация  Навигация работает через NSOutline, который инициализируется из массива словарей. Элементами массива являются объекты c ключами "name" и "selector". Значение по ключу "name" отображется в списке, а значение по ключу "selector" используется для вызова нужного метода, который и занимается выполнением запроса.
###Коллекция картинок

Полученные с Fishup изображения отображаются с помощью `IKImageBrowserView`. Для отображения требуется сначала загрузить снимки по полученным ссылкам, а потом предоставить их классу `IKImageBrowserView` для отображения. Загрузка происходит в методе `imageBrowser: itemAtIndex:` с помощью вызова API `imageAtURL:`. По завершении операции вызовается блок аргумента `onCompletion:`. Вы должны понимать, что этот блок вызывается один или два раза. Если данные запрашиваются в первый раз и кэше ничего нет, блок сработает единожды. Если данные уже есть в кэше, то сначала блок вызовется с данными из кэша, а уже второй раз с данными от сервера. Вы можете как-то анимировать процесс получения новых данных при желании.
   ``` objectivec[self.engine imageAtURL:cell.url
 
           onCompletion:^(NSImage *fetchedImage, NSURL *url, BOOL isInCache) {
               
               if([[cell.url absoluteString] isEqualToString:[url absoluteString]]) {
                   
                   if(isInCache) {
                       cell.image = fetchedImage;
                   } else {
                       cell.image = fetchedImage;
                       [self.browser setNeedsDisplay:YES];
                   }
               }
}];
```###Преобразование полученных данныхДанные от сервера приходят в разных структурах и для того, чтобы привести их к некому единому знаменателю используются свойста класса, которые хранят ключи для выборок из результатов. Так, например, для большинства запросов свойство `subtitle` для `IKImageBrowserView` получается по ключу "**author**". Хотя для выборки из круга общения это свойство заполняется по ключу "**base_hostname**".
###Просмотр своих альбомовПосле вывода списка альбомов можно перейти к просмотру его содержимого - через двойной клик на картинке альбома. Для того, чтобы снова вернутся к списку альбомов - нужно выбрать этот пункт в навигационном меню. 
###Ограничение выборокИмейте ввиду, что все выборки сейчас ограничены значение свойства `perPage` класса `DRFishupEngine`, которое по умолчанию равняется 50. Поэтому во всех списках отображаются только первые 50 изображений (или меньше). Для того чтобы отобразить все снимки нужно изменить значение этого свойства или организовать страничную подкачку - что уже выходит за рамки данного примера.
###Загрузка фотографий в новый альбомДанный пример практически не отличается от варианта описанного в  [простом примере](https://github.com/picasso/DRFishupKit/tree/master/DRFishupKit-OSX-SimpleDemo), но с двумя исключениями. Перед загрузкой файлов пользователю предлагается выбрать альбом, в который будет осуществляться загрузка, а после загрузки отображается содержимое альбома с добавленными файлами (**!обратите внимание, что если в альбоме уже было 50 файлов и более, то вы не увидете добавленные изображения из-за ограничения выборки**).
###Эффекты и анимация
Я не стал тратить много времени на анимацию. Я добавил лишь "встряску" окна ввода логина при неверной авторизации и затемнение экрана на момент обращения к серверу. Причем затемнение работает только во время основного запроса - в момент подкачки самих изображений оно уже неактивно.
