import { useState } from "react";
import { Copy, Check, Terminal, FileCode, Server, Key, CreditCard } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const installScript = `#!/bin/bash

# ===================================
# VPN Bot Auto-Install Script
# ===================================

set -e

echo "🚀 Установка VPN Telegram Bot..."

# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y python3 python3-pip python3-venv git curl

# Create directory
mkdir -p /opt/vpn-bot
cd /opt/vpn-bot

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python packages
pip install aiogram aiohttp yookassa cryptography python-dotenv aiosqlite

# Create .env file
cat > .env << 'EOF'
# Telegram Bot
BOT_TOKEN=your_telegram_bot_token

# YooKassa (Юкасса)
YOOKASSA_SHOP_ID=your_shop_id
YOOKASSA_SECRET_KEY=your_secret_key

# CryptoBot
CRYPTOBOT_TOKEN=your_cryptobot_token

# TON Connect
TON_MANIFEST_URL=https://yourdomain.com/tonconnect-manifest.json

# VPN Server
VPN_SERVER_IP=your_server_ip
VPN_SERVER_PORT=443

# Admin
ADMIN_IDS=123456789,987654321
EOF

echo "✅ Установка завершена!"
echo "📝 Отредактируйте /opt/vpn-bot/.env и добавьте свои токены"
echo "🚀 Запуск: cd /opt/vpn-bot && source venv/bin/activate && python bot.py"`;

