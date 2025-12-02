#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║     VPN TELEGRAM BOT - ПОЛНЫЙ АВТОМАТИЧЕСКИЙ УСТАНОВЩИК                      ║
# ║                      Версия 2.0 | VPN Bot Team                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# Принудительно читаем с терминала
exec < /dev/tty

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Директории
BOT_DIR="/opt/vpn-bot"
WEB_DIR="/var/www/vpn-panel"

# Функции вывода
clear_screen() {
    clear
}

print_logo() {
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                       ║"
    echo "║   ██╗   ██╗██████╗ ███╗   ██╗    ██████╗  ██████╗ ████████╗           ║"
    echo "║   ██║   ██║██╔══██╗████╗  ██║    ██╔══██╗██╔═══██╗╚══██╔══╝           ║"
    echo "║   ██║   ██║██████╔╝██╔██╗ ██║    ██████╔╝██║   ██║   ██║              ║"
    echo "║   ╚██╗ ██╔╝██╔═══╝ ██║╚██╗██║    ██╔══██╗██║   ██║   ██║              ║"
    echo "║    ╚████╔╝ ██║     ██║ ╚████║    ██████╔╝╚██████╔╝   ██║              ║"
    echo "║     ╚═══╝  ╚═╝     ╚═╝  ╚═══╝    ╚═════╝  ╚═════╝    ╚═╝              ║"
    echo "║                                                                       ║"
    echo "║                    ПОЛНЫЙ АВТОМАТИЧЕСКИЙ УСТАНОВЩИК                   ║"
    echo "║                                                                       ║"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}  ✓ $1${NC}"
}

print_error() {
    echo -e "${RED}  ✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}  ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
}

print_input() {
    echo -e "${YELLOW}  → $1${NC}"
}

# Проверка root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Запустите скрипт от имени root!"
        echo ""
        echo "  Используйте команду:"
        echo -e "  ${CYAN}sudo bash install.sh${NC}"
        echo ""
        exit 1
    fi
}

# Запрос с валидацией (обязательное поле)
ask_required() {
    local prompt="$1"
    local var_name="$2"
    local value=""
    
    while true; do
        echo -e "${YELLOW}  → ${prompt}${NC}"
        echo -n "    > "
        read value
        if [ -n "$value" ]; then
            eval "$var_name='$value'"
            print_success "Сохранено!"
            break
        else
            print_error "Это поле обязательно! Введите значение."
        fi
    done
}

# Запрос (необязательное поле)
ask_optional() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    local value=""
    
    if [ -n "$default" ]; then
        echo -e "${YELLOW}  → ${prompt} ${BLUE}[по умолчанию: ${default}]${NC}"
    else
        echo -e "${YELLOW}  → ${prompt} ${BLUE}[необязательно, Enter для пропуска]${NC}"
    fi
    echo -n "    > "
    read value
    
    if [ -z "$value" ] && [ -n "$default" ]; then
        value="$default"
    fi
    
    eval "$var_name='$value'"
    
    if [ -n "$value" ]; then
        print_success "Сохранено!"
    else
        print_info "Пропущено"
    fi
}

# Подтверждение да/нет
ask_confirm() {
    local prompt="$1"
    local response=""
    
    echo -e "${YELLOW}  → ${prompt} (y/n)${NC}"
    echo -n "    > "
    read response
    
    if [ "$response" = "y" ] || [ "$response" = "Y" ] || [ "$response" = "д" ] || [ "$response" = "Д" ]; then
        return 0
    else
        return 1
    fi
}

# Ожидание нажатия Enter
wait_enter() {
    echo ""
    echo -e "${BLUE}  Нажмите Enter чтобы продолжить...${NC}"
    read
}

# ═══════════════════════════════════════════════════════════════════════════════
# ЭТАП 0: ПРИВЕТСТВИЕ
# ═══════════════════════════════════════════════════════════════════════════════
welcome() {
    clear_screen
    print_logo
    
    echo -e "${GREEN}  Добро пожаловать в полный установщик VPN Bot!${NC}"
    echo ""
    echo "  Этот скрипт автоматически установит и настроит:"
    echo ""
    echo -e "  ${WHITE}1.${NC} Системные пакеты и зависимости"
    echo -e "  ${WHITE}2.${NC} VPN сервер (3X-UI + VLESS Reality)"
    echo -e "  ${WHITE}3.${NC} Telegram бота для продаж"
    echo -e "  ${WHITE}4.${NC} Платёжные системы (ЮKassa, CryptoBot, TON)"
    echo -e "  ${WHITE}5.${NC} Веб-панель администратора"
    echo -e "  ${WHITE}6.${NC} Автозапуск всех сервисов"
    echo ""
    echo -e "${YELLOW}  Подготовьте заранее:${NC}"
    echo "  • Токен Telegram бота от @BotFather"
    echo "  • Ваш Telegram ID от @userinfobot"  
    echo "  • Данные ЮKassa (если есть ИП/ООО)"
    echo "  • Токен CryptoBot (если нужна крипта)"
    echo ""
    
    wait_enter
}

