"""
cPanel (Passenger) icin WSGI entrypoint.

FastAPI (ASGI) uygulamasini Passenger'in WSGI arayuzune `a2wsgi`
araciligiyla baglar.

Iki yerlesim de desteklenir:

  1) Duz yerlesim (sunucuda kullanilan):
       <app_root>/
         passenger_wsgi.py
         main.py            # FastAPI
         config.py
         bist_analyzer.py
         news_helper.py
         chatgpt_helper.py
         requirements.txt

  2) Repo yerlesimi (lokal dev):
       mymodel/
         passenger_wsgi.py
         config.py
         ...
         api/
           main.py          # FastAPI

cPanel "Setup Python App":
    Application root:          <app_root>
    Application URL:           m-koray.online/api
    Application startup file:  passenger_wsgi.py
    Application Entry point:   application

Tum API anahtarlari (GROQ_API_KEY, NEWSAPI_KEY, OPENROUTER_API_KEY, ...)
cPanel "Environment variables" bolumunden tanimlanmalidir.
"""

import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

API_DIR = os.path.join(BASE_DIR, "api")
if os.path.isdir(API_DIR) and API_DIR not in sys.path:
    sys.path.insert(0, API_DIR)

from a2wsgi import ASGIMiddleware  # noqa: E402

try:
    from main import app as _fastapi_app  # duz yerlesim
except ModuleNotFoundError:
    from api.main import app as _fastapi_app  # repo yerlesimi

application = ASGIMiddleware(_fastapi_app)
