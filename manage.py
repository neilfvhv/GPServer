#!/usr/bin/env python
from flask_script import Manager, Shell
from flask_migrate import Migrate, MigrateCommand


from application import create_app, db
from application.models import User

mode = 'production'
app = create_app(mode)


def make_shell_context():
    return dict(app=app, db=db, User=User)


if __name__ == '__main__':
    manager = Manager(app)
    manager.add_command("shell", Shell(make_context=make_shell_context))
    manager.add_command('db', MigrateCommand)
    migrate = Migrate(app, db)
    manager.run()