# ═══════════════════════════════════════════════════════════════════════════════
# ЭТАП 1: УСТАНОВКА ПАКЕТОВ
# ═══════════════════════════════════════════════════════════════════════════════
install_packages() {
    clear_screen
    print_logo
    print_step "ЭТАП 1 из 8: УСТАНОВКА СИСТЕМНЫХ ПАКЕТОВ"
    
    print_info "Обновляем список пакетов..."
    apt update -qq > /dev/null 2>&1
    print_success "Список пакетов обновлён"
    
    print_info "Обновляем систему..."
    apt upgrade -y -qq > /dev/null 2>&1
    print_success "Система обновлена"
    
    print_info "Устанавливаем необходимые пакеты..."
    apt install -y -qq python3 python3-pip python3-venv git curl wget nano ufw nginx certbot python3-certbot-nginx > /dev/null 2>&1
    print_success "Пакеты установлены: Python, Git, Nginx, Certbot"
    
    # Node.js для веб-панели
    print_info "Устанавливаем Node.js..."
    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
        apt install -y -qq nodejs > /dev/null 2>&1
    fi
    print_success "Node.js установлен"
    
    wait_enter
}

# ═══════════════════════════════════════════════════════════════════════════════
# ЭТАП 2: НАСТРОЙКА VPN СЕРВЕРА (3X-UI)
# ═══════════════════════════════════════════════════════════════════════════════
setup_vpn_server() {
    clear_screen
    print_logo
    print_step "ЭТАП 2 из 8: УСТАНОВКА VPN СЕРВЕРА (3X-UI)"
    
    echo -e "  ${WHITE}3X-UI - это панель управления для VLESS/Reality VPN.${NC}"
    echo ""
    
    if ask_confirm "Установить 3X-UI на этот сервер?"; then
        print_info "Устанавливаем 3X-UI..."
        bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) << EOF
y
EOF
        print_success "3X-UI установлен!"
        echo ""
        print_warning "ВАЖНО! Запомните данные для входа в панель 3X-UI!"
        print_info "Панель доступна по адресу: http://$(curl -s ifconfig.me):2053"
        
        INSTALL_3XUI="yes"
    else
        print_info "Пропускаем установку 3X-UI"
        INSTALL_3XUI="no"
    fi
    
    wait_enter
}