const botCode = String.raw`import asyncio
import os
import uuid
import base64
import json
from datetime import datetime, timedelta
from dotenv import load_dotenv
from aiogram import Bot, Dispatcher, types, F
from aiogram.filters import Command
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
from yookassa import Configuration, Payment
import aiosqlite

load_dotenv()

# Config
BOT_TOKEN = os.getenv("BOT_TOKEN")
YOOKASSA_SHOP_ID = os.getenv("YOOKASSA_SHOP_ID")
YOOKASSA_SECRET_KEY = os.getenv("YOOKASSA_SECRET_KEY")
CRYPTOBOT_TOKEN = os.getenv("CRYPTOBOT_TOKEN")
VPN_SERVER = os.getenv("VPN_SERVER_IP")
ADMIN_IDS = [int(x) for x in os.getenv("ADMIN_IDS", "").split(",") if x]

# YooKassa setup
Configuration.account_id = YOOKASSA_SHOP_ID
Configuration.secret_key = YOOKASSA_SECRET_KEY

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

# Tariffs
TARIFFS = {
    "basic": {"name": "Basic", "price_rub": 290, "price_usd": 3, "days": 30},
    "premium": {"name": "Premium", "price_rub": 590, "price_usd": 6, "days": 30},
    "ultimate": {"name": "Ultimate", "price_rub": 990, "price_usd": 10, "days": 30},
}

def generate_vless_key(user_id: int) -> str:
    """Generate random VLESS key"""
    key_uuid = str(uuid.uuid4())
    key = f"vless://{key_uuid}@{VPN_SERVER}:443?encryption=none&security=reality&sni=google.com&fp=chrome&pbk=random_key&sid=random_sid&type=tcp&flow=xtls-rprx-vision#{user_id}"
    return key

async def init_db():
    async with aiosqlite.connect("vpn_bot.db") as db:
        await db.execute("""
            CREATE TABLE IF NOT EXISTS users (
                user_id INTEGER PRIMARY KEY,
                username TEXT,
                subscription_end DATETIME,
                vless_key TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)
        await db.execute("""
            CREATE TABLE IF NOT EXISTS payments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                amount REAL,
                currency TEXT,
                method TEXT,
                status TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)
        await db.commit()

@dp.message(Command("start"))
async def cmd_start(message: types.Message):
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🛒 Купить VPN", callback_data="buy")],
        [InlineKeyboardButton(text="👤 Мой профиль", callback_data="profile")],
        [InlineKeyboardButton(text="💬 Поддержка", callback_data="support")],
    ])
    
    await message.answer(
        "🛡️ <b>Добро пожаловать в VPN Bot!</b>\\n\\n"
        "Быстрый и безопасный VPN на протоколе VLESS.\\n\\n"
        "✅ Без логов\\n"
        "✅ Высокая скорость\\n"
        "✅ Работает везде\\n\\n"
        "Выберите действие:",
        reply_markup=keyboard,
        parse_mode="HTML"
    )

@dp.callback_query(F.data == "buy")
async def show_tariffs(callback: types.CallbackQuery):
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text=f"🔹 Basic - {TARIFFS['basic']['price_rub']}₽/мес", callback_data="tariff_basic")],
        [InlineKeyboardButton(text=f"🔸 Premium - {TARIFFS['premium']['price_rub']}₽/мес", callback_data="tariff_premium")],
        [InlineKeyboardButton(text=f"💎 Ultimate - {TARIFFS['ultimate']['price_rub']}₽/мес", callback_data="tariff_ultimate")],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_main")],
    ])
    
    await callback.message.edit_text(
        "📦 <b>Выберите тариф:</b>\\n\\n"
        "🔹 <b>Basic</b> - 1 устройство\\n"
        "🔸 <b>Premium</b> - 3 устройства\\n"
        "💎 <b>Ultimate</b> - 5 устройств + приоритет\\n",
        reply_markup=keyboard,
        parse_mode="HTML"
    )

@dp.callback_query(F.data.startswith("tariff_"))
async def select_tariff(callback: types.CallbackQuery):
    tariff_id = callback.data.replace("tariff_", "")
    tariff = TARIFFS[tariff_id]
    
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="💳 Карта (YooKassa)", callback_data=f"pay_yookassa_{tariff_id}")],
        [InlineKeyboardButton(text="🪙 Крипта (CryptoBot)", callback_data=f"pay_crypto_{tariff_id}")],
        [InlineKeyboardButton(text="💎 TON Connect", callback_data=f"pay_ton_{tariff_id}")],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="buy")],
    ])
    
    await callback.message.edit_text(
        f"💰 <b>Оплата тарифа {tariff['name']}</b>\\n\\n"
        f"Цена: {tariff['price_rub']}₽ / \${tariff['price_usd']}\\n"
        f"Период: {tariff['days']} дней\\n\\n"
        "Выберите способ оплаты:",
        reply_markup=keyboard,
        parse_mode="HTML"
    )

@dp.callback_query(F.data.startswith("pay_yookassa_"))
async def pay_yookassa(callback: types.CallbackQuery):
    tariff_id = callback.data.replace("pay_yookassa_", "")
    tariff = TARIFFS[tariff_id]
    
    # Create YooKassa payment with recurring
    payment = Payment.create({
        "amount": {"value": str(tariff["price_rub"]), "currency": "RUB"},
        "confirmation": {"type": "redirect", "return_url": "https://t.me/your_bot"},
        "capture": True,
        "description": f"VPN {tariff['name']} - {tariff['days']} дней",
        "save_payment_method": True,  # For recurring
        "metadata": {"user_id": callback.from_user.id, "tariff": tariff_id}
    })
    
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="💳 Оплатить", url=payment.confirmation.confirmation_url)],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data=f"tariff_{tariff_id}")],
    ])
    
    await callback.message.edit_text(
        "💳 <b>Оплата через YooKassa</b>\\n\\n"
        "Нажмите кнопку для перехода к оплате.\\n"
        "После оплаты ключ придёт автоматически.",
        reply_markup=keyboard,
        parse_mode="HTML"
    )

async def activate_subscription(user_id: int, tariff_id: str):
    """Activate subscription and send VLESS key"""
    tariff = TARIFFS[tariff_id]
    vless_key = generate_vless_key(user_id)
    end_date = datetime.now() + timedelta(days=tariff["days"])
    
    async with aiosqlite.connect("vpn_bot.db") as db:
        await db.execute(
            "INSERT OR REPLACE INTO users (user_id, subscription_end, vless_key) VALUES (?, ?, ?)",
            (user_id, end_date, vless_key)
        )
        await db.commit()
    
    await bot.send_message(
        user_id,
        f"✅ <b>Подписка активирована!</b>\\n\\n"
        f"📦 Тариф: {tariff['name']}\\n"
        f"📅 Активна до: {end_date.strftime('%d.%m.%Y')}\\n\\n"
        f"🔑 <b>Ваш VLESS ключ:</b>\\n"
        f"<code>{vless_key}</code>\\n\\n"
        f"📱 Скопируйте и вставьте в приложение:\\n"
        f"• iOS: Streisand, Shadowrocket\\n"
        f"• Android: v2rayNG, NekoBox\\n"
        f"• Windows/Mac: V2rayN, Qv2ray",
        parse_mode="HTML"
    )

async def main():
    await init_db()
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())`;

