from aiogram import Bot, Dispatcher, types
from aiogram.enums import ParseMode
from aiogram.fsm.storage.memory import MemoryStorage
from aiogram.types import Message
from config import BOT_TOKEN
import asyncio
from handlers import register_handlers

bot = Bot(token=BOT_TOKEN, parse_mode=ParseMode.HTML)
dp = Dispatcher(storage=MemoryStorage())

register_handlers(dp)

async def main():
    await dp.start_polling(bot)

if __name__ == '__main__':
    asyncio.run(main())
