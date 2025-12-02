#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║           VPN TELEGRAM BOT - ИНТЕРАКТИВНЫЙ УСТАНОВЩИК                        ║
# ║                      Версия 1.0 | Автор: VPN Bot Team                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -e

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функции для вывода
print_header() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           VPN TELEGRAM BOT - УСТАНОВЩИК                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}📌 $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Проверка root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Запустите скрипт от имени root: sudo bash install.sh"
        exit 1
    fi
}

# Приветствие
welcome() {
    clear
    print_header
    echo -e "${GREEN}Добро пожаловать в установщик VPN Telegram Bot!${NC}\n"
    echo "Этот скрипт автоматически:"
    echo "  • Установит все необходимые пакеты"
    echo "  • Настроит Python окружение"
    echo "  • Создаст и настроит бота"
    echo "  • Настроит автозапуск"
    echo ""
    echo -e "${YELLOW}Вам понадобятся:${NC}"
    echo "  • Токен бота от @BotFather"
    echo "  • Ваш Telegram ID (от @userinfobot)"
    echo "  • Данные ЮKassa (опционально)"
    echo "  • Токен CryptoBot (опционально)"
    echo "  • Данные VPN сервера"
    echo ""
    read -p "Нажмите Enter чтобы начать установку..."
}

# Установка пакетов
install_packages() {
    print_step "ШАГ 1/7: Обновление системы и установка пакетов"
    
    print_info "Обновляем список пакетов..."
    apt update -qq
    
    print_info "Обновляем систему..."
    apt upgrade -y -qq
    
    print_info "Устанавливаем необходимые пакеты..."
    apt install -y -qq python3 python3-pip python3-venv git curl nano
    
    print_success "Пакеты установлены!"
}

# Создание директории
create_directory() {
    print_step "ШАГ 2/7: Создание директории бота"
    
    BOT_DIR="/opt/vpn-bot"
    
    if [ -d "$BOT_DIR" ]; then
        print_warning "Директория $BOT_DIR уже существует"
        read -p "Удалить и создать заново? (y/n): " choice
        if [ "$choice" = "y" ]; then
            rm -rf "$BOT_DIR"
        fi
    fi
    
    mkdir -p "$BOT_DIR"
    cd "$BOT_DIR"
    
    print_success "Директория создана: $BOT_DIR"
}

# Настройка Python
setup_python() {
    print_step "ШАГ 3/7: Настройка Python окружения"
    
    print_info "Создаём виртуальное окружение..."
    python3 -m venv venv
    
    print_info "Активируем окружение..."
    source venv/bin/activate
    
    print_info "Устанавливаем Python библиотеки..."
    pip install --quiet --upgrade pip
    pip install --quiet aiogram aiohttp yookassa cryptography python-dotenv aiosqlite
    
    print_success "Python окружение настроено!"
}