# ═══════════════════════════════════════════════════════════════════════════════
# ЭТАП 3: НАСТРОЙКА TELEGRAM БОТА
# ═══════════════════════════════════════════════════════════════════════════════
setup_telegram_bot() {
    clear_screen
    print_logo
    print_step "ЭТАП 3 из 8: НАСТРОЙКА TELEGRAM БОТА"
    
    echo -e "  ${WHITE}Создайте бота в @BotFather и получите токен.${NC}"
    echo ""
    echo "  Как создать бота:"
    echo "  1. Откройте @BotFather в Telegram"
    echo "  2. Отправьте /newbot"
    echo "  3. Введите имя бота"
    echo "  4. Введите username бота (должен заканчиваться на 'bot')"
    echo "  5. Скопируйте токен"
    echo ""
    
    ask_required "Введите токен бота" BOT_TOKEN
    
    echo ""
    echo -e "  ${WHITE}Теперь узнайте ваш Telegram ID в @userinfobot${NC}"
    echo ""
    
    ask_required "Введите ваш Telegram ID (число)" ADMIN_ID
    
    # Проверка токена
    print_info "Проверяем токен бота..."
    RESPONSE=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getMe")
    if echo "$RESPONSE" | grep -q '"ok":true'; then
        BOT_USERNAME=$(echo "$RESPONSE" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
        print_success "Бот найден: @${BOT_USERNAME}"
    else
        print_error "Токен недействителен! Проверьте правильность."
        ask_required "Введите токен бота заново" BOT_TOKEN
    fi
    
    wait_enter
}

# ═══════════════════════════════════════════════════════════════════════════════
# ЭТАП 4: НАСТРОЙКА ЮKASSA
# ═══════════════════════════════════════════════════════════════════════════════
setup_yookassa() {
    clear_screen
    print_logo
    print_step "ЭТАП 4 из 8: НАСТРОЙКА ЮKASSA (оплата картой)"
    
    echo -e "  ${WHITE}ЮKassa - приём платежей картой для ИП/ООО.${NC}"
    echo ""
    echo "  Если у вас нет ИП/ООО - пропустите этот шаг."
    echo ""
    echo "  Как получить данные:"
    echo "  1. Зарегистрируйтесь на yookassa.ru"
    echo "  2. Подключите магазин"
    echo "  3. Перейдите в Интеграция → Ключи API"
    echo "  4. Скопируйте Shop ID и Secret Key"
    echo ""
    
    if ask_confirm "Настроить ЮKassa?"; then
        ask_required "Введите Shop ID (число)" YOOKASSA_SHOP_ID
        ask_required "Введите Secret Key" YOOKASSA_SECRET_KEY
        YOOKASSA_ENABLED="true"
        print_success "ЮKassa настроена!"
    else
        YOOKASSA_SHOP_ID=""
        YOOKASSA_SECRET_KEY=""
        YOOKASSA_ENABLED="false"
        print_info "ЮKassa пропущена"
    fi
    
    wait_enter
}

# ═══════════════════════════════════════════════════════════════════════════════
# ЭТАП 5: НАСТРОЙКА CRYPTOBOT
# ═══════════════════════════════════════════════════════════════════════════════
setup_cryptobot() {
    clear_screen
    print_logo
    print_step "ЭТАП 5 из 8: НАСТРОЙКА CRYPTOBOT (крипто-оплата)"
    
    echo -e "  ${WHITE}CryptoBot - приём криптовалютных платежей.${NC}"
    echo ""
    echo "  Как получить токен:"
    echo "  1. Откройте @CryptoBot в Telegram"
    echo "  2. Нажмите Crypto Pay"
    echo "  3. Создайте приложение"
    echo "  4. Скопируйте API Token"
    echo ""
    
    if ask_confirm "Настроить CryptoBot?"; then
        ask_required "Введите токен CryptoBot" CRYPTOBOT_TOKEN
        CRYPTOBOT_ENABLED="true"
        print_success "CryptoBot настроен!"
    else
        CRYPTOBOT_TOKEN=""
        CRYPTOBOT_ENABLED="false"
        print_info "CryptoBot пропущен"
    fi
    
    wait_enter
}

# ═══════════════════════════════════════════════════════════════════════════════
# ЭТАП 6: НАСТРОЙКА TON CONNECT
# ═══════════════════════════════════════════════════════════════════════════════
setup_ton() {
    clear_screen
    print_logo
    print_step "ЭТАП 6 из 8: НАСТРОЙКА TON CONNECT (оплата TON)"
    
    echo -e "  ${WHITE}TON Connect - оплата через кошельки TON (Tonkeeper и др.)${NC}"
    echo ""
    echo "  Для приёма TON нужен кошелёк и manifest URL."
    echo ""
    
    if ask_confirm "Настроить TON Connect?"; then
        ask_required "Введите адрес TON кошелька" TON_WALLET_ADDRESS
        ask_optional "Введите Manifest URL (или Enter для пропуска)" TON_MANIFEST_URL ""
        TON_ENABLED="true"
        print_success "TON Connect настроен!"
    else
        TON_WALLET_ADDRESS=""
        TON_MANIFEST_URL=""
        TON_ENABLED="false"
        print_info "TON Connect пропущен"
    fi
    
    wait_enter
}

# ═══════════════════════════════════════════════════════════════════════════════
# ЭТАП 7: НАСТРОЙКА VPN ПАРАМЕТРОВ
# ═══════════════════════════════════════════════════════════════════════════════
setup_vpn_params() {
    clear_screen
    print_logo
    print_step "ЭТАП 7 из 8: НАСТРОЙКА ПАРАМЕТРОВ VPN"
    
    echo -e "  ${WHITE}Введите параметры вашего VPN сервера.${NC}"
    echo ""
    echo "  Эти данные нужны для генерации VLESS ключей."
    echo "  Получите их из панели 3X-UI после создания inbound."
    echo ""
    
    # Автоопределение IP
    SERVER_IP=$(curl -s ifconfig.me)
    
    ask_optional "IP адрес VPN сервера" VPN_SERVER_IP "$SERVER_IP"
    ask_optional "Порт VPN сервера" VPN_SERVER_PORT "443"
    
    echo ""
    echo -e "  ${WHITE}Следующие данные получите из 3X-UI после настройки VLESS Reality:${NC}"
    echo ""
    
    ask_optional "Public Key (pbk)" VPN_PUBLIC_KEY ""
    ask_optional "Short ID (sid)" VPN_SHORT_ID ""
    ask_optional "SNI домен" VPN_SNI "google.com"
    
    echo ""
    echo -e "  ${WHITE}Настройка тарифов (цены в рублях):${NC}"
    echo ""
    
    ask_optional "Цена Basic (1 устройство)" PRICE_BASIC "290"
    ask_optional "Цена Premium (3 устройства)" PRICE_PREMIUM "590"
    ask_optional "Цена Ultimate (5 устройств)" PRICE_ULTIMATE "990"
    
    wait_enter
}

# ═══════════════════════════════════════════════════════════════════════════════
# ЭТАП 8: СОЗДАНИЕ И ЗАПУСК
# ═══════════════════════════════════════════════════════════════════════════════
create_and_run() {
    clear_screen
    print_logo
    print_step "ЭТАП 8 из 8: СОЗДАНИЕ ФАЙЛОВ И ЗАПУСК"
    
    # Создание директории
    print_info "Создаём директорию бота..."
    mkdir -p "$BOT_DIR"
    cd "$BOT_DIR"
    print_success "Директория создана: $BOT_DIR"
    
    # Создание виртуального окружения
    print_info "Создаём Python окружение..."
    python3 -m venv venv
    source venv/bin/activate
    pip install --quiet --upgrade pip
    pip install --quiet aiogram aiohttp python-dotenv aiosqlite
    
    if [ "$YOOKASSA_ENABLED" = "true" ]; then
        pip install --quiet yookassa
    fi
    
    print_success "Python окружение готово"
    
    # Создание .env
    print_info "Создаём конфигурацию..."
    cat > "$BOT_DIR/.env" << EOF
# ═══════════════════════════════════════════════════════════════
# VPN BOT - КОНФИГУРАЦИЯ
# Создано: $(date '+%Y-%m-%d %H:%M:%S')
# ═══════════════════════════════════════════════════════════════

# TELEGRAM BOT
BOT_TOKEN=${BOT_TOKEN}
ADMIN_IDS=${ADMIN_ID}

# ЮKASSA
YOOKASSA_ENABLED=${YOOKASSA_ENABLED}
YOOKASSA_SHOP_ID=${YOOKASSA_SHOP_ID}
YOOKASSA_SECRET_KEY=${YOOKASSA_SECRET_KEY}

# CRYPTOBOT  
CRYPTOBOT_ENABLED=${CRYPTOBOT_ENABLED}
CRYPTOBOT_TOKEN=${CRYPTOBOT_TOKEN}

# TON CONNECT
TON_ENABLED=${TON_ENABLED}
TON_WALLET_ADDRESS=${TON_WALLET_ADDRESS}
TON_MANIFEST_URL=${TON_MANIFEST_URL}

# VPN SERVER
VPN_SERVER_IP=${VPN_SERVER_IP}
VPN_SERVER_PORT=${VPN_SERVER_PORT}
VPN_PUBLIC_KEY=${VPN_PUBLIC_KEY}
VPN_SHORT_ID=${VPN_SHORT_ID}
VPN_SNI=${VPN_SNI}

# PRICES (RUB)
PRICE_BASIC=${PRICE_BASIC}
PRICE_PREMIUM=${PRICE_PREMIUM}
PRICE_ULTIMATE=${PRICE_ULTIMATE}
EOF
    print_success "Конфигурация создана"
    
    # Создание бота
    print_info "Создаём файл бота..."
    create_bot_file
    print_success "Бот создан"
    
    # Создание systemd сервиса
    print_info "Настраиваем автозапуск..."
    cat > /etc/systemd/system/vpn-bot.service << EOF
[Unit]
Description=VPN Telegram Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${BOT_DIR}
ExecStart=${BOT_DIR}/venv/bin/python ${BOT_DIR}/bot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable vpn-bot > /dev/null 2>&1
    systemctl start vpn-bot
    print_success "Автозапуск настроен"
    
    # Проверка статуса
    sleep 2
    if systemctl is-active --quiet vpn-bot; then
        print_success "Бот запущен и работает!"
    else
        print_warning "Бот запущен, но возможны ошибки. Проверьте: journalctl -u vpn-bot -f"
    fi
    
    wait_enter
}

# Создание файла бота
create_bot_file() {
    cat > "$BOT_DIR/bot.py" << 'BOTEOF'
import asyncio
import os
import uuid
import logging
from datetime import datetime, timedelta
from dotenv import load_dotenv
from aiogram import Bot, Dispatcher, types, F
from aiogram.filters import Command
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
import aiosqlite

load_dotenv()

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Config
BOT_TOKEN = os.getenv("BOT_TOKEN")
ADMIN_IDS = [int(x.strip()) for x in os.getenv("ADMIN_IDS", "").split(",") if x.strip()]

# VPN Config
VPN_SERVER = os.getenv("VPN_SERVER_IP", "")
VPN_PORT = os.getenv("VPN_SERVER_PORT", "443")
VPN_PBK = os.getenv("VPN_PUBLIC_KEY", "")
VPN_SID = os.getenv("VPN_SHORT_ID", "")
VPN_SNI = os.getenv("VPN_SNI", "google.com")

# Prices
PRICE_BASIC = int(os.getenv("PRICE_BASIC", 290))
PRICE_PREMIUM = int(os.getenv("PRICE_PREMIUM", 590))
PRICE_ULTIMATE = int(os.getenv("PRICE_ULTIMATE", 990))

# Payment systems
YOOKASSA_ENABLED = os.getenv("YOOKASSA_ENABLED", "false").lower() == "true"
CRYPTOBOT_ENABLED = os.getenv("CRYPTOBOT_ENABLED", "false").lower() == "true"
TON_ENABLED = os.getenv("TON_ENABLED", "false").lower() == "true"

if YOOKASSA_ENABLED:
    try:
        from yookassa import Configuration, Payment
        Configuration.account_id = os.getenv("YOOKASSA_SHOP_ID")
        Configuration.secret_key = os.getenv("YOOKASSA_SECRET_KEY")
        logger.info("YooKassa enabled")
    except Exception as e:
        logger.error(f"YooKassa error: {e}")
        YOOKASSA_ENABLED = False

CRYPTOBOT_TOKEN = os.getenv("CRYPTOBOT_TOKEN", "")
TON_WALLET = os.getenv("TON_WALLET_ADDRESS", "")

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

# Tariffs
TARIFFS = {
    "basic": {"name": "Basic", "price_rub": PRICE_BASIC, "price_usd": 3, "days": 30, "devices": 1},
    "premium": {"name": "Premium", "price_rub": PRICE_PREMIUM, "price_usd": 6, "days": 30, "devices": 3},
    "ultimate": {"name": "Ultimate", "price_rub": PRICE_ULTIMATE, "price_usd": 10, "days": 30, "devices": 5},
}

DB_PATH = "vpn_bot.db"

async def init_db():
    async with aiosqlite.connect(DB_PATH) as db:
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

def generate_vless_key(user_id: int) -> str:
    key_uuid = str(uuid.uuid4())
    if VPN_PBK and VPN_SID:
        return f"vless://{key_uuid}@{VPN_SERVER}:{VPN_PORT}?encryption=none&security=reality&sni={VPN_SNI}&fp=chrome&pbk={VPN_PBK}&sid={VPN_SID}&type=tcp&flow=xtls-rprx-vision#VPN-{user_id}"
    else:
        return f"vless://{key_uuid}@{VPN_SERVER}:{VPN_PORT}?encryption=none&type=tcp#VPN-{user_id}"

async def get_user(user_id: int):
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT * FROM users WHERE user_id = ?", (user_id,)) as cursor:
            return await cursor.fetchone()

async def create_or_update_user(user_id: int, username: str, tariff: str, days: int):
    vless_key = generate_vless_key(user_id)
    subscription_end = datetime.now() + timedelta(days=days)
    
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("""
            INSERT INTO users (user_id, username, subscription_end, vless_key, tariff)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(user_id) DO UPDATE SET
                subscription_end = ?,
                vless_key = ?,
                tariff = ?
        """, (user_id, username, subscription_end, vless_key, tariff, subscription_end, vless_key, tariff))
        await db.commit()
    
    return vless_key, subscription_end

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
            text=f"🔹 Basic ({TARIFFS['basic']['devices']} устр.) - {TARIFFS['basic']['price_rub']}₽", 
            callback_data="tariff_basic"
        )],
        [InlineKeyboardButton(
            text=f"🔸 Premium ({TARIFFS['premium']['devices']} устр.) - {TARIFFS['premium']['price_rub']}₽", 
            callback_data="tariff_premium"
        )],
        [InlineKeyboardButton(
            text=f"💎 Ultimate ({TARIFFS['ultimate']['devices']} устр.) - {TARIFFS['ultimate']['price_rub']}₽", 
            callback_data="tariff_ultimate"
        )],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_main")],
    ])
    
    await callback.message.edit_text(
        "📦 <b>Выберите тариф:</b>\n\n"
        f"🔹 <b>Basic</b> - {TARIFFS['basic']['devices']} устройство, {TARIFFS['basic']['days']} дней\n"
        f"🔸 <b>Premium</b> - {TARIFFS['premium']['devices']} устройства, {TARIFFS['premium']['days']} дней\n"
        f"💎 <b>Ultimate</b> - {TARIFFS['ultimate']['devices']} устройств, {TARIFFS['ultimate']['days']} дней\n",
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
    
    if CRYPTOBOT_ENABLED:
        buttons.append([InlineKeyboardButton(
            text="🪙 Крипта (CryptoBot)", 
            callback_data=f"pay_crypto_{tariff_id}"
        )])
    
    if TON_ENABLED:
        buttons.append([InlineKeyboardButton(
            text="💎 TON", 
            callback_data=f"pay_ton_{tariff_id}"
        )])
    
    if not buttons:
        buttons.append([InlineKeyboardButton(
            text="💬 Связаться с админом", 
            url=f"tg://user?id={ADMIN_IDS[0] if ADMIN_IDS else 0}"
        )])
    
    buttons.append([InlineKeyboardButton(text="⬅️ Назад", callback_data="buy")])
    
    keyboard = InlineKeyboardMarkup(inline_keyboard=buttons)
    
    await callback.message.edit_text(
        f"💰 <b>Оплата тарифа {tariff['name']}</b>\n\n"
        f"📦 Тариф: {tariff['name']}\n"
        f"📱 Устройств: {tariff['devices']}\n"
        f"💵 Цена: {tariff['price_rub']}₽\n"
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
    
    try:
        payment = Payment.create({
            "amount": {"value": str(tariff["price_rub"]), "currency": "RUB"},
            "confirmation": {"type": "redirect", "return_url": f"https://t.me/{(await bot.me()).username}"},
            "capture": True,
            "description": f"VPN {tariff['name']} - {tariff['days']} дней",
            "metadata": {"user_id": callback.from_user.id, "tariff": tariff_id}
        })
        
        keyboard = InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="💳 Оплатить", url=payment.confirmation.confirmation_url)],
            [InlineKeyboardButton(text="✅ Я оплатил", callback_data=f"check_yookassa_{payment.id}_{tariff_id}")],
            [InlineKeyboardButton(text="⬅️ Назад", callback_data=f"tariff_{tariff_id}")],
        ])
        
        await callback.message.edit_text(
            "💳 <b>Оплата через YooKassa</b>\n\n"
            "1. Нажмите «Оплатить»\n"
            "2. Оплатите на сайте\n"
            "3. Нажмите «Я оплатил»\n\n"
            f"💰 Сумма: {tariff['price_rub']}₽",
            reply_markup=keyboard,
            parse_mode="HTML"
        )
    except Exception as e:
        logger.error(f"YooKassa error: {e}")
        await callback.answer("Ошибка создания платежа", show_alert=True)
    
    await callback.answer()

