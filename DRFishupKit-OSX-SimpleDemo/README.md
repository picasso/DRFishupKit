#Простые примеры DRFishupKit для Mac OSX

Подробнее о DRFishupKit читайте в файле [DRFishupKit.pages](https://github.com/picasso/DRFishupKit/blob/master/DRFishupKit.pages).

---
###Первые шагиДля того, чтобы использовать в своем проекте DRFishupKit вам необходимо создать объект класса DRFishupEngine, через который вы будете осуществлять все операции по взаимодействию с Fishup API. Я предпочитаю сохранять этот объект в свойстве либо класса реализуещего `Application Delegate`, либо в свойстве класса реализующего `Window Controller`. Затем вам необходимо задать блок для обработчика ошибок (если он вам нужен) и блок для индикации сетевой активности (опять же, если это требуется).

 <style type="text/css">
div.objc {margin:20px;padding:10px;background:#fff;border:1px solid #d9ebf6;}
p.p1 {margin: 0; font: 12px Helvetica}
p.p2 {margin: 0; font: 12px Helvetica; min-height: 14px}
p.p3 {margin: 0; font: 12px Menlo; color: #578085}
p.p4 {margin: 0; font: 12px Menlo; min-height: 10}
p.p5 {margin: 0; font: 12px Menlo}
p.p6 {margin: 0; font: 12px Menlo; color: #1d8917}
p.p7 {margin: 0; font: 12px Menlo; color: #43007e}
p.p8 {margin: 0; font: 12px Menlo; color: #c5232c}
p.p9 {margin: 0; font: 12px Menlo; color: #3a595d}
p.p10 {margin: 0; font: 12px Menlo; color: #734a31}
span.s1 {letter-spacing: 0}
span.s2 {font: 11px Menlo; letter-spacing: 0; color: #78009b}
span.s3 {letter-spacing: 0; color: #b3009f}
span.s4 {letter-spacing: 0; color: #000000}
span.s5 {letter-spacing: 0; color: #43007e}
span.s6 {letter-spacing: 0; color: #578085}
span.s7 {letter-spacing: 0; color: #3a595d}
span.s8 {letter-spacing: 0; color: #7124a5}
span.s9 {letter-spacing: 0; color: #4200d3}
span.s10 {font: 11px Menlo; letter-spacing: 0; color: #578085}
span.s11 {letter-spacing: 0; color: #734a31}
span.s12 {letter-spacing: 0; color: #c5232c}
 </style>

<div class="objc">
<p class="p3"><span class="s3">self</span><span class="s4">.</span><span class="s1">engine</span><span class="s4"> = [[</span><span class="s1">DRFishupEngine</span><span class="s4"> </span><span class="s5">alloc</span><span class="s4">] </span><span class="s5">init</span><span class="s4">];</span></p>
<p class="p4"><span class="s1"></span><br></p>
<p class="p5"><span class="s1">[</span><span class="s3">self</span><span class="s1">.</span><span class="s6">engine</span><span class="s1"> </span><span class="s7">onError</span><span class="s1">:^(</span><span class="s8">NSError</span><span class="s1"> *error) {</span></p>
<p class="p4"><span class="s1"><span class="Apple-converted-space">  </span></span></p>
<p class="p6"><span class="s4"><span class="Apple-converted-space">    </span></span><span class="s3">if</span><span class="s4">(error.</span><span class="s5">code</span><span class="s4"> == </span><span class="s9">16000</span><span class="s4">) { </span><span class="s1">// Данный метод требует дополнительных параметров</span></p>
<p class="p7"><span class="s4"><span class="Apple-converted-space">        </span>[[</span><span class="s8">NSAlert</span><span class="s4"> </span><span class="s1">alertWithError</span><span class="s4">:error] </span><span class="s1">runModal</span><span class="s4">];</span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">    </span>}</span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">    </span></span><span class="s3">else</span></p>
<p class="p8"><span class="s4"><span class="Apple-converted-space">        </span></span><span class="s5">NSLog</span><span class="s4">(</span><span class="s1">@"Произошла ошибка:%@"</span><span class="s4">, error);</span></p>
<p class="p5"><span class="s1">}];</span></p>
<p class="p4"><span class="s1"></span><br></p>
<p class="p9"><span class="s4">[</span><span class="s3">self</span><span class="s4">.</span><span class="s6">engine</span><span class="s4"> </span><span class="s1">onNetworked</span><span class="s4">:^{</span></p>
<p class="p4"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p3"><span class="s4"><span class="Apple-converted-space">    </span></span><span class="s3">if</span><span class="s4">(</span><span class="s3">self</span><span class="s4">.</span><span class="s1">engine</span><span class="s4">.</span><span class="s1">isNetworkActive</span><span class="s4">)</span></p>
<p class="p3"><span class="s4"><span class="Apple-converted-space">        </span>[</span><span class="s3">self</span><span class="s4">.</span><span class="s1">networkActivity</span><span class="s4"> </span><span class="s5">startAnimation</span><span class="s4">:</span><span class="s3">self</span><span class="s4">];</span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">    </span></span><span class="s3">else</span></p>
<p class="p3"><span class="s4"><span class="Apple-converted-space">        </span>[</span><span class="s3">self</span><span class="s4">.</span><span class="s1">networkActivity</span><span class="s4"> </span><span class="s5">stopAnimation</span><span class="s4">:</span><span class="s3">self</span><span class="s4">];</span></p>
<p class="p5"><span class="s1">}];</span></p>
</div>


###Пример 1. Получение информации о пользователеСчитаем что объект  класса DRFishupEngine у нас уже создан и обработчик ошибок для него установлен. Чтобы получить публичную информацию о пользователе Fishup нужно вызвать метод `accounts.user.getPublicData` и передать в качестве параметра ID пользователя о котором мы хотим получить данные. В данном примере данные полученные от Fishup выводятся в в `NSTextView`.<div class="objc">
<p class="p8"><span class="s4">[</span><span class="s3">self</span><span class="s4">.</span><span class="s6">engine</span><span class="s4"> </span><span class="s7">sendAPI</span><span class="s4">:</span><span class="s1">@"accounts.user.getPublicData"</span></p>
<p class="p7"><span class="s4"><span class="Apple-converted-space">          </span></span><span class="s7">withParams</span><span class="s4">:[</span><span class="s8">NSDictionary</span><span class="s4"> </span><span class="s1">dictionaryWithObject</span><span class="s4">:</span><span class="s11">kUserID</span><span class="s4"> </span><span class="s1">forKey</span><span class="s4">:</span><span class="s12">@"id"</span><span class="s4">]</span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">        </span></span><span class="s7">onCompletion</span><span class="s1">:^(</span><span class="s8">NSDictionary</span><span class="s1"> *data) {</span></p>
<p class="p4"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p7"><span class="s4"><span class="Apple-converted-space">    </span>[</span><span class="s3">self</span><span class="s4">.</span><span class="s6">fishupResponse</span><span class="s4"> </span><span class="s1">setString</span><span class="s4">:[data </span><span class="s1">description</span><span class="s4">]];</span></p>
<p class="p5"><span class="s1">}];</span></p>
</div>###Пример 2. Получение списка популярных фотографийТеперь воспользуемся словарем `ApiHelper` для получения списка популярных фотографий за определенный период. В словаре есть ключи для запросов с периодом на год, месяц и неделю. Необходимо указать только ключ словаря (в данном случае это будет ключ "**top**" и ключ следующего уровня "**year**") и все. Название метода и необходимые параметры будут взяты из словаря.<div class="objc">
<p class="p9"><span class="s4">[</span><span class="s3">self</span><span class="s4">.</span><span class="s6">engine</span><span class="s4"> </span><span class="s1">sendAPI</span><span class="s4">:</span><span class="s12">@"top.year"</span><span class="s4"> </span><span class="s1">onCompletion</span><span class="s4">:^(</span><span class="s8">NSArray</span><span class="s4"> *data) {</span></p>
<p class="p4"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p7"><span class="s4"><span class="Apple-converted-space">    </span>[</span><span class="s3">self</span><span class="s4">.</span><span class="s6">fishupResponse</span><span class="s4"> </span><span class="s1">setString</span><span class="s4">:[data </span><span class="s1">description</span><span class="s4">]];</span></p>
<p class="p5"><span class="s1">}];</span></p>
</div>
###Пример 3. Получение списка альбомов для своего аккаунтаДля получения списка своих альбомов необходимо сначала авторизоваться и получить `token`. Cделаем это синхронным методом с ожиданием ответа от сервера. И при удачной авторизации запросим список альбомов. Чтобы продемонстрировать возможные преобразования полученных данных с помощью **KVC**, возьмем из структуры только ссылки на изображения вида *square* (маленькие квадратные превьюшки). 
<div class="objc">
<p class="p10"><span class="s3">BOOL</span><span class="s4"> isLoginOk = [</span><span class="s3">self</span><span class="s4">.</span><span class="s6">engine</span><span class="s4"> </span><span class="s7">login</span><span class="s4">:</span><span class="s1">kFishupMyLogin</span><span class="s4"> </span><span class="s7">password</span><span class="s4">:</span><span class="s1">kFishupMyPassword</span><span class="s4"> </span><span class="s7">andWait</span><span class="s4">:</span><span class="s3">YES</span><span class="s4">];</span></p>
<p class="p4"><span class="s1"></span><br></p>
<p class="p5"><span class="s3">if</span><span class="s1">(isLoginOk) {</span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">    </span>[</span><span class="s3">self</span><span class="s1">.</span><span class="s6">engine</span><span class="s1"> </span><span class="s7">sendAPI</span><span class="s1">:</span><span class="s12">@"my.albums"</span><span class="s1"> </span><span class="s7">onCompletion</span><span class="s1">:^(</span><span class="s8">NSArray</span><span class="s1"> *data) {</span></p>
<p class="p4"><span class="s1"><span class="Apple-converted-space">        </span></span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">        </span></span><span class="s8">NSArray</span><span class="s1"> *squareURLs = [data </span><span class="s5">valueForKeyPath</span><span class="s1">:</span><span class="s12">@"photo.square.url"</span><span class="s1">];</span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">        </span>[</span><span class="s3">self</span><span class="s1">.</span><span class="s6">fishupResponse</span><span class="s1"> </span><span class="s5">setString</span><span class="s1">:[squareURLs </span><span class="s5">description</span><span class="s1">]];</span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">    </span>}];</span></p>
</div>###Пример 4. Загрузка фотографий в новый альбомПодробно про технологию загрузки файлов на Fishup описано в [DRFishupKit.pages](https://github.com/picasso/DRFishupKit/blob/master/DRFishupKit.pages). Данный пример лишь демонстрирует описанные шаги: добавление списка файлов в очередь загрузки, задание дополнительных атрибутов для этих файлов, задание блока для отображения прогресс-индикатора загрузки и старт процесса с указанием ID альбома.<div class="objc">
<p class="p5"><span class="s1">[</span><span class="s3">self</span><span class="s1">.</span><span class="s6">engine</span><span class="s1"> </span><span class="s7">addUploads</span><span class="s1">:urls];</span></p>
<p class="p4"><span class="s1"></span><br></p>
<p class="p5"><span class="s3">int</span><span class="s1"> i =</span><span class="s9">0</span><span class="s1">;</span></p>
<p class="p5"><span class="s3">for</span><span class="s1">(</span><span class="s8">NSURL</span><span class="s1"> *url </span><span class="s3">in</span><span class="s1"> urls) {</span></p>
<p class="p4"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">    </span></span><span class="s6">DRUploadFile</span><span class="s1"> *file = [</span><span class="s3">self</span><span class="s1">.</span><span class="s6">engine</span><span class="s1"> </span><span class="s7">uploadForPath</span><span class="s1">:[url </span><span class="s5">path</span><span class="s1">]];</span></p>
<p class="p4"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">    </span>file.</span><span class="s7">title</span><span class="s1"> = [</span><span class="s8">NSString</span><span class="s1"> </span><span class="s5">stringWithFormat</span><span class="s1">:</span><span class="s12">@"Myfile#%d"</span><span class="s1">, (i++ +</span><span class="s9">1</span><span class="s1">)];</span></p>
<p class="p8"><span class="s4"><span class="Apple-converted-space">    </span>file.</span><span class="s7">author</span><span class="s4"> = </span><span class="s1">@"Dmitry Rudakov"</span><span class="s4">;</span></p>
<p class="p8"><span class="s4"><span class="Apple-converted-space">    </span>file.</span><span class="s7">desc</span><span class="s4"> = </span><span class="s1">@"Apple has been busy updating Mac OS X to version 10.8"</span><span class="s4">;</span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">    </span>file.</span><span class="s7">tags</span><span class="s1"> = [</span><span class="s8">NSString</span><span class="s1"> </span><span class="s5">stringWithFormat</span><span class="s1">:</span><span class="s12">@"tag%d, tag%d, tag%d"</span><span class="s1">, i+</span><span class="s9">1</span><span class="s1">, i+</span><span class="s9">2</span><span class="s1">, i+</span><span class="s9">3</span><span class="s1">];</span></p>
<p class="p5"><span class="s1">}</span></p>
<p class="p4"><span class="s1"></span><br></p>
<p class="p5"><span class="s1">[</span><span class="s3">self</span><span class="s1">.</span><span class="s6">engine</span><span class="s1"> </span><span class="s7">onProgress</span><span class="s1">:^(</span><span class="s3">double</span><span class="s1"> progress) {</span></p>
<p class="p4"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">    </span>[</span><span class="s3">self</span><span class="s1">.</span><span class="s6">uploadProgress</span><span class="s1"> </span><span class="s5">setDoubleValue</span><span class="s1">:progress];</span></p>
<p class="p5"><span class="s1">}];</span></p>
<p class="p4"><span class="s1"></span><br></p>
<p class="p9"><span class="s4">[</span><span class="s3">self</span><span class="s4">.</span><span class="s6">engine</span><span class="s4"> </span><span class="s1">uploadToGallery</span><span class="s4">:</span><span class="s11">kFishupMyGalleryID</span><span class="s4"> </span><span class="s1">onCompletion</span><span class="s4">:^(</span><span class="s8">NSArray</span><span class="s4"> *list) {</span></p>
<p class="p4"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p8"><span class="s4"><span class="Apple-converted-space">    </span></span><span class="s5">NSLog</span><span class="s4">(</span><span class="s1">@"upload of %ld of %ld files completed\n"</span><span class="s4">, [list </span><span class="s5">count</span><span class="s4">], [urls </span><span class="s5">count</span><span class="s4">]);</span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">    </span></span><span class="s3">for</span><span class="s1">(</span><span class="s6">DRUploadFile</span><span class="s1"> *file </span><span class="s3">in</span><span class="s1"> list)</span></p>
<p class="p5"><span class="s1"><span class="Apple-converted-space">        </span></span><span class="s5">NSLog</span><span class="s1">(</span><span class="s12">@"%@ (id=%@)\n"</span><span class="s1">, file.</span><span class="s7">title</span><span class="s1">, file.</span><span class="s6">fileid</span><span class="s1">);</span></p>
<p class="p5"><span class="s1">}];</span></p>
</div>
