# config.py

import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'clave-secreta-gestion-violeta')
    SQLALCHEMY_DATABASE_URI = os.environ.get(
        'DATABASE_URL',
        'postgresql://user:1234@localhost:5432/GESTIONDB'
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