@dp.callback_query(F.data.startswith("check_yookassa_"))
async def check_yookassa(callback: types.CallbackQuery):
    parts = callback.data.split("_")
    payment_id = parts[2]
    tariff_id = parts[3]
    tariff = TARIFFS[tariff_id]
    
    try:
        payment = Payment.find_one(payment_id)
        
        if payment.status == "succeeded":
            vless_key, sub_end = await create_or_update_user(
                callback.from_user.id,
                callback.from_user.username or "",
                tariff_id,
                tariff["days"]
            )
            
            await callback.message.edit_text(
                "✅ <b>Оплата успешна!</b>\n\n"
                f"📦 Тариф: {tariff['name']}\n"
                f"📅 Действует до: {sub_end.strftime('%d.%m.%Y')}\n\n"
                f"🔑 <b>Ваш VLESS ключ:</b>\n"
                f"<code>{vless_key}</code>\n\n"
                "📱 Скопируйте ключ и вставьте в приложение:\n"
                "• iOS: Streisand, V2Box\n"
                "• Android: V2rayNG, NekoBox\n"
                "• Windows/Mac: V2rayN, Nekoray",
                parse_mode="HTML"
            )
        else:
            await callback.answer(f"Статус платежа: {payment.status}. Попробуйте позже.", show_alert=True)
    except Exception as e:
        logger.error(f"Check payment error: {e}")
        await callback.answer("Ошибка проверки платежа", show_alert=True)

