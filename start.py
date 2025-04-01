from aiogram import Router, F
from aiogram.types import Message, CallbackQuery
from aiogram.utils.keyboard import InlineKeyboardBuilder

router = Router()

def register(dp):
    dp.include_router(router)

@router.message(F.text == "/start")
async def start_cmd(message: Message):
    builder = InlineKeyboardBuilder()
    builder.button(text="🚀 Passer à Ultra", callback_data="upgrade")
    await message.answer("Bienvenue dans <b>MrWhiteBlack</b>\nStatut: Standard", reply_markup=builder.as_markup())