const envTemplate = `# ===================================
# VPN Bot Configuration
# ===================================

# Telegram Bot Token
# Получить: https://t.me/BotFather -> /newbot
BOT_TOKEN=your_telegram_bot_token_here

# YooKassa (Юкасса)
# Получить: https://yookassa.ru/my/merchant/integration/api-keys
YOOKASSA_SHOP_ID=your_shop_id_here
YOOKASSA_SECRET_KEY=your_secret_key_here

# CryptoBot
# Получить: https://t.me/CryptoBot -> /pay -> Create App
CRYPTOBOT_TOKEN=your_cryptobot_token_here

# TON Connect
# Создать manifest.json на своём сервере
TON_MANIFEST_URL=https://yourdomain.com/tonconnect-manifest.json

# VPN Server
# IP адрес вашего VPN сервера с VLESS
VPN_SERVER_IP=123.456.789.0
VPN_SERVER_PORT=443

# Admin Telegram IDs (через запятую)
# Узнать: https://t.me/userinfobot
ADMIN_IDS=123456789,987654321`;

const sections = [
  { id: "install", title: "Установка", icon: Terminal },
  { id: "config", title: "Конфигурация", icon: FileCode },
  { id: "bot", title: "Код бота", icon: Server },
  { id: "payments", title: "Платежи", icon: CreditCard },
  { id: "keys", title: "VLESS ключи", icon: Key },
];