@dp.callback_query(F.data.startswith("pay_crypto_"))
async def pay_crypto(callback: types.CallbackQuery):
    tariff_id = callback.data.replace("pay_crypto_", "")
    tariff = TARIFFS[tariff_id]
    
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🪙 Оплатить в CryptoBot", url=f"https://t.me/CryptoBot")],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data=f"tariff_{tariff_id}")],
    ])
    
    await callback.message.edit_text(
        "🪙 <b>Оплата через CryptoBot</b>\n\n"
        f"💰 Сумма: ${tariff['price_usd']} USD\n\n"
        "Свяжитесь с админом для получения ссылки на оплату.",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

@dp.callback_query(F.data.startswith("pay_ton_"))
async def pay_ton(callback: types.CallbackQuery):
    tariff_id = callback.data.replace("pay_ton_", "")
    tariff = TARIFFS[tariff_id]
    
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="💎 Кошелёк TON", url=f"ton://transfer/{TON_WALLET}")],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data=f"tariff_{tariff_id}")],
    ])
    
    await callback.message.edit_text(
        "💎 <b>Оплата через TON</b>\n\n"
        f"💰 Адрес: <code>{TON_WALLET}</code>\n\n"
        "После оплаты свяжитесь с админом для активации.",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

@dp.callback_query(F.data == "profile")
async def show_profile(callback: types.CallbackQuery):
    user = await get_user(callback.from_user.id)
    
    if user:
        user_id, username, sub_end, vless_key, tariff, created = user
        sub_end_dt = datetime.fromisoformat(sub_end) if sub_end else None
        
        if sub_end_dt and sub_end_dt > datetime.now():
            status = f"✅ Активна до {sub_end_dt.strftime('%d.%m.%Y')}"
            key_text = f"\n\n🔑 <b>Ваш ключ:</b>\n<code>{vless_key}</code>"
        else:
            status = "❌ Неактивна"
            key_text = ""
        
        text = (
            f"👤 <b>Ваш профиль</b>\n\n"
            f"🆔 ID: {callback.from_user.id}\n"
            f"📦 Тариф: {tariff or 'Нет'}\n"
            f"📊 Подписка: {status}"
            f"{key_text}"
        )
    else:
        text = (
            f"👤 <b>Ваш профиль</b>\n\n"
            f"🆔 ID: {callback.from_user.id}\n"
            f"📊 Подписка: ❌ Неактивна\n\n"
            "Купите подписку чтобы получить VPN!"
        )
    
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🛒 Купить VPN", callback_data="buy")],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_main")],
    ])
    
    await callback.message.edit_text(text, reply_markup=keyboard, parse_mode="HTML")
    await callback.answer()

