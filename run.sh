#!/bin/bash
cd /etc/supervisor/conf.d/
sed -i "s|window.tokenapiUrl = 'http://0.0.0.0:6012'|window.tokenapiUrl = '$FLOAPIURL'|" /floscout/index.html

echo "running..."
supervisord -c /etc/supervisor/conf.d/ftt-ranchimallflo.conf
#./floscout/example