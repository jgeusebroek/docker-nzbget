#!/bin/bash
set -x

USERNAME=${USERNAME:=nzbget}
GROUP=${GROUP:=nzbget}

if ! id -u "${USERNAME}" >/dev/null 2>&1; then
	groupadd --gid ${USER_GID:=4000} ${GROUP}
	useradd --uid ${USER_UID:=4000} --gid ${USER_GID:=4000} --system -M --shell /usr/sbin/nologin ${USERNAME}
	chown -R ${USERNAME}:${USERNAME} /usr/lib/nzbget
fi

if [ "${CHANGE_CONFIG_DIR_OWNERSHIP}" = true ]; then
  find /config ! -user ${USERNAME} -print0 | xargs -0 -I{} chown -R ${USERNAME}: {}
fi

if [ "${CHANGE_DIR_RIGHTS}" = true ]; then
  chgrp -R ${GROUP} /downloads
  chmod -R g+rX /downloads
fi

if [ ! -f /config/logs ]; then
	mkdir /config/logs
	touch /config/logs/nzbget.log
	chown -R ${USERNAME}:${GROUP} /config/logs
fi

if [ ! -f /config/queue ]; then
	mkdir /config/queue -p && chown ${USERNAME}:${GROUP} /config/queue
fi

if [ ! -f /config/nzb ]; then
	mkdir /config/nzb -p && chown ${USERNAME}:${GROUP} /config/nzb
fi

if [ ! -f /config/nzbget.conf ]; then
	cp /usr/lib/nzbget/nzbget.conf /config/nzbget.conf
	chown ${USERNAME}:${GROUP} /config/nzbget.conf
	sed -i -e "s#^\(TempDir=\).*#\1/downloads/tmp#g" /config/nzbget.conf
	sed -i -e "s#^\(DestDir=\).*#\1/downloads/dst#g" /config/nzbget.conf
	sed -i -e "s#^\(QueueDir=\).*#\1/config/queue#g" /config/nzbget.conf
	sed -i -e "s#^\(NzbDir=\).*#\1/config/nzb#g" /config/nzbget.conf
	sed -i -e "s#^\(InterDir=\).*#\1/downloads/int#g" /config/nzbget.conf
	sed -i -e "s#^\(ScriptDir=\).*#\1/config/scripts#g" /config/nzbget.conf
	sed -i -e "s#^\(LogFile=\).*#\1/config/logs/nzbget.log#g" /config/nzbget.conf
	sed -i -e "s#^\(LockFile=\).*#\1/usr/lib/nzbget/nzbget.lock#g" /config/nzbget.conf
fi

sudo -u ${USERNAME} -E sh -c "/usr/lib/nzbget/nzbget -c /config/nzbget.conf -D"
tail -f /config/logs/nzbget.log