@dp.callback_query(F.data == "help")
async def show_help(callback: types.CallbackQuery):
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_main")],
    ])
    
    await callback.message.edit_text(
        "📖 <b>Инструкция по использованию VPN</b>\n\n"
        "<b>iOS:</b>\n"
        "1. Скачайте Streisand или V2Box из App Store\n"
        "2. Скопируйте VLESS ключ из профиля\n"
        "3. Вставьте ключ в приложение\n\n"
        "<b>Android:</b>\n"
        "1. Скачайте V2rayNG из Google Play\n"
        "2. Нажмите + → Импорт из буфера\n"
        "3. Включите VPN\n\n"
        "<b>Windows/Mac:</b>\n"
        "1. Скачайте V2rayN (Win) или Nekoray (Mac)\n"
        "2. Импортируйте ключ\n"
        "3. Подключитесь",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

@dp.callback_query(F.data == "support")
async def show_support(callback: types.CallbackQuery):
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="💬 Написать админу", url=f"tg://user?id={ADMIN_IDS[0] if ADMIN_IDS else 0}")],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_main")],
    ])
    
    await callback.message.edit_text(
        "💬 <b>Поддержка</b>\n\n"
        "Если у вас возникли вопросы или проблемы, "
        "напишите администратору.",
        reply_markup=keyboard,
        parse_mode="HTML"
    )
    await callback.answer()

