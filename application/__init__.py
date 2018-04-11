from flask import Flask
from flask_sqlalchemy import SQLAlchemy

import matlab.engine as engine

from .configs import config

print('Loading MATLAB Environment')
en = engine.start_matlab()
print('Loading End')

db = SQLAlchemy()


def create_app(config_name):

    app = Flask(__name__)

    app.config.from_object(config[config_name])
    config[config_name].init_app(config_name)

    db.init_app(app)

    from .main import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return app
