#!/usr/bin/env bash
gunicorn manage:app -c configurations/gunicorn_conf.py