@dp.callback_query(F.data == "back_main")
async def back_to_main(callback: types.CallbackQuery):
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

# Admin commands
@dp.message(Command("admin"))
async def cmd_admin(message: types.Message):
    if message.from_user.id not in ADMIN_IDS:
        return
    
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT COUNT(*) FROM users") as cursor:
            total_users = (await cursor.fetchone())[0]
        async with db.execute("SELECT COUNT(*) FROM users WHERE subscription_end > datetime('now')") as cursor:
            active_users = (await cursor.fetchone())[0]
        async with db.execute("SELECT COUNT(*) FROM payments WHERE status = 'succeeded'") as cursor:
            total_payments = (await cursor.fetchone())[0]
    
    await message.answer(
        "👑 <b>Админ-панель</b>\n\n"
        f"👥 Всего пользователей: {total_users}\n"
        f"✅ Активных подписок: {active_users}\n"
        f"💰 Успешных платежей: {total_payments}\n\n"
        "<b>Команды:</b>\n"
        "/stats - Статистика\n"
        "/users - Список пользователей\n"
        "/give <user_id> <tariff> - Выдать подписку",
        parse_mode="HTML"
    )

@dp.message(Command("give"))
async def cmd_give(message: types.Message):
    if message.from_user.id not in ADMIN_IDS:
        return
    
    args = message.text.split()
    if len(args) < 3:
        await message.answer("Использование: /give <user_id> <tariff>\nТарифы: basic, premium, ultimate")
        return
    
    try:
        user_id = int(args[1])
        tariff_id = args[2].lower()
        
        if tariff_id not in TARIFFS:
            await message.answer("Неверный тариф! Доступны: basic, premium, ultimate")
            return
        
        tariff = TARIFFS[tariff_id]
        vless_key, sub_end = await create_or_update_user(user_id, "", tariff_id, tariff["days"])
        
        await message.answer(
            f"✅ Подписка выдана!\n\n"
            f"👤 User ID: {user_id}\n"
            f"📦 Тариф: {tariff['name']}\n"
            f"📅 До: {sub_end.strftime('%d.%m.%Y')}"
        )
        
        # Уведомление пользователю
        try:
            await bot.send_message(
                user_id,
                f"🎉 <b>Вам выдана подписка!</b>\n\n"
                f"📦 Тариф: {tariff['name']}\n"
                f"📅 Действует до: {sub_end.strftime('%d.%m.%Y')}\n\n"
                f"🔑 <b>Ваш VLESS ключ:</b>\n"
                f"<code>{vless_key}</code>",
                parse_mode="HTML"
            )
        except:
            pass
            
    except ValueError:
        await message.answer("Неверный user_id!")