export function Documentation() {
  const [activeSection, setActiveSection] = useState("install");
  const [copied, setCopied] = useState<string | null>(null);

  const copyToClipboard = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopied(id);
    setTimeout(() => setCopied(null), 2000);
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold gradient-text mb-2">Документация</h2>
        <p className="text-muted-foreground">
          Пошаговые инструкции по установке и настройке VPN бота
        </p>
      </div>

      {/* Section Navigation */}
      <div className="flex gap-2 flex-wrap">
        {sections.map((section) => (
          <Button
            key={section.id}
            variant={activeSection === section.id ? "cyber" : "outline"}
            size="sm"
            onClick={() => setActiveSection(section.id)}
            className="gap-2"
          >
            <section.icon className="h-4 w-4" />
            {section.title}
          </Button>
        ))}
      </div>

      {/* Install Section */}
      {activeSection === "install" && (
        <div className="space-y-6">
          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Terminal className="h-5 w-5 text-primary" />
                Шаг 1: Автоматическая установка
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-muted-foreground">
                Выполните эту команду на вашем Linux сервере (Ubuntu/Debian):
              </p>
              <div className="relative">
                <pre className="bg-muted p-4 rounded-lg overflow-x-auto text-sm font-mono">
                  <code>curl -sSL https://your-domain.com/install.sh | bash</code>
                </pre>
                <Button
                  size="sm"
                  variant="ghost"
                  className="absolute top-2 right-2"
                  onClick={() => copyToClipboard("curl -sSL https://your-domain.com/install.sh | bash", "install-cmd")}
                >
                  {copied === "install-cmd" ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
                </Button>
              </div>

              <p className="text-muted-foreground mt-4">
                Или скопируйте скрипт вручную:
              </p>
              <div className="relative">
                <pre className="bg-muted p-4 rounded-lg overflow-x-auto text-sm font-mono max-h-96">
                  <code>{installScript}</code>
                </pre>
                <Button
                  size="sm"
                  variant="ghost"
                  className="absolute top-2 right-2"
                  onClick={() => copyToClipboard(installScript, "install-script")}
                >
                  {copied === "install-script" ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Config Section */}
      {activeSection === "config" && (
        <div className="space-y-6">
          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <FileCode className="h-5 w-5 text-accent" />
                Шаг 2: Настройка .env файла
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-muted-foreground">
                Отредактируйте файл <code className="bg-muted px-2 py-1 rounded">/opt/vpn-bot/.env</code>:
              </p>
              <div className="relative">
                <pre className="bg-muted p-4 rounded-lg overflow-x-auto text-sm font-mono">
                  <code>{envTemplate}</code>
                </pre>
                <Button
                  size="sm"
                  variant="ghost"
                  className="absolute top-2 right-2"
                  onClick={() => copyToClipboard(envTemplate, "env")}
                >
                  {copied === "env" ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
                </Button>
              </div>

              <div className="mt-6 space-y-4">
                <h4 className="font-semibold text-foreground">Где получить токены:</h4>
                <div className="grid gap-3">
                  <div className="p-3 bg-muted/50 rounded-lg">
                    <p className="font-medium text-primary">BOT_TOKEN</p>
                    <p className="text-sm text-muted-foreground">
                      Telegram: @BotFather → /newbot → скопируйте токен
                    </p>
                  </div>
                  <div className="p-3 bg-muted/50 rounded-lg">
                    <p className="font-medium text-secondary">YOOKASSA</p>
                    <p className="text-sm text-muted-foreground">
                      yookassa.ru → Настройки → API-ключи → Shop ID и Secret Key
                    </p>
                  </div>
                  <div className="p-3 bg-muted/50 rounded-lg">
                    <p className="font-medium text-accent">CRYPTOBOT_TOKEN</p>
                    <p className="text-sm text-muted-foreground">
                      Telegram: @CryptoBot → /pay → Create App → API Token
                    </p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Bot Code Section */}
      {activeSection === "bot" && (
        <div className="space-y-6">
          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Server className="h-5 w-5 text-secondary" />
                Шаг 3: Код бота (bot.py)
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-muted-foreground">
                Создайте файл <code className="bg-muted px-2 py-1 rounded">/opt/vpn-bot/bot.py</code>:
              </p>
              <div className="relative">
                <pre className="bg-muted p-4 rounded-lg overflow-x-auto text-sm font-mono max-h-[500px]">
                  <code>{botCode}</code>
                </pre>
                <Button
                  size="sm"
                  variant="ghost"
                  className="absolute top-2 right-2"
                  onClick={() => copyToClipboard(botCode, "bot")}
                >
                  {copied === "bot" ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Payments Section */}
      {activeSection === "payments" && (
        <div className="space-y-6">
          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle>Настройка платежей</CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-4">
                <h4 className="font-semibold flex items-center gap-2">
                  <span className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center text-primary">1</span>
                  YooKassa (Юкасса)
                </h4>
                <ol className="list-decimal list-inside space-y-2 text-muted-foreground ml-10">
                  <li>Зарегистрируйтесь на yookassa.ru</li>
                  <li>Пройдите верификацию (ИП или ООО)</li>
                  <li>Получите shopId и secretKey в разделе API</li>
                  <li>Включите «Сохранение платёжных методов» для рекуррентов</li>
                  <li>Настройте webhook на /webhook/yookassa</li>
                </ol>
              </div>

              <div className="space-y-4">
                <h4 className="font-semibold flex items-center gap-2">
                  <span className="w-8 h-8 rounded-full bg-secondary/20 flex items-center justify-center text-secondary">2</span>
                  CryptoBot
                </h4>
                <ol className="list-decimal list-inside space-y-2 text-muted-foreground ml-10">
                  <li>Откройте @CryptoBot в Telegram</li>
                  <li>Отправьте /pay</li>
                  <li>Выберите «Create App»</li>
                  <li>Скопируйте API Token</li>
                </ol>
              </div>

              <div className="space-y-4">
                <h4 className="font-semibold flex items-center gap-2">
                  <span className="w-8 h-8 rounded-full bg-accent/20 flex items-center justify-center text-accent">3</span>
                  TON Connect
                </h4>
                <ol className="list-decimal list-inside space-y-2 text-muted-foreground ml-10">
                  <li>Создайте tonconnect-manifest.json</li>
                  <li>Разместите на своём домене с HTTPS</li>
                  <li>Укажите URL в .env файле</li>
                </ol>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Keys Section */}
      {activeSection === "keys" && (
        <div className="space-y-6">
          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Key className="h-5 w-5 text-accent" />
                Генерация VLESS ключей
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-muted-foreground">
                Бот автоматически генерирует уникальные VLESS ключи для каждого пользователя.
                Ключ создаётся в формате URI и сразу готов к импорту в клиентские приложения.
              </p>

              <div className="p-4 bg-muted/50 rounded-lg">
                <p className="font-medium text-foreground mb-2">Пример ключа:</p>
                <code className="text-sm text-primary break-all">
                  vless://uuid@server:443?encryption=none&security=reality&sni=google.com&type=tcp#UserID
                </code>
              </div>

              <div className="mt-4">
                <h4 className="font-semibold mb-3">Поддерживаемые клиенты:</h4>
                <div className="grid grid-cols-2 gap-3">
                  <div className="p-3 bg-muted/50 rounded-lg">
                    <p className="font-medium">iOS</p>
                    <p className="text-sm text-muted-foreground">Streisand, Shadowrocket</p>
                  </div>
                  <div className="p-3 bg-muted/50 rounded-lg">
                    <p className="font-medium">Android</p>
                    <p className="text-sm text-muted-foreground">v2rayNG, NekoBox</p>
                  </div>
                  <div className="p-3 bg-muted/50 rounded-lg">
                    <p className="font-medium">Windows</p>
                    <p className="text-sm text-muted-foreground">V2rayN, Qv2ray</p>
                  </div>
                  <div className="p-3 bg-muted/50 rounded-lg">
                    <p className="font-medium">macOS</p>
                    <p className="text-sm text-muted-foreground">V2rayU, Qv2ray</p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
