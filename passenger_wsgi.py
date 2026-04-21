"""
cPanel (Passenger) için minimal WSGI entrypoint.

Bu proje Telegram botu için polling (sonsuz çalışan process) kullanır.
Passenger web request süreci bunun için uygun değildir; botu CRON/Supervisor ile
`main.py` üzerinden çalıştırın.

Bu dosya sadece cPanel "Setup Python App" ekranında gerekli alanları doldurmak
ve venv/env yönetimini kullanabilmek içindir.
"""

def application(environ, start_response):
    status = "200 OK"
    headers = [("Content-Type", "text/plain; charset=utf-8")]
    start_response(status, headers)
    return [b"OK - Telegram bot bu endpoint uzerinden calismaz. Cron ile main.py calistirin.\n"]