# Сбор данных от пользователя
collect_data() {
    print_step "ШАГ 4/7: Настройка бота"
    
    echo -e "${CYAN}Сейчас нужно ввести данные для настройки бота.${NC}"
    echo -e "${YELLOW}Если какой-то параметр не нужен - просто нажмите Enter.${NC}\n"
    
    # Telegram Bot
    echo -e "\n${PURPLE}═══ TELEGRAM BOT ═══${NC}"
    while true; do
        read -p "🤖 Введите токен бота (от @BotFather): " BOT_TOKEN
        if [ -z "$BOT_TOKEN" ]; then
            print_error "Токен бота обязателен!"
        else
            break
        fi
    done
    
    while true; do
        read -p "👤 Введите ваш Telegram ID (от @userinfobot): " ADMIN_ID
        if [ -z "$ADMIN_ID" ]; then
            print_error "Admin ID обязателен!"
        else
            break
        fi
    done
    
    # YooKassa
    echo -e "\n${PURPLE}═══ ЮKASSA (для оплаты картой) ═══${NC}"
    print_info "Пропустите, если нет ИП/ООО"
    read -p "💳 Shop ID (число): " YOOKASSA_SHOP_ID
    read -p "🔑 Secret Key: " YOOKASSA_SECRET_KEY
    
    # CryptoBot
    echo -e "\n${PURPLE}═══ CRYPTOBOT (для крипто-оплаты) ═══${NC}"
    read -p "🪙 CryptoBot Token: " CRYPTOBOT_TOKEN
    
    # TON Connect
    echo -e "\n${PURPLE}═══ TON CONNECT (опционально) ═══${NC}"
    read -p "💎 TON Manifest URL (или Enter для пропуска): " TON_MANIFEST_URL
    
    # VPN Server
    echo -e "\n${PURPLE}═══ VPN СЕРВЕР ═══${NC}"
    while true; do
        read -p "🌐 IP адрес VPN сервера: " VPN_SERVER_IP
        if [ -z "$VPN_SERVER_IP" ]; then
            print_error "IP сервера обязателен!"
        else
            break
        fi
    done
    
    read -p "🔌 Порт VPN (по умолчанию 443): " VPN_SERVER_PORT
    VPN_SERVER_PORT=${VPN_SERVER_PORT:-443}
    
    read -p "🔐 Public Key (pbk) от Reality: " VPN_PUBLIC_KEY
    read -p "🆔 Short ID (sid) от Reality: " VPN_SHORT_ID
    read -p "🌍 SNI домен (по умолчанию google.com): " VPN_SNI
    VPN_SNI=${VPN_SNI:-google.com}
    
    # Тарифы
    echo -e "\n${PURPLE}═══ ТАРИФЫ ═══${NC}"
    print_info "Установим стандартные тарифы. Можно изменить позже в .env"
    
    read -p "💰 Цена Basic в рублях (по умолчанию 290): " PRICE_BASIC
    PRICE_BASIC=${PRICE_BASIC:-290}
    
    read -p "💰 Цена Premium в рублях (по умолчанию 590): " PRICE_PREMIUM
    PRICE_PREMIUM=${PRICE_PREMIUM:-590}
    
    read -p "💰 Цена Ultimate в рублях (по умолчанию 990): " PRICE_ULTIMATE
    PRICE_ULTIMATE=${PRICE_ULTIMATE:-990}
    
    print_success "Данные собраны!"
}

# Создание .env файла
create_env() {
    print_step "ШАГ 5/7: Создание конфигурации"
    
    cat > /opt/vpn-bot/.env << EOF
# ╔══════════════════════════════════════════════════════════════╗
# ║              VPN BOT - КОНФИГУРАЦИЯ                          ║
# ║         Создано автоматически $(date +%Y-%m-%d)                   ║
# ╚══════════════════════════════════════════════════════════════╝

# ═══ TELEGRAM BOT ═══
BOT_TOKEN=${BOT_TOKEN}
ADMIN_IDS=${ADMIN_ID}

# ═══ ЮKASSA ═══
YOOKASSA_SHOP_ID=${YOOKASSA_SHOP_ID}
YOOKASSA_SECRET_KEY=${YOOKASSA_SECRET_KEY}

# ═══ CRYPTOBOT ═══
CRYPTOBOT_TOKEN=${CRYPTOBOT_TOKEN}

# ═══ TON CONNECT ═══
TON_MANIFEST_URL=${TON_MANIFEST_URL}

# ═══ VPN СЕРВЕР ═══
VPN_SERVER_IP=${VPN_SERVER_IP}
VPN_SERVER_PORT=${VPN_SERVER_PORT}
VPN_PUBLIC_KEY=${VPN_PUBLIC_KEY}
VPN_SHORT_ID=${VPN_SHORT_ID}
VPN_SNI=${VPN_SNI}

# ═══ ТАРИФЫ (в рублях) ═══
PRICE_BASIC=${PRICE_BASIC}
PRICE_PREMIUM=${PRICE_PREMIUM}
PRICE_ULTIMATE=${PRICE_ULTIMATE}
EOF

    print_success "Файл .env создан!"
}

