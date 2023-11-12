# Интеграция ворот Nice RoadKit 400 в Home Assistant

![PizzaWare](https://img.shields.io/badge/%F0%9F%8D%95-PizzaWare-orange)
![Tea powered](https://img.shields.io/badge/%F0%9F%8D%B5-tea%20powered-yellowgreen)

## О проекте 

Практически универсальный способ интеграции автоматических ворот которые могут отррываться с пульта в Home Assistant

Способ годится и для люубого другого оборудования с радио пультами. Минус решения - нет обратной связи, пульт только отсылает сигналы, но не проверяет состояние. Решается установкой герконовых датчиков. У меня на ворота смотрит камера и можно контролировать визуально. 

Идея проста - использовать родной пульт, просто эмулируя нажатие кнопок на нем. 

## Железо 

- дополнительный пульт, который привязывается к воротам (см документацию на блок управления воротами)
- 2-х канальное реле с сухими контактами
- USB2TTL адаптер для первоначальной прошивки.

#### Пульт

Контроллер ворот позволяет подключить до 250 пультов (зависит от модели). Покупаем новый дополнительный пульт, поддерживающий протокол контроллера ворот и привязываем его к контроллеру. Например такой:

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/transmitter_01.jpg)

Паралельно кнокам на пульте полключаем сухие контакты от реле. 

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/transmitter_pinout_01.jpg)
![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/transmitter_pinout_02.jpg)

#### Реле

Реле необходимо именно с сухими контактами (dry contacts) которые гальванически развязаны от цепи питания реле. Например такое:

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/relay.jpg)

В выбранном мной реле используется контроллер esp8265 - необходимо подключить контакты с сингнальной землей, TX и RX 

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/esp8265_pinout_1.jpg)


### Прошивка
Чтобы перевести плату рэле в режим прошивки нужно зажать кнопку GPIO0, не отпуская ее подключить питание через microUSB, затем отпускаем кнопку GPIO0 и подключаем uart адаптер к usb.


## Код для ESPHOME

После добавления реле в ESPHome и генерации токена, задания креденшиалс для точки доступа и т.д. к дефолтовому блоку кода с подключением к WiFi, токеном и прочим добавьте:

```yaml
###[ Nice RoadKit 400 ]###

status_led:
 pin: 13

binary_sensor:

# Кнопка 1
  - platform: gpio
    pin:
      number: 9
      mode: INPUT_PULLUP
      inverted: true
    name: "button1"
    id: button1

# Нажатие кнопки1 переключает реле1
    on_click:
      min_length: 50ms
      max_length: 500ms
      then:
        - switch.turn_on: relay1
        - delay: 500ms
        - switch.turn_off: relay1
        - delay: 500ms
        - switch.turn_off: relay1

# Кнопка 2
  - platform: gpio
    pin:
      number: 0
      mode: INPUT_PULLUP
      inverted: true
    name: "button2"
    id: button2

# Нажатие кнопки2 переключает реле2
    on_click:
      min_length: 50ms
      max_length: 350ms
      then:
        - switch.turn_on: relay2
        - delay: 500ms
        - switch.turn_off: relay2
        - delay: 500ms
        - switch.turn_off: relay2

switch:
# Реле 1
  - platform: gpio
    name: "relay1"
    pin: GPIO12
    id: relay1
    icon: "mdi:gate"
    # запрет на одновременное переключение
    interlock: [relay2]
    on_turn_on:
    - delay: 500ms
    - switch.turn_off: relay1

# Реле 2
  - platform: gpio
    name: "relay2"
    pin: GPIO5
    id: relay2
    icon: "mdi:gate-open"
    # запрет на одновременное переключение
    interlock: [relay1]
    on_turn_on:
    - delay: 500ms
    - switch.turn_off: relay2
```
В коде добавлен запрет на одновременное срабатывание 2 реле, дабы избежать неопределенного состояния контроллера ворот.

Пульт срабатывает как и при нажатии кнопок на рэле, так и по командам из  HomeAssistant.

## Home Assistant

После подключения реле с пультом в Settings - Devices & Servicess - ESPHome появится новое устройство
![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/ha_00.png)

добавляем в дашбоард 

![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/ha_01.jpg)
![](https://github.com/pdacity/nice-roadkit-400-gate/blob/main/images/ha_02.jpg)

## ToDo
- [ ] добавить индикацию светодиодом при нажатии срабатывании реле.

--- 

References:
TASMOTA esp8265 - https://templates.blakadder.com/LC-EWL-B04-MB.html
