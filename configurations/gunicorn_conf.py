import datetime

bind = '0.0.0.0:5000'

worker_class = 'gevent'
workers = 4

daemon = True

timeout = 10 * 60

now = datetime.datetime.now()
now_str = str(now.year) + str(now.month) + str(now.day) + "_"\
          + str(now.hour) + str(now.minute) + str(now.second)
accesslog = 'logs/' + now_str + ".log"
errorlog = 'logs/' + now_str + ".log"
capture_output = True
