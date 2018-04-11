import os

app_directory = os.path.abspath(os.path.dirname(__file__))
upload_directory = os.path.abspath(app_directory + '/upload')
result_directory = os.path.abspath(app_directory + '/result')
base_directory = os.path.abspath(app_directory + '/../')
algorithm_directory = os.path.abspath(base_directory + '/algorithm')
databases_directory = 'sqlite:///' + base_directory + '/databases/'


class Config:

    SQLALCHEMY_TRACK_MODIFICATIONS = False

    @staticmethod
    def init_app(config_name):
        pass


class DevelopmentConfig(Config):

    DEBUG = True

    SQLALCHEMY_DATABASE_URI = databases_directory + 'data-dev.sqlite'


class TestingConfig(Config):

    TESTING = True

    SQLALCHEMY_DATABASE_URI = databases_directory + 'data-test.sqlite'


class ProductionConfig(Config):

    SQLALCHEMY_DATABASE_URI = databases_directory + 'data.sqlite'


config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
