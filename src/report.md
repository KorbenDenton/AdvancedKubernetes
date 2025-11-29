## Part 1. Развертывание собственного кластера k3s
1) Получаем набор виртуальных машин для кластера, для этого используем `Vagrant`  
    - Пишем конфиг вагранта  
    ![Alt text](<screens/Снимок экрана 2025-11-03 в 13.43.28.png>)  
    - Смотрим статус  
    ![Alt text](<screens/Снимок экрана 2025-11-03 в 13.43.59.png>)  
2) Устанавливаем `k3s` на всех трех машинах, при этом используем флаг `--disable=traefik`, чтобы не устанавливать стандартный Ingress Controller k3s  
    - Сначала мастер нода
    ![Alt text](<screens/Снимок экрана 2025-11-03 в 15.26.39.png>)  
    Берем токен для воркеров при помощи <screens/pre>sudo cat /var/lib/rancher/k3s/server/node-token<screens//pre>  
    - Теперь воркеры
    ![Alt text](<screens/Снимок экрана 2025-11-03 в 17.16.26.png>)  
    ![Alt text](<screens/Снимок экрана 2025-11-03 в 17.27.03.png>)  
3) Выполняем подключение узлов к кластеру. Для воркеров используем переменную окружения `NODE_TOKEN`
    - на мастере
    ![Alt text](<screens/Снимок экрана 2025-11-03 в 17.29.23.png>)  
    - на воркерах  
    ![Alt text](<screens/Снимок экрана 2025-11-03 в 17.19.56-1.png>)
    ![Alt text](<screens/Снимок экрана 2025-11-03 в 17.31.43.png>)
    Смотрим, что все встало как надо  
    ![Alt text](<screens/Снимок экрана 2025-11-03 в 17.55.27.png>)
4) Устанавливаем Ingress Controller Nginx вместо стандартного с github
    ![Alt text](<screens/Снимок экрана 2025-11-03 в 18.03.58.png>)
5) Получаем доменное имя и конфигурируем внутри кластера утилиту cert-manager, которая должна генерировать wildcard-сертификат для полученного домена  
    - Установка `cert-manager` при помощи  
    <pre>kubectl apply -f https://github.com/cert-manager/cert-manager releases/download/v1.17.1/cert-manager.yaml</pre>
    - Пишем `clusterissuer`, выдающий самоподписанные сертификаты  
    ![alt text](screens/image-1.png)
    - Пишем `cerificate`, чтобы запросить сертификат  
    ![alt text](screens/image-3.png)  
6) Создаем `Ingress` для своего личного домена и настраиваем его для использования контроллера `nginx ingress` и полученного сертификата.  
    ![alt text](screens/image-4.png)
7) Создаем PV и PVC для `postgres`  
    ![Alt text](<screens/Снимок экрана 2025-11-10 в 13.14.12.png>)
8) Применяем манифесты и запускаем приложение  
    ![Alt text](<screens/Снимок экрана 2025-11-10 в 16.06.05.png>)
    ![Alt text](<screens/Снимок экрана 2025-11-10 в 16.10.37.png>)
    ![alt text](screens/image.png)
    ![alt text](screens/image-5.png)
9) Запускаем функциональные тесты Postman, чтобы удостовериться в работоспособности приложения, для этого немного меняем конфигурацию тестов, чтобы запросы шли не по `localhost:port, а по домену`  
    ![alt text](screens/image-6.png)  
10) Устанавливаем и запускаем `Prometheus Operator` в отдельный `namespace`, показываем результат команды `kubectl get pods -n monitoring`
    ![alt text](screens/image-7.png)
    ![alt text](screens/image-8.png)