async def main():
    await init_db()
    logger.info("Bot started!")
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
BOTEOF
}

# ═══════════════════════════════════════════════════════════════════════════════
# ФИНАЛЬНЫЙ ЭКРАН
# ═══════════════════════════════════════════════════════════════════════════════
show_final() {
    clear_screen
    print_logo
    
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                       ║"
    echo "║                    ✅ УСТАНОВКА ЗАВЕРШЕНА!                            ║"
    echo "║                                                                       ║"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo ""
    echo -e "${WHITE}  📁 Файлы бота:${NC} $BOT_DIR"
    echo -e "${WHITE}  📝 Конфигурация:${NC} $BOT_DIR/.env"
    echo -e "${WHITE}  🤖 Бот:${NC} @${BOT_USERNAME:-ваш_бот}"
    echo ""
    
    if [ "$INSTALL_3XUI" = "yes" ]; then
        echo -e "${WHITE}  🌐 3X-UI панель:${NC} http://$(curl -s ifconfig.me):2053"
    fi
    
    echo ""
    echo -e "${CYAN}  Полезные команды:${NC}"
    echo ""
    echo "  • Статус бота:     systemctl status vpn-bot"
    echo "  • Логи бота:       journalctl -u vpn-bot -f"
    echo "  • Перезапуск:      systemctl restart vpn-bot"
    echo "  • Остановка:       systemctl stop vpn-bot"
    echo "  • Редактировать:   nano $BOT_DIR/.env"
    echo ""
    
    echo -e "${YELLOW}  ⚠️  Что делать дальше:${NC}"
    echo ""
    echo "  1. Настройте 3X-UI (создайте inbound с VLESS Reality)"
    echo "  2. Скопируйте pbk и sid из 3X-UI"
    echo "  3. Отредактируйте $BOT_DIR/.env"
    echo "  4. Перезапустите бота: systemctl restart vpn-bot"
    echo ""
    
    echo -e "${GREEN}  Спасибо за использование VPN Bot!${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# ГЛАВНАЯ ФУНКЦИЯ
# ═══════════════════════════════════════════════════════════════════════════════
main() {
    check_root
    welcome
    install_packages
    setup_vpn_server
    setup_telegram_bot
    setup_yookassa
    setup_cryptobot
    setup_ton
    setup_vpn_params
    create_and_run
    show_final
}

# Запуск
main
