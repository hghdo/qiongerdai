#!/bin/bash

DESC="Examples of the daemon shell"

#NAME="t"
#DAEMON="/opt/java/bin/java"
#MAIN="/home/david/work/shell/daemon.jar"
#ARGS="-jar $MAIN"

DIR="/home/david/work/ror/qiongerdai"
NAME="spider"
DAEMON="$DIR/cronshell"
MAIN=""
ARGS="$MAIN"


PIDFILE="$DIR/$NAME.pid"
USER="david"

echo "$DAEMON"

#start-stop-daemon --start -b -m --pidfile "$PIDFILE" --chuid "$USER" --chdir "$DIR" --startas "$DAEMON" -- $ARGS
#start-stop-daemon --start --pidfile "$PIDFILE" --chuid "$USER" --chdir "$DIR" --startas "$DAEMON" -- "$ARGS"


case "$1" in
   (start)
      echo -n "Starting $DESC: $NAME"
      start-stop-daemon --start --pidfile "$PIDFILE" --chuid "$USER" --background --make-pidfile --startas "$DAEMON" -- $ARGS
      ;;
   (stop)
      echo -n "Stopping $DESC: $NAME"
      start-stop-daemon --stop --quiet --pidfile $PIDFILE
      ;;
   (restart)
      $0 stop
      $0 start
      ;;
   (*)
      echo $0 "start|stop"
      exit 1
      ;;
esac
exit 0