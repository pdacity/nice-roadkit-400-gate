# Интеграция ворот Nice RoadKit 400 в Home Assistant

## О проекте 

Практически универсальный способ интеграции автоматических ворот которые могут отррываться с пульта в Home Assistant

Способ годится и для любого другого оборудования с радио пультами. Минус решения - нет обратной связи, пульт только отсылает сигналы, но не проверяет состояние. Решается установкой герконовых датчиков. У меня на ворота смотрит камера и можно контролировать визуально. 

Идея проста - использовать родной пульт, просто эмулируя нажатие кнопок на нем. 

## Железо 

- дополнительный пульт, который привязывается к воротам (см документацию на блок управления воротами) (https://market.yandex.ru/product--pult-nice-flo2re/1740609984)
- 2-х канальное реле с сухими контактами (https://aliexpress.ru/item/1005001860518730.html)
- USB2TTL CH340N адаптер для первоначальной прошивки (https://aliexpress.ru/item/1005005834078608.html)

#### Пульт

Контроллер ворот позволяет подключить до 250 пультов (зависит от модели). Покупаем новый дополнительный пульт, поддерживающий протокол контроллера ворот и привязываем его к контроллеру. Например такой:

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/transmitter_01.jpg)

Паралельно кнокам на пульте полключаем сухие контакты от реле. 

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/transmitter_pinout_01.jpg)
![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/transmitter_pinout_02.jpg)

#### Реле

Реле необходимо именно с сухими контактами (dry contacts) которые гальванически развязаны от цепи питания реле. Например такое:

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/relay.jpg)

В выбранном мной реле используется контроллер esp8265 - необходимо подключить контакты с сингнальной землей GND, TX и RX 

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/esp8265_pinout_1.jpg)

| Signal | PIN |
|--------|--------|
| GND | 20 |
| RX | 21 |
| TX | 22 |

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/esp8265_pinout.png)

### Прошивка
Чтобы перевести плату реле в режим прошивки нужно зажать кнопку GPIO0, не отпуская ее подключить питание через microUSB, затем отпускаем кнопку GPIO0 и подключаем uart адаптер к usb.


## Код для ESPHOME

В коде добавлен запрет на одновременное срабатывание 2 реле, дабы избежать неопределенного состояния контроллера ворот.

Пульт срабатывает как и при нажатии кнопок на реле, так и по командам из  HomeAssistant. Отображается статус ручного нажатия на кнопки реле.

## Home Assistant

После подключения реле с пультом в Settings - Devices & Servicess - ESPHome появится новое устройство
![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/ha_00.png)

добавляем в Dashboard 

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/ha_01.jpg)
![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/ha_02.jpg)

## Original eWeLink Firmware backup
В каталоге firmware - бакап оригинальной прошивки реле от  eWeLink и скрипты для бакапа и восстановления. 

--- 

## References:
TASMOTA esp8265 - https://templates.blakadder.com/LC-EWL-B04-MB.html

PSF-B04 Application Guide - https://itead.cc/diy-kits-guides/psf-b04-application-guide/

Tasmota 4 channel relay - https://community.home-assistant.io/t/hacking-the-psf-b04-esp8285-4-channel-relay-board-and-with-tasmota-and-unable-to-drive-all-4-relays-concurrently/155919

Nice RoadKit 400 documentation (RUS) - https://www.bramy.ru/assets/files/documents/otkatnye-vorota/nice/instrukciya-po-montazhu-i-nastrojke-privoda-nice-rd400.pdf

Список реле с сухим контактом - https://ivan.bessarabov.ru/blog/relay-with-dry-contacts

Еще реле с сухим контактом - https://sonoff.ru/catalog/wifi-rele/rele-s-sukhim-kontaktom