# Создание бота
create_bot() {
    print_step "ШАГ 6/7: Создание файла бота"
    
    cat > /opt/vpn-bot/bot.py << 'BOTCODE'
import asyncio
import os
import uuid
import json
from datetime import datetime, timedelta
from dotenv import load_dotenv
from aiogram import Bot, Dispatcher, types, F
from aiogram.filters import Command
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
import aiosqlite

load_dotenv()

# Config
BOT_TOKEN = os.getenv("BOT_TOKEN")
ADMIN_IDS = [int(x) for x in os.getenv("ADMIN_IDS", "").split(",") if x]
VPN_SERVER = os.getenv("VPN_SERVER_IP")
VPN_PORT = os.getenv("VPN_SERVER_PORT", "443")
VPN_PBK = os.getenv("VPN_PUBLIC_KEY", "")
VPN_SID = os.getenv("VPN_SHORT_ID", "")
VPN_SNI = os.getenv("VPN_SNI", "google.com")

# Prices
PRICE_BASIC = int(os.getenv("PRICE_BASIC", 290))
PRICE_PREMIUM = int(os.getenv("PRICE_PREMIUM", 590))
PRICE_ULTIMATE = int(os.getenv("PRICE_ULTIMATE", 990))

# YooKassa
YOOKASSA_SHOP_ID = os.getenv("YOOKASSA_SHOP_ID")
YOOKASSA_SECRET_KEY = os.getenv("YOOKASSA_SECRET_KEY")

if YOOKASSA_SHOP_ID and YOOKASSA_SECRET_KEY:
    from yookassa import Configuration, Payment
    Configuration.account_id = YOOKASSA_SHOP_ID
    Configuration.secret_key = YOOKASSA_SECRET_KEY
    YOOKASSA_ENABLED = True
else:
    YOOKASSA_ENABLED = False

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

# Tariffs
TARIFFS = {
    "basic": {"name": "Basic", "price_rub": PRICE_BASIC, "price_usd": 3, "days": 30, "devices": 1},
    "premium": {"name": "Premium", "price_rub": PRICE_PREMIUM, "price_usd": 6, "days": 30, "devices": 3},
    "ultimate": {"name": "Ultimate", "price_rub": PRICE_ULTIMATE, "price_usd": 10, "days": 30, "devices": 5},
}

def generate_vless_key(user_id: int) -> str:
    """Generate VLESS key with Reality"""
    key_uuid = str(uuid.uuid4())
    key = f"vless://{key_uuid}@{VPN_SERVER}:{VPN_PORT}?encryption=none&security=reality&sni={VPN_SNI}&fp=chrome&pbk={VPN_PBK}&sid={VPN_SID}&type=tcp&flow=xtls-rprx-vision#{user_id}"
    return key

async def init_db():
    async with aiosqlite.connect("vpn_bot.db") as db:
        await db.execute("""
            CREATE TABLE IF NOT EXISTS users (
                user_id INTEGER PRIMARY KEY,
                username TEXT,
                subscription_end DATETIME,
                vless_key TEXT,
                tariff TEXT,
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
                tariff TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)
        await db.commit()

@dp.message(Command("start"))
async def cmd_start(message: types.Message):
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🛒 Купить VPN", callback_data="buy")],
        [InlineKeyboardButton(text="👤 Мой профиль", callback_data="profile")],
        [InlineKeyboardButton(text="📖 Инструкция", callback_data="help")],
        [InlineKeyboardButton(text="💬 Поддержка", callback_data="support")],
    ])
    
    await message.answer(
        "🛡️ <b>Добро пожаловать в VPN Bot!</b>\n\n"
        "Быстрый и безопасный VPN на протоколе VLESS+Reality.\n\n"
        "✅ Без логов\n"
        "✅ Высокая скорость\n"
        "✅ Работает везде\n"
        "✅ Обход блокировок\n\n"
        "Выберите действие:",
        reply_markup=keyboard,
        parse_mode="HTML"
    )

@dp.callback_query(F.data == "buy")
async def show_tariffs(callback: types.CallbackQuery):
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(
            text=f"🔹 Basic ({TARIFFS['basic']['devices']} устр.) - {TARIFFS['basic']['price_rub']}₽/мес", 
            callback_data="tariff_basic"
        )],
        [InlineKeyboardButton(
            text=f"🔸 Premium ({TARIFFS['premium']['devices']} устр.) - {TARIFFS['premium']['price_rub']}₽/мес", 
            callback_data="tariff_premium"
        )],
        [InlineKeyboardButton(
            text=f"💎 Ultimate ({TARIFFS['ultimate']['devices']} устр.) - {TARIFFS['ultimate']['price_rub']}₽/мес", 
            callback_data="tariff_ultimate"
        )],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_main")],
    ])
    
    await callback.message.edit_text(
        "📦 <b>Выберите тариф:</b>\n\n"
        f"🔹 <b>Basic</b> - {TARIFFS['basic']['devices']} устройство\n"
        f"🔸 <b>Premium</b> - {TARIFFS['premium']['devices']} устройства\n"
        f"💎 <b>Ultimate</b> - {TARIFFS['ultimate']['devices']} устройств + приоритет\n",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

@dp.callback_query(F.data.startswith("tariff_"))
async def select_tariff(callback: types.CallbackQuery):
    tariff_id = callback.data.replace("tariff_", "")
    tariff = TARIFFS[tariff_id]
    
    buttons = []
    
    if YOOKASSA_ENABLED:
        buttons.append([InlineKeyboardButton(
            text="💳 Карта (YooKassa)", 
            callback_data=f"pay_yookassa_{tariff_id}"
        )])
    
    buttons.append([InlineKeyboardButton(
        text="🪙 Крипта (CryptoBot)", 
        callback_data=f"pay_crypto_{tariff_id}"
    )])
    buttons.append([InlineKeyboardButton(
        text="💎 TON", 
        callback_data=f"pay_ton_{tariff_id}"
    )])
    buttons.append([InlineKeyboardButton(text="⬅️ Назад", callback_data="buy")])
    
    keyboard = InlineKeyboardMarkup(inline_keyboard=buttons)
    
    await callback.message.edit_text(
        f"💰 <b>Оплата тарифа {tariff['name']}</b>\n\n"
        f"📦 Тариф: {tariff['name']}\n"
        f"📱 Устройств: {tariff['devices']}\n"
        f"💵 Цена: {tariff['price_rub']}₽ / ${tariff['price_usd']}\n"
        f"📅 Период: {tariff['days']} дней\n\n"
        "Выберите способ оплаты:",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

@dp.callback_query(F.data.startswith("pay_yookassa_"))
async def pay_yookassa(callback: types.CallbackQuery):
    if not YOOKASSA_ENABLED:
        await callback.answer("ЮKassa не настроена", show_alert=True)
        return
        
    tariff_id = callback.data.replace("pay_yookassa_", "")
    tariff = TARIFFS[tariff_id]
    
    payment = Payment.create({
        "amount": {"value": str(tariff["price_rub"]), "currency": "RUB"},
        "confirmation": {"type": "redirect", "return_url": f"https://t.me/{(await bot.me()).username}"},
        "capture": True,
        "description": f"VPN {tariff['name']} - {tariff['days']} дней",
        "save_payment_method": True,
        "metadata": {"user_id": callback.from_user.id, "tariff": tariff_id}
    })
    
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="💳 Оплатить", url=payment.confirmation.confirmation_url)],
        [InlineKeyboardButton(text="✅ Я оплатил", callback_data=f"check_payment_{payment.id}_{tariff_id}")],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data=f"tariff_{tariff_id}")],
    ])
    
    await callback.message.edit_text(
        "💳 <b>Оплата через YooKassa</b>\n\n"
        "1. Нажмите кнопку «Оплатить»\n"
        "2. Оплатите на сайте ЮKassa\n"
        "3. Вернитесь и нажмите «Я оплатил»\n\n"
        f"💰 Сумма: {tariff['price_rub']}₽",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

@dp.callback_query(F.data.startswith("check_payment_"))
async def check_payment(callback: types.CallbackQuery):
    parts = callback.data.split("_")
    payment_id = parts[2]
    tariff_id = parts[3]
    
    payment = Payment.find_one(payment_id)
    
    if payment.status == "succeeded":
        await activate_subscription(callback.from_user.id, tariff_id, "yookassa", payment.amount.value)
        await callback.answer("✅ Оплата подтверждена!", show_alert=True)
    elif payment.status == "pending":
        await callback.answer("⏳ Оплата ещё не поступила. Подождите немного.", show_alert=True)
    else:
        await callback.answer(f"❌ Статус оплаты: {payment.status}", show_alert=True)

@dp.callback_query(F.data == "profile")
async def show_profile(callback: types.CallbackQuery):
    user_id = callback.from_user.id
    
    async with aiosqlite.connect("vpn_bot.db") as db:
        cursor = await db.execute(
            "SELECT subscription_end, vless_key, tariff FROM users WHERE user_id = ?",
            (user_id,)
        )
        row = await cursor.fetchone()
    
    if row and row[0]:
        sub_end = datetime.fromisoformat(row[0])
        if sub_end > datetime.now():
            days_left = (sub_end - datetime.now()).days
            
            keyboard = InlineKeyboardMarkup(inline_keyboard=[
                [InlineKeyboardButton(text="🔑 Показать ключ", callback_data="show_key")],
                [InlineKeyboardButton(text="🔄 Продлить", callback_data="buy")],
                [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_main")],
            ])
            
            await callback.message.edit_text(
                f"👤 <b>Ваш профиль</b>\n\n"
                f"📦 Тариф: {row[2] or 'Стандарт'}\n"
                f"📅 Активен до: {sub_end.strftime('%d.%m.%Y')}\n"
                f"⏳ Осталось: {days_left} дней\n\n"
                f"🆔 Ваш ID: <code>{user_id}</code>",
                reply_markup=keyboard,
                parse_mode="HTML"
            )
            await callback.answer()
            return
    
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🛒 Купить VPN", callback_data="buy")],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_main")],
    ])
    
    await callback.message.edit_text(
        f"👤 <b>Ваш профиль</b>\n\n"
        f"📦 Подписка: <b>Не активна</b>\n\n"
        f"🆔 Ваш ID: <code>{user_id}</code>",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

@dp.callback_query(F.data == "show_key")
async def show_key(callback: types.CallbackQuery):
    user_id = callback.from_user.id
    
    async with aiosqlite.connect("vpn_bot.db") as db:
        cursor = await db.execute(
            "SELECT vless_key FROM users WHERE user_id = ?",
            (user_id,)
        )
        row = await cursor.fetchone()
    
    if row and row[0]:
        keyboard = InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="⬅️ Назад", callback_data="profile")],
        ])
        
        await callback.message.edit_text(
            "🔑 <b>Ваш VLESS ключ:</b>\n\n"
            f"<code>{row[0]}</code>\n\n"
            "📱 <b>Приложения для подключения:</b>\n"
            "• iOS: Streisand, Shadowrocket\n"
            "• Android: v2rayNG, NekoBox\n"
            "• Windows: V2rayN, Nekoray\n"
            "• macOS: V2rayU, Nekoray\n\n"
            "📋 Скопируйте ключ и вставьте в приложение",
            reply_markup=keyboard,
            parse_mode="HTML"
        )
    
    await callback.answer()

@dp.callback_query(F.data == "help")
async def show_help(callback: types.CallbackQuery):
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_main")],
    ])
    
    await callback.message.edit_text(
        "📖 <b>Как подключиться к VPN:</b>\n\n"
        "<b>1. Купите подписку</b>\n"
        "   Нажмите «Купить VPN» и выберите тариф\n\n"
        "<b>2. Скачайте приложение</b>\n"
        "   • iOS: Streisand или Shadowrocket\n"
        "   • Android: v2rayNG или NekoBox\n"
        "   • Windows/Mac: V2rayN или Nekoray\n\n"
        "<b>3. Скопируйте ключ</b>\n"
        "   После оплаты вы получите VLESS ключ\n\n"
        "<b>4. Вставьте ключ в приложение</b>\n"
        "   Нажмите + или «Импорт» и вставьте ключ\n\n"
        "<b>5. Подключитесь!</b>\n"
        "   Нажмите кнопку подключения в приложении",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

@dp.callback_query(F.data == "support")
async def show_support(callback: types.CallbackQuery):
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_main")],
    ])
    
    await callback.message.edit_text(
        "💬 <b>Поддержка</b>\n\n"
        "Если у вас возникли проблемы:\n\n"
        "1. Проверьте правильность ключа\n"
        "2. Попробуйте другое приложение\n"
        "3. Перезагрузите устройство\n\n"
        "Для связи с поддержкой напишите нам ваш вопрос прямо в этот чат.",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

@dp.callback_query(F.data == "back_main")
async def back_main(callback: types.CallbackQuery):
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🛒 Купить VPN", callback_data="buy")],
        [InlineKeyboardButton(text="👤 Мой профиль", callback_data="profile")],
        [InlineKeyboardButton(text="📖 Инструкция", callback_data="help")],
        [InlineKeyboardButton(text="💬 Поддержка", callback_data="support")],
    ])
    
    await callback.message.edit_text(
        "🛡️ <b>VPN Bot</b>\n\n"
        "Выберите действие:",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

async def activate_subscription(user_id: int, tariff_id: str, method: str, amount: float):
    """Activate subscription and send VLESS key"""
    tariff = TARIFFS[tariff_id]
    vless_key = generate_vless_key(user_id)
    end_date = datetime.now() + timedelta(days=tariff["days"])
    
    async with aiosqlite.connect("vpn_bot.db") as db:
        await db.execute(
            "INSERT OR REPLACE INTO users (user_id, subscription_end, vless_key, tariff) VALUES (?, ?, ?, ?)",
            (user_id, end_date.isoformat(), vless_key, tariff["name"])
        )
        await db.execute(
            "INSERT INTO payments (user_id, amount, currency, method, status, tariff) VALUES (?, ?, ?, ?, ?, ?)",
            (user_id, amount, "RUB", method, "completed", tariff_id)
        )
        await db.commit()
    
    await bot.send_message(
        user_id,
        f"✅ <b>Подписка активирована!</b>\n\n"
        f"📦 Тариф: {tariff['name']}\n"
        f"📱 Устройств: {tariff['devices']}\n"
        f"📅 Активна до: {end_date.strftime('%d.%m.%Y')}\n\n"
        f"🔑 <b>Ваш VLESS ключ:</b>\n"
        f"<code>{vless_key}</code>\n\n"
        f"📱 <b>Приложения:</b>\n"
        f"• iOS: Streisand, Shadowrocket\n"
        f"• Android: v2rayNG, NekoBox\n"
        f"• Windows/Mac: V2rayN, Nekoray\n\n"
        f"📋 Скопируйте ключ и вставьте в приложение",
        parse_mode="HTML"
    )
    
    # Notify admin
    for admin_id in ADMIN_IDS:
        try:
            await bot.send_message(
                admin_id,
                f"💰 <b>Новая оплата!</b>\n\n"
                f"👤 User ID: {user_id}\n"
                f"📦 Тариф: {tariff['name']}\n"
                f"💵 Сумма: {amount}₽\n"
                f"💳 Метод: {method}",
                parse_mode="HTML"
            )
        except:
            pass

# Admin commands
@dp.message(Command("admin"))
async def admin_panel(message: types.Message):
    if message.from_user.id not in ADMIN_IDS:
        return
    
    async with aiosqlite.connect("vpn_bot.db") as db:
        cursor = await db.execute("SELECT COUNT(*) FROM users WHERE subscription_end > datetime('now')")
        active_users = (await cursor.fetchone())[0]
        
        cursor = await db.execute("SELECT COUNT(*) FROM users")
        total_users = (await cursor.fetchone())[0]
        
        cursor = await db.execute("SELECT SUM(amount) FROM payments WHERE status = 'completed'")
        total_revenue = (await cursor.fetchone())[0] or 0
    
    await message.answer(
        "👑 <b>Админ панель</b>\n\n"
        f"👥 Всего пользователей: {total_users}\n"
        f"✅ Активных подписок: {active_users}\n"
        f"💰 Общий доход: {total_revenue}₽\n\n"
        "<b>Команды:</b>\n"
        "/adduser ID DAYS - Выдать подписку\n"
        "/stats - Статистика",
        parse_mode="HTML"
    )

@dp.message(Command("adduser"))
async def add_user(message: types.Message):
    if message.from_user.id not in ADMIN_IDS:
        return
    
    try:
        parts = message.text.split()
        user_id = int(parts[1])
        days = int(parts[2]) if len(parts) > 2 else 30
        
        await activate_subscription(user_id, "premium", "admin", 0)
        await message.answer(f"✅ Подписка выдана пользователю {user_id} на {days} дней")
    except Exception as e:
        await message.answer(f"❌ Ошибка: {e}\n\nИспользование: /adduser USER_ID DAYS")

async def main():
    print("🚀 Запуск VPN Bot...")
    await init_db()
    print("✅ База данных инициализирована")
    print("✅ Бот запущен и готов к работе!")
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
BOTCODE

    print_success "Файл bot.py создан!"
}

# Создание systemd сервиса
create_service() {
    print_step "ШАГ 7/7: Настройка автозапуска"
    
    cat > /etc/systemd/system/vpn-bot.service << EOF
[Unit]
Description=VPN Telegram Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/vpn-bot
ExecStart=/opt/vpn-bot/venv/bin/python bot.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable vpn-bot
    systemctl start vpn-bot
    
    print_success "Сервис создан и запущен!"
}

# Финальное сообщение
finish() {
    echo -e "\n${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 🎉 УСТАНОВКА ЗАВЕРШЕНА! 🎉                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}Полезные команды:${NC}"
    echo "  • Статус бота:     systemctl status vpn-bot"
    echo "  • Логи бота:       journalctl -u vpn-bot -f"
    echo "  • Перезапуск:      systemctl restart vpn-bot"
    echo "  • Остановка:       systemctl stop vpn-bot"
    echo ""
    echo -e "${YELLOW}Файлы бота:${NC}"
    echo "  • Конфигурация:    /opt/vpn-bot/.env"
    echo "  • Код бота:        /opt/vpn-bot/bot.py"
    echo "  • База данных:     /opt/vpn-bot/vpn_bot.db"
    echo ""
    echo -e "${GREEN}Теперь откройте бота в Telegram и отправьте /start${NC}"
    echo ""
}

# Главная функция
main() {
    check_root
    welcome
    install_packages
    create_directory
    setup_python
    collect_data
    create_env
    create_bot
    create_service
    finish
}

# Запуск
main
