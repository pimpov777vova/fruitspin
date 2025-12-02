import { useState } from "react";
import { Copy, Check, ChevronDown, ChevronRight, Server, Bot, CreditCard, Key, Shield, Terminal, Globe, AlertTriangle } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export function FullGuide() {
  const [copied, setCopied] = useState<string | null>(null);
  const [openSections, setOpenSections] = useState<string[]>(["step1"]);

  const copyToClipboard = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopied(id);
    setTimeout(() => setCopied(null), 2000);
  };

  const toggleSection = (id: string) => {
    setOpenSections(prev => 
      prev.includes(id) ? prev.filter(s => s !== id) : [...prev, id]
    );
  };

  const CodeBlock = ({ code, id }: { code: string; id: string }) => (
    <div className="relative">
      <pre className="bg-muted p-4 rounded-lg overflow-x-auto text-sm font-mono">
        <code>{code}</code>
      </pre>
      <Button
        size="sm"
        variant="ghost"
        className="absolute top-2 right-2"
        onClick={() => copyToClipboard(code, id)}
      >
        {copied === id ? <Check className="h-4 w-4 text-accent" /> : <Copy className="h-4 w-4" />}
      </Button>
    </div>
  );

  const Section = ({ id, title, icon: Icon, children }: { id: string; title: string; icon: any; children: React.ReactNode }) => (
    <Card className="bg-card border-border">
      <CardHeader 
        className="cursor-pointer hover:bg-muted/30 transition-colors"
        onClick={() => toggleSection(id)}
      >
        <CardTitle className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg bg-primary/20 flex items-center justify-center">
              <Icon className="h-5 w-5 text-primary" />
            </div>
            {title}
          </div>
          {openSections.includes(id) ? <ChevronDown className="h-5 w-5" /> : <ChevronRight className="h-5 w-5" />}
        </CardTitle>
      </CardHeader>
      {openSections.includes(id) && (
        <CardContent className="space-y-4 pt-0">
          {children}
        </CardContent>
      )}
    </Card>
  );

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold gradient-text mb-2">Полная инструкция по установке</h2>
        <p className="text-muted-foreground">
          Пошаговое руководство по настройке VPN Telegram бота с нуля
        </p>
      </div>

      {/* Prerequisites */}
      <Card className="bg-yellow-500/10 border-yellow-500/30">
        <CardContent className="py-4">
          <div className="flex gap-3">
            <AlertTriangle className="h-5 w-5 text-yellow-500 shrink-0 mt-0.5" />
            <div>
              <p className="font-medium text-yellow-500">Что вам понадобится:</p>
              <ul className="text-sm text-muted-foreground mt-2 space-y-1">
                <li>• VPS сервер с Ubuntu 20.04+ (минимум 1GB RAM)</li>
                <li>• Домен (опционально, для TON Connect)</li>
                <li>• ИП или ООО для подключения ЮKassa</li>
                <li>• Базовые знания работы с терминалом</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Step 1: Server Setup */}
      <Section id="step1" title="Шаг 1: Подготовка сервера" icon={Server}>
        <p className="text-muted-foreground">
          Арендуйте VPS сервер у любого провайдера (Timeweb, FirstVDS, Selectel, DigitalOcean и др.)
        </p>
        
        <div className="space-y-3">
          <h4 className="font-medium">1.1 Подключитесь к серверу по SSH:</h4>
          <CodeBlock code="ssh root@ваш_ip_адрес" id="ssh" />
        </div>

        <div className="space-y-3">
          <h4 className="font-medium">1.2 Обновите систему:</h4>
          <CodeBlock code={`apt update && apt upgrade -y`} id="update" />
        </div>

        <div className="space-y-3">
          <h4 className="font-medium">1.3 Установите необходимые пакеты:</h4>
          <CodeBlock code={`apt install -y python3 python3-pip python3-venv git curl nano`} id="packages" />
        </div>

        <div className="space-y-3">
          <h4 className="font-medium">1.4 Создайте директорию для бота:</h4>
          <CodeBlock code={`mkdir -p /opt/vpn-bot && cd /opt/vpn-bot`} id="mkdir" />
        </div>

        <div className="space-y-3">
          <h4 className="font-medium">1.5 Создайте виртуальное окружение Python:</h4>
          <CodeBlock code={`python3 -m venv venv
source venv/bin/activate`} id="venv" />
        </div>

        <div className="space-y-3">
          <h4 className="font-medium">1.6 Установите Python библиотеки:</h4>
          <CodeBlock code={`pip install aiogram aiohttp yookassa cryptography python-dotenv aiosqlite`} id="pip" />
        </div>
      </Section>

      {/* Step 2: Telegram Bot */}
      <Section id="step2" title="Шаг 2: Создание Telegram бота" icon={Bot}>
        <div className="space-y-4">
          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">2.1 Откройте @BotFather в Telegram</h4>
            <p className="text-sm text-muted-foreground">
              Перейдите в Telegram и найдите бота <code className="bg-muted px-2 py-1 rounded">@BotFather</code>
            </p>
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">2.2 Создайте нового бота</h4>
            <p className="text-sm text-muted-foreground">Отправьте команду:</p>
            <CodeBlock code="/newbot" id="newbot" />
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">2.3 Введите название бота</h4>
            <p className="text-sm text-muted-foreground">
              Например: <code className="bg-muted px-2 py-1 rounded">My VPN Bot</code>
            </p>
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">2.4 Введите username бота</h4>
            <p className="text-sm text-muted-foreground">
              Должен заканчиваться на <code className="bg-muted px-2 py-1 rounded">bot</code>, например: <code className="bg-muted px-2 py-1 rounded">my_vpn_service_bot</code>
            </p>
          </div>

          <div className="p-4 bg-primary/10 rounded-lg border border-primary/30">
            <h4 className="font-medium text-primary">2.5 Сохраните токен бота</h4>
            <p className="text-sm text-muted-foreground mt-2">
              BotFather пришлёт токен вида: <code className="bg-muted px-2 py-1 rounded">7123456789:AAH1234567890abcdefghijklmnop</code>
            </p>
            <p className="text-sm text-muted-foreground mt-1">
              <strong>Сохраните его!</strong> Он понадобится для файла .env
            </p>
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">2.6 Узнайте свой Telegram ID</h4>
            <p className="text-sm text-muted-foreground">
              Перейдите к боту <code className="bg-muted px-2 py-1 rounded">@userinfobot</code> и отправьте /start. 
              Он покажет ваш ID — сохраните его для настройки админа.
            </p>
          </div>
        </div>
      </Section>

      {/* Step 3: YooKassa */}
      <Section id="step3" title="Шаг 3: Настройка ЮKassa" icon={CreditCard}>
        <div className="space-y-4">
          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">3.1 Зарегистрируйтесь на ЮKassa</h4>
            <p className="text-sm text-muted-foreground">
              Перейдите на <a href="https://yookassa.ru" target="_blank" className="text-primary hover:underline">yookassa.ru</a> и создайте аккаунт
            </p>
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">3.2 Пройдите верификацию</h4>
            <p className="text-sm text-muted-foreground">
              Для работы с платежами нужно ИП или ООО. Процесс занимает 1-3 рабочих дня.
            </p>
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">3.3 Получите API ключи</h4>
            <ol className="text-sm text-muted-foreground space-y-2 mt-2">
              <li>1. Войдите в личный кабинет ЮKassa</li>
              <li>2. Перейдите в <strong>Настройки → API-ключи</strong></li>
              <li>3. Скопируйте <code className="bg-muted px-2 py-1 rounded">shopId</code> (идентификатор магазина)</li>
              <li>4. Создайте и скопируйте <code className="bg-muted px-2 py-1 rounded">Секретный ключ</code></li>
            </ol>
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">3.4 Включите рекуррентные платежи</h4>
            <ol className="text-sm text-muted-foreground space-y-2 mt-2">
              <li>1. Перейдите в <strong>Настройки → Функциональность</strong></li>
              <li>2. Включите <strong>«Сохранение платёжных методов»</strong></li>
              <li>3. Это позволит автоматически списывать платежи при продлении подписки</li>
            </ol>
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">3.5 Настройте Webhook (уведомления)</h4>
            <ol className="text-sm text-muted-foreground space-y-2 mt-2">
              <li>1. Перейдите в <strong>Настройки → HTTP-уведомления</strong></li>
              <li>2. Добавьте URL: <code className="bg-muted px-2 py-1 rounded">https://ваш_домен.com/webhook/yookassa</code></li>
              <li>3. Выберите события: <strong>payment.succeeded</strong>, <strong>payment.canceled</strong></li>
            </ol>
          </div>
        </div>
      </Section>

      {/* Step 4: CryptoBot */}
      <Section id="step4" title="Шаг 4: Настройка CryptoBot" icon={Key}>
        <div className="space-y-4">
          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">4.1 Откройте @CryptoBot в Telegram</h4>
            <p className="text-sm text-muted-foreground">
              Найдите бота <code className="bg-muted px-2 py-1 rounded">@CryptoBot</code> (официальный бот от Telegram)
            </p>
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">4.2 Создайте приложение</h4>
            <ol className="text-sm text-muted-foreground space-y-2 mt-2">
              <li>1. Отправьте команду <code className="bg-muted px-2 py-1 rounded">/pay</code></li>
              <li>2. Нажмите <strong>«Create App»</strong></li>
              <li>3. Введите название приложения (например, VPN Bot)</li>
            </ol>
          </div>

          <div className="p-4 bg-primary/10 rounded-lg border border-primary/30">
            <h4 className="font-medium text-primary">4.3 Сохраните API Token</h4>
            <p className="text-sm text-muted-foreground mt-2">
              CryptoBot выдаст токен вида: <code className="bg-muted px-2 py-1 rounded">12345:AAGxxxxxxxxxxxxx</code>
            </p>
          </div>
        </div>
      </Section>

      {/* Step 5: TON Connect */}
      <Section id="step5" title="Шаг 5: Настройка TON Connect" icon={Globe}>
        <div className="space-y-4">
          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">5.1 Создайте файл манифеста</h4>
            <p className="text-sm text-muted-foreground">
              Создайте файл <code className="bg-muted px-2 py-1 rounded">tonconnect-manifest.json</code>:
            </p>
            <CodeBlock code={`{
  "url": "https://ваш_домен.com",
  "name": "VPN Bot",
  "iconUrl": "https://ваш_домен.com/icon.png",
  "termsOfUseUrl": "https://ваш_домен.com/terms",
  "privacyPolicyUrl": "https://ваш_домен.com/privacy"
}`} id="manifest" />
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">5.2 Разместите на сервере с HTTPS</h4>
            <p className="text-sm text-muted-foreground">
              Файл должен быть доступен по адресу типа: <code className="bg-muted px-2 py-1 rounded">https://ваш_домен.com/tonconnect-manifest.json</code>
            </p>
          </div>

          <div className="p-4 bg-yellow-500/10 rounded-lg border border-yellow-500/30">
            <p className="text-sm text-yellow-500">
              <strong>Примечание:</strong> TON Connect требует HTTPS. Если у вас нет домена, можете пропустить этот шаг и использовать только ЮKassa и CryptoBot.
            </p>
          </div>
        </div>
      </Section>

      {/* Step 6: VPN Server */}
      <Section id="step6" title="Шаг 6: Настройка VPN сервера (VLESS)" icon={Shield}>
        <div className="space-y-4">
          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">6.1 Установите 3X-UI панель</h4>
            <p className="text-sm text-muted-foreground">На отдельном VPS выполните:</p>
            <CodeBlock code={`bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)`} id="3xui" />
          </div>

          <div className="p-4 bg-muted/30 rounded-lg space-y-3">
            <h4 className="font-medium">6.2 Настройте VLESS + Reality</h4>
            <ol className="text-sm text-muted-foreground space-y-2 mt-2">
              <li>1. Войдите в панель 3X-UI (порт 2053 по умолчанию)</li>
              <li>2. Создайте новый Inbound</li>
              <li>3. Выберите протокол <strong>VLESS</strong></li>
              <li>4. Включите <strong>Reality</strong></li>
              <li>5. Укажите SNI: <code className="bg-muted px-2 py-1 rounded">google.com</code> или другой популярный домен</li>
            </ol>
          </div>

          <div className="p-4 bg-primary/10 rounded-lg border border-primary/30">
            <h4 className="font-medium text-primary">6.3 Сохраните параметры</h4>
            <p className="text-sm text-muted-foreground mt-2">
              Вам понадобятся: IP сервера, порт, публичный ключ (pbk), short id (sid)
            </p>
          </div>
        </div>
      </Section>

      {/* Step 7: Bot Configuration */}
      <Section id="step7" title="Шаг 7: Создание файлов бота" icon={Terminal}>
        <div className="space-y-4">
          <div className="space-y-3">
            <h4 className="font-medium">7.1 Создайте файл .env</h4>
            <CodeBlock code={`nano /opt/vpn-bot/.env`} id="nano-env" />
            <p className="text-sm text-muted-foreground">Вставьте и отредактируйте:</p>
            <CodeBlock code={`# Telegram Bot
BOT_TOKEN=7123456789:AAH_ваш_токен_от_BotFather

# YooKassa
YOOKASSA_SHOP_ID=123456
YOOKASSA_SECRET_KEY=live_ваш_секретный_ключ

# CryptoBot
CRYPTOBOT_TOKEN=12345:AAG_ваш_токен

# TON Connect (опционально)
TON_MANIFEST_URL=https://ваш_домен.com/tonconnect-manifest.json

# VPN Server
VPN_SERVER_IP=123.45.67.89
VPN_SERVER_PORT=443
VPN_PUBLIC_KEY=ваш_публичный_ключ_reality
VPN_SHORT_ID=ваш_short_id

# Admin
ADMIN_IDS=ваш_telegram_id`} id="env-content" />
            <p className="text-sm text-muted-foreground">Сохраните: <kbd className="bg-muted px-2 py-1 rounded">Ctrl+X</kbd> → <kbd className="bg-muted px-2 py-1 rounded">Y</kbd> → <kbd className="bg-muted px-2 py-1 rounded">Enter</kbd></p>
          </div>

          <div className="space-y-3">
            <h4 className="font-medium">7.2 Создайте файл bot.py</h4>
            <CodeBlock code={`nano /opt/vpn-bot/bot.py`} id="nano-bot" />
            <p className="text-sm text-muted-foreground">
              Скопируйте код бота из раздела <strong>«Код бота»</strong> в документации админ-панели
            </p>
          </div>
        </div>
      </Section>

      {/* Step 8: Launch */}
      <Section id="step8" title="Шаг 8: Запуск и автозапуск" icon={Terminal}>
        <div className="space-y-4">
          <div className="space-y-3">
            <h4 className="font-medium">8.1 Проверьте запуск вручную</h4>
            <CodeBlock code={`cd /opt/vpn-bot
source venv/bin/activate
python bot.py`} id="manual-run" />
            <p className="text-sm text-muted-foreground">
              Если всё работает — остановите бота через <kbd className="bg-muted px-2 py-1 rounded">Ctrl+C</kbd>
            </p>
          </div>

          <div className="space-y-3">
            <h4 className="font-medium">8.2 Создайте systemd сервис</h4>
            <CodeBlock code={`nano /etc/systemd/system/vpn-bot.service`} id="nano-service" />
            <p className="text-sm text-muted-foreground">Вставьте:</p>
            <CodeBlock code={`[Unit]
Description=VPN Telegram Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/vpn-bot
ExecStart=/opt/vpn-bot/venv/bin/python bot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target`} id="service-content" />
          </div>

          <div className="space-y-3">
            <h4 className="font-medium">8.3 Запустите сервис</h4>
            <CodeBlock code={`systemctl daemon-reload
systemctl enable vpn-bot
systemctl start vpn-bot`} id="start-service" />
          </div>

          <div className="space-y-3">
            <h4 className="font-medium">8.4 Проверьте статус</h4>
            <CodeBlock code={`systemctl status vpn-bot`} id="status" />
          </div>

          <div className="space-y-3">
            <h4 className="font-medium">8.5 Просмотр логов</h4>
            <CodeBlock code={`journalctl -u vpn-bot -f`} id="logs" />
          </div>
        </div>
      </Section>

      {/* Final Check */}
      <Card className="bg-accent/10 border-accent/30">
        <CardContent className="py-6">
          <div className="flex gap-3">
            <Check className="h-6 w-6 text-accent shrink-0" />
            <div>
              <h3 className="font-semibold text-accent text-lg">Готово!</h3>
              <p className="text-muted-foreground mt-2">
                Теперь откройте вашего бота в Telegram и отправьте <code className="bg-muted px-2 py-1 rounded">/start</code>. 
                Если всё настроено правильно, бот ответит приветственным сообщением с кнопками.
              </p>
              <div className="mt-4 p-4 bg-muted/30 rounded-lg">
                <p className="text-sm font-medium">Полезные команды:</p>
                <ul className="text-sm text-muted-foreground mt-2 space-y-1">
                  <li>• Перезапуск бота: <code className="bg-muted px-1 rounded">systemctl restart vpn-bot</code></li>
                  <li>• Остановка: <code className="bg-muted px-1 rounded">systemctl stop vpn-bot</code></li>
                  <li>• Логи в реальном времени: <code className="bg-muted px-1 rounded">journalctl -u vpn-bot -f</code></li>
                </ul>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
